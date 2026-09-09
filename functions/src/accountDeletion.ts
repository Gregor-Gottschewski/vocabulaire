import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as functionsV1 from "firebase-functions/v1";
import {REGION} from "./counters";
import {userStoragePrefix} from "./storagePaths";

export const onUserDeleted = functionsV1
    .region(REGION)
    .auth.user()
    .onDelete(async (user) => {
        const uid = user.uid;
        const db = getFirestore();

        await Promise.all([
            getStorage().bucket().deleteFiles({prefix: userStoragePrefix(uid), force: true}),
            db.recursiveDelete(db.collection("users").doc(uid).collection("groups")),
        ]);

        const reservations = await db.collection("audioReservations").where("uid", "==", uid).get();
        await Promise.all(reservations.docs.map((d) => d.ref.delete()));

        const subscriptions = await db.collection("appleSubscriptions").where("uid", "==", uid).get();
        await Promise.all(
            subscriptions.docs.map((d) =>
                d.ref.delete().catch((e) => console.error(`onUserDeleted: failed to release appleSubscriptions/${d.id}`, e))
            )
        );

        await db.collection("rateLimits").doc(uid).delete().catch(() => undefined);
    });
