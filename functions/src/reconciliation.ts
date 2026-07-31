import {getFirestore} from "firebase-admin/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";

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
