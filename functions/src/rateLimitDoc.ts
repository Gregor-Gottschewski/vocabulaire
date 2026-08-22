import { Timestamp, getFirestore } from "firebase-admin/firestore";
import * as functionsV1 from "firebase-functions/v1";

export const onUserCreated = functionsV1
  .region("europe-west1")
  .auth.user()
  .onCreate(async (user) => {
    await getFirestore().collection("rateLimits").doc(user.uid).set({
      ttsCallCount: 0,
      ttsWindowStart: Timestamp.now(),
      isPremium: false,
      vocabularyCountOnline: 0,
      groupCountOnline: 0,
      audioBytesUsed: 0,
    });
  });
