// Single source of truth for the audio Storage path shape
export const AUDIO_PATH_PATTERN =
    /^users\/([^/]+)\/groups\/([^/]+)\/boxes\/([^/]+)\/audios\/([^/]+)$/;

export function audioObjectPath(uid: string, groupId: string, boxId: string, vocabId: string): string {
    return `users/${uid}/groups/${groupId}/boxes/${boxId}/audios/${vocabId}.m4a`;
}

export function boxAudioPrefix(uid: string, groupId: string, boxId: string): string {
    return `users/${uid}/groups/${groupId}/boxes/${boxId}/audios/`;
}

export function groupPrefix(uid: string, groupId: string): string {
    return `users/${uid}/groups/${groupId}/boxes/`;
}
