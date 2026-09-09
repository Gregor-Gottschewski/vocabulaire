import { readFileSync } from "fs";
import { join } from "path";
import {
    Environment,
    SignedDataVerifier,
    VerificationException,
    VerificationStatus,
    type JWSTransactionDecodedPayload,
    type ResponseBodyV2DecodedPayload,
} from "@apple/app-store-server-library";
import { defineSecret } from "firebase-functions/params";

/** Bundle identifier of the iOS/macOS app, shared by both StoreKit environments. */
export const appleBundleId = "me.gregorgott.vocabulaire";
export const appleAppId = defineSecret("APPLE_APP_ID");

let verifiersCache: { sandbox: SignedDataVerifier; production?: SignedDataVerifier } | undefined;

function verifiers(): { sandbox: SignedDataVerifier; production?: SignedDataVerifier } {
    if (!verifiersCache) {
        const rootCertificate = readFileSync(join(__dirname, "..", "certs", "AppleRootCA-G3.cer"));
        const sandbox = new SignedDataVerifier(
            [rootCertificate],
            true,
            Environment.SANDBOX,
            appleBundleId
        );

        const appAppleIdValue = appleAppId.value();
        const production = appAppleIdValue
            ? new SignedDataVerifier(
                  [rootCertificate],
                  true,
                  Environment.PRODUCTION,
                  appleBundleId,
                  Number(appAppleIdValue)
              )
            : undefined;

        verifiersCache = { sandbox, production };
    }
    return verifiersCache;
}

/**
 * Verifies and decodes a signed transaction.
 */
export async function verifyAndDecodeTransaction(
    signedTransactionInfo: string
): Promise<JWSTransactionDecodedPayload> {
    const { sandbox, production } = verifiers();
    if (!production) {
        return sandbox.verifyAndDecodeTransaction(signedTransactionInfo);
    }
    try {
        return await production.verifyAndDecodeTransaction(signedTransactionInfo);
    } catch (e) {
        if (e instanceof VerificationException && e.status === VerificationStatus.INVALID_ENVIRONMENT) {
            return await sandbox.verifyAndDecodeTransaction(signedTransactionInfo);
        }
        throw e;
    }
}

/** Verifies and decodes an App Store Server Notifications V2 payload. */
export async function verifyAndDecodeNotification(
    signedPayload: string
): Promise<ResponseBodyV2DecodedPayload> {
    const { sandbox, production } = verifiers();
    if (!production) {
        return sandbox.verifyAndDecodeNotification(signedPayload);
    }
    try {
        return await production.verifyAndDecodeNotification(signedPayload);
    } catch (e) {
        if (e instanceof VerificationException && e.status === VerificationStatus.INVALID_ENVIRONMENT) {
            return await sandbox.verifyAndDecodeNotification(signedPayload);
        }
        throw e;
    }
}
