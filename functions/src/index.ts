import { initializeApp } from "firebase-admin/app";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { consumeRateLimit } from "./rateLimiter";
import { synthesize } from "./ttsClient";
import { validateText } from "./validation";

initializeApp();

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
    await consumeRateLimit(request.auth.uid);

    const { audioContent, mimeType } = await synthesize(text);

    return {
      audioContent: audioContent.toString("base64"),
      mimeType,
    };
  }
);
