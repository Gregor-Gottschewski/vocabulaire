import {Timestamp, getFirestore} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {REGION, VOCABULARY_LIMIT_PREMIUM} from "./counters";

const VOCABULARY_UPLOAD_WINDOW_MS = 24 * 60 * 60 * 1000;

// Determines whether the rolling upload window has elapsed and should restart at `now`.
function resolveUploadWindow(
    lastReset: Timestamp | undefined,
    now: Timestamp
): { resetWindow: boolean; windowStart: Timestamp } {
    if (!lastReset || now.toMillis() - lastReset.toMillis() > VOCABULARY_UPLOAD_WINDOW_MS) {
        return {resetWindow: true, windowStart: now};
    }
    return {resetWindow: false, windowStart: lastReset};
}

function validateCount(raw: unknown): number {
    const count = typeof raw === "number" ? raw : NaN;
    if (!Number.isInteger(count) || count <= 0 || count > VOCABULARY_LIMIT_PREMIUM) {
        throw new HttpsError("invalid-argument", "Invalid vocabulary count.");
    }
    return count;
}

/**
 * Atomically reserves `count` vocabulary uploads.
 */
export const reserveVocabularyUpload = onCall(
    {region: REGION, enforceAppCheck: true},
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Login required.");
        }
        const uid = request.auth.uid;
        const count = validateCount(request.data?.count);

        const db = getFirestore();
        const rateLimitRef = db.collection("rateLimits").doc(uid);

        await db.runTransaction(async (tx) => {
            const snap = await tx.get(rateLimitRef);
            const data = snap.exists ? snap.data()! : {};

            const now = Timestamp.now();
            const {resetWindow, windowStart} = resolveUploadWindow(
                data.lastUploadReset as Timestamp | undefined, now
            );

            const hasStoredReservations = data.vocabularyReservations !== undefined;
            const dailyReservations = resetWindow || !hasStoredReservations ?
                0 : (data.vocabularyReservations as number);

            if (dailyReservations + count > VOCABULARY_LIMIT_PREMIUM) {
                throw new HttpsError("resource-exhausted", "Daily vocabulary quota exhausted.");
            }

            const countOnline = (data.vocabularyCountOnline as number | undefined) ?? 0;
            if (countOnline + count > VOCABULARY_LIMIT_PREMIUM) {
                throw new HttpsError("resource-exhausted", "Vocabulary limit reached.");
            }

            tx.set(rateLimitRef, {
                vocabularyReservations: dailyReservations + count,
                lastUploadReset: windowStart,
            }, {merge: true});
        });
        return {reserved: count};
    }
);
