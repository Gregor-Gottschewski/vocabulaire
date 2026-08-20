import {Timestamp, getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {releaseReservation} from "./audioReservations";

const REGION = "europe-west1";

// Safety net against counter drift
export const reconcileVocabularyCounts = onSchedule(
    {region: REGION, schedule: "every day 04:00", timeZone: "Europe/Berlin"},
    async () => {
        const db = getFirestore();
        const rateLimitDocs = await db.collection("rateLimits").get();

        await Promise.all(rateLimitDocs.docs.map(async (doc) => {
            const uid = doc.id;
            const stored = (doc.data().vocabularyCountOnline as number | undefined) ?? 0;

            const aggregate = await db
                .collectionGroup("vocabularies")
                .where("ownerUid", "==", uid)
                .where("deleted", "==", false)
                .count()
                .get();
            const actual = aggregate.data().count;

            if (actual !== stored) {
                await doc.ref.set({vocabularyCountOnline: actual}, {merge: true});
            }
        }));
    }
);

// Releases reservations left dangling by uploads that never completed (or failed to clean up).
export const reconcileReservedAudioUsage = onSchedule(
    {region: REGION, schedule: "every 60 minutes"},
    async () => {
        const db = getFirestore();

        const expiredReservations = await db
            .collection("audioReservations")
            .where("expiresAt", "<=", Timestamp.now())
            .get();

        await Promise.all(expiredReservations.docs.map((doc) => {
            const data = doc.data();
            return releaseReservation(data.uid as string, data.fileName as string);
        }));
    }
);

// Safety net against audio quota drift.
export const reconcileAudioUsageLimits = onSchedule(
    {region: REGION, schedule: "every 120 minutes"},
    async () => {
        const db = getFirestore();
        const rateLimitDocs = await db.collection("rateLimits").get();

        await Promise.all(rateLimitDocs.docs.map(async (doc) => {
            const uid = doc.id;
            const stored = (doc.data().audioBytesUsed as number | undefined) ?? 0;

            const [files] = await getStorage().bucket().getFiles({prefix: `users/${uid}/audio/`});
            const actual = files.reduce((sum, file) => sum + Number(file.metadata.size ?? 0), 0);

            if (actual !== stored) {
                await doc.ref.set({audioBytesUsed: actual}, {merge: true});
            }
        }));
    }
);
