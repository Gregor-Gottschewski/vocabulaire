import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { appleAppId, appleBundleId, verifyAndDecodeTransaction } from "./appleVerification";

const REGION = "europe-west1";

class SubscriptionConflictError extends Error {
    constructor(readonly conflictingUid: string) {
        super("subscription-linked-to-other-account");
    }
}

/**
 * Verifies a signed StoreKit 2 transaction (from a purchase or a restore) and
 * mirrors the resulting subscription status onto `rateLimits/{uid}`.
 */
export const verifyAppleSubscription = onCall(
    { region: REGION, enforceAppCheck: true, secrets: [appleAppId] },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Login required.");
        }
        const uid = request.auth.uid;

        const signedTransactionInfo = request.data?.signedTransactionInfo;
        if (typeof signedTransactionInfo !== "string" || signedTransactionInfo.length === 0) {
            throw new HttpsError("invalid-argument", "Missing signed transaction.");
        }

        let transaction;
        try {
            transaction = await verifyAndDecodeTransaction(signedTransactionInfo);
        } catch (e) {
            console.error("verifyAppleSubscription: transaction verification failed", e);
            throw new HttpsError("invalid-argument", "Could not verify transaction.");
        }

        if (transaction.bundleId !== appleBundleId) {
            throw new HttpsError("invalid-argument", "Transaction bundle id mismatch.");
        }

        const { originalTransactionId, productId, expiresDate, environment } = transaction;
        if (!originalTransactionId || !productId || !expiresDate) {
            throw new HttpsError("invalid-argument", "Incomplete transaction data.");
        }

        const db = getFirestore();
        const rateLimitRef = db.collection("rateLimits").doc(uid);
        const subscriptionRef = db.collection("appleSubscriptions").doc(originalTransactionId);

        try {
            await db.runTransaction(async (tx) => {
                const existingSnap = await tx.get(subscriptionRef);
                const existingUid = existingSnap.exists ? (existingSnap.data()?.uid as string | undefined) : undefined;

                if (existingUid && existingUid !== uid) {
                    throw new SubscriptionConflictError(existingUid);
                }

                tx.set(
                    rateLimitRef,
                    {
                        subscriptionProductId: productId,
                        subscriptionExpiresAt: Timestamp.fromMillis(expiresDate),
                        subscriptionOriginalTransactionId: originalTransactionId,
                        subscriptionEnvironment: environment ?? null,
                        subscriptionUpdatedAt: Timestamp.now(),
                    },
                    { merge: true }
                );
                tx.set(subscriptionRef, { uid, productId }, { merge: true });
            });
        } catch (e) {
            if (e instanceof SubscriptionConflictError) {
                let email: string | null = null;
                try {
                    const otherUser = await getAuth().getUser(e.conflictingUid);
                    email = otherUser.email ?? null;
                } catch (lookupErr) {
                    console.error("verifyAppleSubscription: could not resolve conflicting uid", lookupErr);
                }
                throw new HttpsError("already-exists", "This subscription is already linked to another account.", {
                    reason: "subscription-linked-to-other-account",
                    email,
                });
            }
            throw e;
        }

        return { subscriptionExpiresAt: expiresDate };
    }
);
