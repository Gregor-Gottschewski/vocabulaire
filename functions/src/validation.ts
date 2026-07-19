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

/**
 * Maps the ISO-639-1 codes supported by the client (see AppLanguage client) to BCP-47 tags.
 */
export const SUPPORTED_LANGUAGE_CODES: Readonly<Record<string, string>> = {
    de: "de-DE",
    en: "en-US",
    fr: "fr-FR",
    es: "es-ES",
    it: "it-IT",
    pt: "pt-PT",
    nl: "nl-NL",
    ru: "ru-RU",
    pl: "pl-PL",
    tr: "tr-TR",
    zh: "zh-CN",
    ja: "ja-JP",
    da: "da-DK",
    cs: "cs-CZ",
    hu: "hu-HU",
    ko: "ko-KR",
};

/**
 * Validates the client-supplied language code against a fixed allowlist and
 * returns the corresponding BCP-47 tag.
 */
export function validateLanguageCode(raw: unknown): string {
    const code = typeof raw === "string" ? raw.trim() : "";
    const mapped = SUPPORTED_LANGUAGE_CODES[code];

    if (!mapped) {
        throw new HttpsError(
            "invalid-argument",
            `Unsupported language code: ${JSON.stringify(raw)}.`
        );
    }
    return mapped;
}
