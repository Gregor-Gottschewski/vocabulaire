import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {onDocumentCreated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import {onObjectDeleted, onObjectFinalized, StorageEvent} from "firebase-functions/v2/storage";
import {consumeReservation, releaseReservation} from "./audioReservations";

const REGION = "europe-west1";
const GROUP_PATH = "users/{uid}/groups/{groupId}";
const BOX_PATH = "users/{uid}/groups/{groupId}/boxes/{boxId}";
const VOCABULARY_PATH = "users/{uid}/groups/{groupId}/boxes/{boxId}/vocabularies/{vocabId}";
const AUDIO_PATH_PATTERN = /^users\/([^/]+)\/audio\/([^/]+)$/;

// Keep in sync with the vocabulary quota check in firestore.rules.
const VOCABULARY_LIMIT_PREMIUM = 3000;

async function adjustRateLimitField(uid: string, field: string, delta: number): Promise<void> {
    if (delta === 0) return;
    await getFirestore()
        .collection("rateLimits")
        .doc(uid)
        .set({[field]: FieldValue.increment(delta)}, {merge: true});
}

async function adjustGroupField(uid: string, groupId: string, field: string, delta: number): Promise<void> {
    if (delta === 0) return;
    await getFirestore()
        .collection("users")
        .doc(uid)
        .collection("groups")
        .doc(groupId)
        .set({[field]: FieldValue.increment(delta)}, {merge: true});
}

// Keeps rateLimits/{uid}.groupCountOnline in sync with the user's groups.
export const onGroupCreated = onDocumentCreated(
    {region: REGION, document: GROUP_PATH},
    async (event) => {
        await adjustRateLimitField(event.params.uid, "groupCountOnline", 1);
    }
);

export const onGroupDeleted = onDocumentDeleted(
    {region: REGION, document: GROUP_PATH},
    async (event) => {
        await adjustRateLimitField(event.params.uid, "groupCountOnline", -1);
    }
);

export const onBoxCreated = onDocumentCreated(
    {region: REGION, document: BOX_PATH},
    async (event) => {
        await adjustGroupField(event.params.uid, event.params.groupId, "boxCountOnline", 1);
    }
);

export const onBoxDeleted = onDocumentDeleted(
    {region: REGION, document: BOX_PATH},
    async (event) => {
        await adjustGroupField(event.params.uid, event.params.groupId, "boxCountOnline", -1);
    }
);

// Re-validates the quota inside a transaction and deletes the vocabulary if a race condition occurs.
export const onVocabularyCreated = onDocumentCreated(
    {region: REGION, document: VOCABULARY_PATH},
    async (event) => {
        const uid = event.params.uid;
        const vocabRef = event.data?.ref;
        if (!vocabRef) return;

        const rateLimitRef = getFirestore().collection("rateLimits").doc(uid);
        await getFirestore().runTransaction(async (tx) => {
            const snap = await tx.get(rateLimitRef);
            const data = snap.exists ? snap.data()! : {};
            const limit = VOCABULARY_LIMIT_PREMIUM;
            const count = (data.vocabularyCountOnline as number | undefined) ?? 0;

            if (count >= limit) {
                tx.delete(vocabRef);
                tx.set(rateLimitRef, {
                    vocabulariesRejectedCount: FieldValue.increment(1),
                    lastRejectedAt: FieldValue.serverTimestamp(),
                }, {merge: true});
                return;
            }

            tx.set(rateLimitRef, {vocabularyCountOnline: FieldValue.increment(1)}, {merge: true});
        });
    }
);

export const onVocabularyDeleted = onDocumentDeleted(
    {region: REGION, document: VOCABULARY_PATH},
    async (event) => {
        await adjustRateLimitField(event.params.uid, "vocabularyCountOnline", -1);
        await releaseReservation(event.params.uid, `${event.params.vocabId}.m4a`);
    }
);

function parseAudioObjectName(objectName: string): {uid: string; fileName: string} | null {
    const match = AUDIO_PATH_PATTERN.exec(objectName);
    return match ? {uid: match[1], fileName: match[2]} : null;
}

export const onAudioFinalize = onObjectFinalized({region: REGION}, async (event: StorageEvent) => {
    const parsed = parseAudioObjectName(event.data.name);
    if (!parsed) return;
    await consumeReservation(parsed.uid, parsed.fileName, Number(event.data.size));
});

export const onAudioDelete = onObjectDeleted({region: REGION}, async (event: StorageEvent) => {
    const parsed = parseAudioObjectName(event.data.name);
    if (!parsed) return;
    await adjustRateLimitField(parsed.uid, "audioBytesUsed", -event.data.size);
});
