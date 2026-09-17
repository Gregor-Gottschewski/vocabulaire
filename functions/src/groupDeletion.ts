import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {REGION} from "./counters";
import {groupPrefix} from "./storagePaths";

function validateGroupId(raw: unknown): string {
    const id = typeof raw === "string" ? raw.trim() : "";
    if (id.length === 0 || id.includes("/")) {
        throw new HttpsError("invalid-argument", "Invalid group id.");
    }
    return id;
}

export const hardDeleteGroup = onCall(
    {region: REGION, enforceAppCheck: true},
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Login required.");
        }
        const uid = request.auth.uid;
        const groupId = validateGroupId(request.data?.groupId);

        const groupRef = getFirestore()
            .collection("users")
            .doc(uid)
            .collection("groups")
            .doc(groupId);

        const snap = await groupRef.get();
        if (!snap.exists) return;

        await Promise.all([
            getStorage().bucket().deleteFiles({prefix: groupPrefix(uid, groupId), force: true}),
            getFirestore().recursiveDelete(groupRef),
        ]);
    }
);
