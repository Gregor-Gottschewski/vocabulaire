import {HttpsError} from "firebase-functions/v2/https";

export const MAX_CHARS = 65;

/**
 * Validates the text to be synthesized.
 */
export function validateText(raw: unknown): string {
    const text = typeof raw === "string" ? raw.trim() : "";

    if (!text) {
        throw new HttpsError("invalid-argument", "Text must not be empty.");
    }
    if (text.length > MAX_CHARS) {
        throw new HttpsError(
            "invalid-argument",
            `Max text length is ${MAX_CHARS}.`
        );
    }
    return text;
}
