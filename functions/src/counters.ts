import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {onDocumentCreated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import {onObjectDeleted, onObjectFinalized, StorageEvent} from "firebase-functions/v2/storage";

const REGION = "europe-west1";
const VOCABULARY_PATH = "users/{uid}/boxes/{boxId}/vocabularies/{vocabId}";
const AUDIO_PATH_PATTERN = /^users\/([^/]+)\/audio\//;

async function adjustRateLimitField(uid: string, field: string, delta: number): Promise<void> {
    if (delta === 0) return;
    await getFirestore()
        .collection("rateLimits")
        .doc(uid)
        .set({[field]: FieldValue.increment(delta)}, {merge: true});
}

export const onVocabularyCreated = onDocumentCreated(
    {region: REGION, document: VOCABULARY_PATH},
    async (event) => {
        await adjustRateLimitField(event.params.uid, "vocabularyCountOnline", 1);
    }
);

export const onVocabularyDeleted = onDocumentDeleted(
    {region: REGION, document: VOCABULARY_PATH},
    async (event) => {
        await adjustRateLimitField(event.params.uid, "vocabularyCountOnline", -1);
    }
);

function uidFromAudioObjectName(objectName: string): string | null {
    const match = AUDIO_PATH_PATTERN.exec(objectName);
    return match ? match[1] : null;
}

async function handleAudioObjectEvent(event: StorageEvent, sign: 1 | -1): Promise<void> {
    const uid = uidFromAudioObjectName(event.data.name);
    if (!uid) return;
    await adjustRateLimitField(uid, "audioBytesUsed", sign * event.data.size);
}

export const onAudioFinalize = onObjectFinalized({region: REGION}, async (event) => {
    await handleAudioObjectEvent(event, 1);
});

export const onAudioDelete = onObjectDeleted({region: REGION}, async (event) => {
    await handleAudioObjectEvent(event, -1);
});
