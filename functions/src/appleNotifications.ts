import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { NotificationTypeV2 } from "@apple/app-store-server-library";
import { appleAppId, verifyAndDecodeNotification, verifyAndDecodeTransaction } from "./appleVerification";

const REGION = "europe-west1";

/** Notification types after which the subscription is no longer active. */
const PREMIUM_REVOKING_TYPES = new Set<string>([
    NotificationTypeV2.EXPIRED,
    NotificationTypeV2.REVOKE,
    NotificationTypeV2.REFUND,
    NotificationTypeV2.GRACE_PERIOD_EXPIRED,
    NotificationTypeV2.DID_FAIL_TO_RENEW,
]);

/**
 * Public webhook for Apple's App Store Server Notifications.
 */
export const appleServerNotifications = onRequest(
    { region: REGION, secrets: [appleAppId] },
    async (req, res) => {
        if (req.method !== "POST") {
            res.status(405).send("Method not allowed.");
            return;
        }

        const signedPayload = req.body?.signedPayload;
        if (typeof signedPayload !== "string") {
            res.status(400).send("Missing signedPayload.");
            return;
        }

        let notification;
        try {
            notification = await verifyAndDecodeNotification(signedPayload);
        } catch (e) {
            console.error("appleServerNotifications: signature verification failed", e);
            res.status(400).send("Invalid signature.");
            return;
        }

        const signedTransactionInfo = notification.data?.signedTransactionInfo;
        if (!signedTransactionInfo) {
            res.status(200).send("OK");
            return;
        }

        let transaction;
        try {
            transaction = await verifyAndDecodeTransaction(signedTransactionInfo);
        } catch (e) {
            console.error("appleServerNotifications: transaction verification failed", e);
            res.status(400).send("Invalid transaction signature.");
            return;
        }

        const originalTransactionId = transaction.originalTransactionId;
        if (!originalTransactionId) {
            res.status(200).send("OK");
            return;
        }

        const db = getFirestore();
        const subscriptionRef = db.collection("appleSubscriptions").doc(originalTransactionId);

        const subscriptionSnap = await subscriptionRef.get();
        if (!subscriptionSnap.exists) {
            console.warn(
                `appleServerNotifications: unknown originalTransactionId ${originalTransactionId}`
            );
            res.status(200).send("OK");
            return;
        }
        if (!subscriptionSnap.data()?.uid) {
            res.status(200).send("OK");
            return;
        }

        const notificationType = notification.notificationType;
        const isRevoking = notificationType != null && PREMIUM_REVOKING_TYPES.has(notificationType);
        const expiresDate = transaction.expiresDate;
        const subscriptionExpiresAt = isRevoking || !expiresDate ? null : Timestamp.fromMillis(expiresDate);
        const incomingSignedDate = transaction.signedDate;

        await db.runTransaction(async (tx) => {
            const freshSnap = await tx.get(subscriptionRef);
            const freshData = freshSnap.data();
            const uid = freshData?.uid as string | undefined;
            if (!uid) {
                return;
            }

            const lastEventSignedDate = freshData?.lastEventSignedDate as number | undefined;
            if (
                lastEventSignedDate != null &&
                incomingSignedDate != null &&
                incomingSignedDate < lastEventSignedDate
            ) {
                return;
            }

            tx.set(
                db.collection("rateLimits").doc(uid),
                {
                    subscriptionProductId: transaction.productId ?? null,
                    subscriptionExpiresAt,
                    subscriptionStatus: notificationType ?? null,
                    subscriptionUpdatedAt: Timestamp.now(),
                },
                { merge: true }
            );

            tx.set(
                subscriptionRef,
                {
                    lastEventSignedDate: incomingSignedDate ?? lastEventSignedDate ?? null,
                    ...(isRevoking ? { uid: FieldValue.delete() } : {}),
                },
                { merge: true }
            );
        });

        res.status(200).send("OK");
    }
);
