import {Timestamp, getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {releaseReservation} from "./audioReservations";
import {AUDIO_PATH_PATTERN} from "./storagePaths";

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

// Safety net against groupCountOnline drift.
export const reconcileGroupCounts = onSchedule(
    {region: REGION, schedule: "every day 04:15", timeZone: "Europe/Berlin"},
    async () => {
        const db = getFirestore();
        const rateLimitDocs = await db.collection("rateLimits").get();

        await Promise.all(rateLimitDocs.docs.map(async (doc) => {
            const uid = doc.id;
            const stored = (doc.data().groupCountOnline as number | undefined) ?? 0;

            const aggregate = await db
                .collection("users").doc(uid).collection("groups")
                .where("deleted", "==", false)
                .count()
                .get();
            const actual = aggregate.data().count;

            if (actual !== stored) {
                await doc.ref.set({groupCountOnline: actual}, {merge: true});
            }
        }));
    }
);

// Safety net against per-group boxCountOnline drift.
export const reconcileBoxCounts = onSchedule(
    {region: REGION, schedule: "every day 04:30", timeZone: "Europe/Berlin"},
    async () => {
        const db = getFirestore();
        const rateLimitDocs = await db.collection("rateLimits").get();

        await Promise.all(rateLimitDocs.docs.map(async (doc) => {
            const uid = doc.id;

            const boxesSnapshot = await db
                .collectionGroup("boxes")
                .where("ownerUid", "==", uid)
                .where("deleted", "==", false)
                .get();

            const countsByGroup = new Map<string, number>();
            for (const boxDoc of boxesSnapshot.docs) {
                const groupId = boxDoc.ref.parent.parent!.id;
                countsByGroup.set(groupId, (countsByGroup.get(groupId) ?? 0) + 1);
            }

            const groupsSnapshot = await db.collection("users").doc(uid).collection("groups").get();
            await Promise.all(groupsSnapshot.docs.map(async (groupDoc) => {
                const stored = (groupDoc.data().boxCountOnline as number | undefined) ?? 0;
                const actual = countsByGroup.get(groupDoc.id) ?? 0;
                if (actual !== stored) {
                    await groupDoc.ref.set({boxCountOnline: actual}, {merge: true});
                }
            }));
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

            const [files] = await getStorage().bucket().getFiles({prefix: `users/${uid}/groups/`});
            const actual = files
                .filter((file) => AUDIO_PATH_PATTERN.test(file.name))
                .reduce((sum, file) => sum + Number(file.metadata.size ?? 0), 0);

            if (actual !== stored) {
                await doc.ref.set({audioBytesUsed: actual}, {merge: true});
            }
        }));
    }
);
