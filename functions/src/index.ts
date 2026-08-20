import { initializeApp } from "firebase-admin/app";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { consumeRateLimit } from "./rateLimiter";
import { synthesize } from "./ttsClient";
import { validateLanguageCode, validateText } from "./validation";

initializeApp();

export {
  onAudioDelete,
  onAudioFinalize,
  onVocabularyCreated,
  onVocabularyDeleted,
} from "./counters";
export { reconcileAudioUsage, reconcileVocabularyCounts } from "./reconciliation";
export { onUserCreated } from "./rateLimitDoc";
export { reserveAudioUpload } from "./audioReservations";

export const synthesizeSpeech = onCall(
  {
    region: "europe-west1",
    enforceAppCheck: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Anonymous login required.");
    }

    const text = validateText(request.data?.text);
    const languageCode = validateLanguageCode(request.data?.languageCode);
    await consumeRateLimit(request.auth.uid);

    const { audioContent, mimeType } = await synthesize(text, languageCode);

    return {
      audioContent: audioContent.toString("base64"),
      mimeType,
    };
  }
);
