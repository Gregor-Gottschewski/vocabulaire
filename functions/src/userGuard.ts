import {getAuth} from "firebase-admin/auth";

export async function userExists(uid: string): Promise<boolean> {
    try {
        await getAuth().getUser(uid);
        return true;
    } catch (err) {
        if ((err as {code?: string}).code === "auth/user-not-found") return false;
        throw err;
    }
}
