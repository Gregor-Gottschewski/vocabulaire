import {Timestamp} from "firebase-admin/firestore";

/** True iff `data.subscriptionExpiresAt` is a Firestore Timestamp in the future. */
export function isPremiumActive(
  data: FirebaseFirestore.DocumentData | undefined | null
): boolean {
  const expiresAt = data?.subscriptionExpiresAt as Timestamp | null | undefined;
  return !!expiresAt && expiresAt.toMillis() > Date.now();
}
