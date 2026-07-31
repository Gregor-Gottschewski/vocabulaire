import {FieldValue, Timestamp, getFirestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

const DAILY_LIMIT_FREE = 1;
const DAILY_LIMIT_PREMIUM = 50;
const WINDOW_MS = 24 * 60 * 60 * 1000;

/**
 * The Google TTS backend is limited because of costs that emerge while using the API.
 * Two limits exists: DAILY_LIMIT_FREE and DAILY_LIMIT_PREMIUM.
 * A premium user has DAILY_LIMIT_FREE + DAILY_LIMIT_PREMIUM TTS API calls per WINDOW_MS.
 * A non-paying user has DAILY_LIMIT_FREE TTS API calls per WINDOW_MS.
 */
export async function consumeRateLimit(uid: string): Promise<void> {
    const ref = getFirestore().collection("rateLimits").doc(uid);

    await getFirestore().runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        const now = Timestamp.now();

        if (!snap.exists) {
            tx.set(ref, {ttsCallCount: 1, ttsWindowStart: now, isPremium: false});
            return;
        }

        const data = snap.data()!;
        const isPremium = data.isPremium === true;
        const limit = isPremium ? DAILY_LIMIT_PREMIUM + DAILY_LIMIT_FREE : DAILY_LIMIT_FREE;

        const windowStart = data.ttsWindowStart as Timestamp;
        const windowExpired = now.toMillis() - windowStart.toMillis() > WINDOW_MS;

        if (windowExpired) {
            tx.set(ref, {ttsCallCount: 1, ttsWindowStart: now, isPremium}, {merge: true});
            return;
        }

        if ((data.ttsCallCount ?? 0) >= limit) {
            throw new HttpsError(
                "resource-exhausted",
                "Limit for text-to-speech reached."
            );
        }

        tx.update(ref, {ttsCallCount: FieldValue.increment(1)});
    });
}
