import {FieldValue, Timestamp, getFirestore} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

const REGION = "europe-west1";

export const AUDIO_STORAGE_LIMIT_BYTES = 50 * 1024 * 1024;

// A reservation is a short-lived promise of quota, made atomically inside a Firestore
// transaction before the client uploads to Storage.
const RESERVATION_TTL_MS = 60 * 1000; // 1 minute: 1 * 60 * 1000

function reservationRef(uid: string, fileName: string) {
    return getFirestore().collection("audioReservations").doc(`${uid}_${fileName}`);
}

function validateId(raw: unknown, label: string): string {
    const id = typeof raw === "string" ? raw.trim() : "";
    if (id.length === 0 || id.includes("/")) {
        throw new HttpsError("invalid-argument", `Invalid ${label}.`);
    }
    return id;
}

function validateSizeBytes(raw: unknown): number {
    const size = typeof raw === "number" ? raw : NaN;
    if (!Number.isFinite(size) || size <= 0 || size > AUDIO_STORAGE_LIMIT_BYTES) {
        throw new HttpsError("invalid-argument", "Invalid audio size.");
    }
    return Math.floor(size);
}

/**
 * Atomically reserves `sizeBytes` of the caller's audio storage quota for `fileName`.
 */
export const reserveAudioUpload = onCall(
    {region: REGION, enforceAppCheck: true},
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Login required.");
        }
        const uid = request.auth.uid;
        const boxId = validateId(request.data?.boxId, "box id");
        const vocabId = validateId(request.data?.vocabId, "vocabulary id");
        const sizeBytes = validateSizeBytes(request.data?.sizeBytes);
        const fileName = `${vocabId}.m4a`;

        const db = getFirestore();
        const rateLimitRef = db.collection("rateLimits").doc(uid);
        const reservation = reservationRef(uid, fileName);
        const vocabRef = db.doc(`users/${uid}/boxes/${boxId}/vocabularies/${vocabId}`);

        await db.runTransaction(async (tx) => {
            const [rateLimitSnap, reservationSnap, vocabSnap] = await Promise.all([
                tx.get(rateLimitRef),
                tx.get(reservation),
                tx.get(vocabRef),
            ]);

            if (!vocabSnap.exists || vocabSnap.data()?.deleted === true) {
                throw new HttpsError("not-found", "Vocabulary not found.");
            }

            const rateLimitData = rateLimitSnap.exists ? rateLimitSnap.data()! : {};
            if (rateLimitData.isPremium !== true) {
                throw new HttpsError("permission-denied", "Premium subscription required.");
            }

            const used = (rateLimitData.audioBytesUsed as number | undefined) ?? 0;
            const reserved = (rateLimitData.audioBytesReserved as number | undefined) ?? 0;

            const previousSize = reservationSnap.exists ?
                ((reservationSnap.data()!.sizeBytes as number | undefined) ?? 0) :
                0;

            const netReserved = reserved - previousSize + sizeBytes;
            if (used + netReserved > AUDIO_STORAGE_LIMIT_BYTES) {
                throw new HttpsError("resource-exhausted", "Audio storage limit reached.");
            }

            const now = Timestamp.now();
            tx.set(rateLimitRef, {
                audioBytesReserved: FieldValue.increment(sizeBytes - previousSize),
            }, {merge: true});
            tx.set(reservation, {
                uid,
                fileName,
                sizeBytes,
                createdAt: now,
                expiresAt: Timestamp.fromMillis(now.toMillis() + RESERVATION_TTL_MS),
            });
        });

        return {expiresInMs: RESERVATION_TTL_MS};
    }
);

/** Releases a reservation (if any) without requiring the upload it was made for. */
export async function releaseReservation(uid: string, fileName: string): Promise<void> {
    const db = getFirestore();
    const rateLimitRef = db.collection("rateLimits").doc(uid);
    const reservation = reservationRef(uid, fileName);

    await db.runTransaction(async (tx) => {
        const snap = await tx.get(reservation);
        if (!snap.exists) return;
        const sizeBytes = (snap.data()!.sizeBytes as number | undefined) ?? 0;
        tx.delete(reservation);
        tx.set(rateLimitRef, {audioBytesReserved: FieldValue.increment(-sizeBytes)}, {merge: true});
    });
}

/**
 * Consumes the reservation for `fileName`.
 */
export async function consumeReservation(
    uid: string,
    fileName: string,
    actualSizeBytes: number
): Promise<void> {
    const db = getFirestore();
    const rateLimitRef = db.collection("rateLimits").doc(uid);
    const reservation = reservationRef(uid, fileName);

    await db.runTransaction(async (tx) => {
        const snap = await tx.get(reservation);
        const reservedSize = snap.exists ? (snap.data()!.sizeBytes as number | undefined) : undefined;

        if (reservedSize === undefined || reservedSize !== actualSizeBytes) {
            console.warn(
                `consumeReservation: no matching reservation for ${uid}/${fileName} ` +
                `(reserved=${reservedSize}, actual=${actualSizeBytes}); recording usage only.`
            );
            tx.set(rateLimitRef, {audioBytesUsed: FieldValue.increment(actualSizeBytes)}, {merge: true});
            return;
        }

        tx.set(rateLimitRef, {
            audioBytesUsed: FieldValue.increment(actualSizeBytes),
            audioBytesReserved: FieldValue.increment(-reservedSize),
        }, {merge: true});
        tx.delete(reservation);
    });
}
