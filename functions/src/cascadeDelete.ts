import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {BOX_PATH, GROUP_PATH, REGION, VOCABULARY_PATH} from "./counters";
import {audioObjectPath, boxAudioPrefix, groupPrefix} from "./storagePaths";

// True only on the false -> true (or undefined -> true) transition of `deleted`
function isFreshSoftDelete(before: FirebaseFirestore.DocumentData | undefined, after: FirebaseFirestore.DocumentData | undefined): boolean {
    return !!before && !!after && before.deleted !== true && after.deleted === true;
}

export const onGroupSoftDeleted = onDocumentUpdated(
    {region: REGION, document: GROUP_PATH, timeoutSeconds: 300, retry: true},
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();
        if (!isFreshSoftDelete(before, after)) return;

        const eventAgeMs = Date.now() - Date.parse(event.time);
        const eventMaxAgeMs = 1000 * 60 * 3; // retry for 3 minutes
        if (eventAgeMs > eventMaxAgeMs) {
            console.log(`Dropping event ${event} with age[ms]: ${eventAgeMs}`);
            return;
        }

        const {uid, groupId} = event.params;
        await Promise.all([
            getStorage().bucket().deleteFiles({prefix: groupPrefix(uid, groupId), force: true}),
            getFirestore().recursiveDelete(event.data!.after.ref),
        ]);
    }
);

export const onBoxSoftDeleted = onDocumentUpdated(
    {region: REGION, document: BOX_PATH, timeoutSeconds: 300, retry: true},
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();
        if (!isFreshSoftDelete(before, after)) return;

        const eventAgeMs = Date.now() - Date.parse(event.time);
        const eventMaxAgeMs = 1000 * 60 * 3; // retry for 3 minutes
        if (eventAgeMs > eventMaxAgeMs) {
            console.log(`Dropping event ${event} with age[ms]: ${eventAgeMs}`);
            return;
        }

        const {uid, groupId, boxId} = event.params;
        await Promise.all([
            getStorage().bucket().deleteFiles({prefix: boxAudioPrefix(uid, groupId, boxId), force: true}),
            getFirestore().recursiveDelete(event.data!.after.ref),
        ]);
    }
);

export const onVocabularySoftDeleted = onDocumentUpdated(
    {region: REGION, document: VOCABULARY_PATH, retry: true},
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();
        if (!isFreshSoftDelete(before, after)) return;

        const eventAgeMs = Date.now() - Date.parse(event.time);
        const eventMaxAgeMs = 1000 * 60 * 3; // retry for 3 minutes
        if (eventAgeMs > eventMaxAgeMs) {
            console.log(`Dropping event ${event} with age[ms]: ${eventAgeMs}`);
            return;
        }

        const {uid, groupId, boxId, vocabId} = event.params;
        await Promise.all([
            getStorage().bucket().file(audioObjectPath(uid, groupId, boxId, vocabId)).delete({ignoreNotFound: true}),
            event.data!.after.ref.delete(),
        ]);
    }
);
