import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendDeadlines = functions.firestore
  .document("deadlines/{deadlinesId}")
  .onCreate(async (snapshot) => {
    const notification = snapshot.data();

    const querySnapshot = await db
      .collection("users")
      .where("id", "in", notification.members)
      .get();

    const tokens = querySnapshot.docs.map((snap) => snap.data().token);

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: `${notification.title}`,
        body: `${notification.desc}`,
        icon: "your-icon-url",
        click_action: "FLUTTER_NOTIFICATION_CLICK", // required only for onResume or onLaunch callbacks
        priority: "high",
      },
    };

    return fcm.sendToDevice(tokens, payload);
  });

export const sendNotices = functions.firestore
  .document("posts/{postsId}")
  .onCreate(async (snapshot) => {
    const notification = snapshot.data();

    if (notification.type == "notice") {
      await db
        .collection("courses")
        .where("id", "==", notification.course)
        .onSnapshot((snaps) => {
          snaps.docs.forEach(async (element) => {
            const querySnapshot = await db
              .collection("users")
              .where("id", "in", element.data().members)
              .get();

            const queryGetContent = await db
              .collection("contents")
              .where("post", "==", notification.id)
              .get();

            const tokens = querySnapshot.docs.map((snap) => snap.data().token);

            const title = queryGetContent.docs[0].data().title;
            const desc = queryGetContent.docs[0].data().desc;

            const payload: admin.messaging.MessagingPayload = {
              notification: {
                title: `${title}`,
                body: `${desc}`,
                icon: "your-icon-url",
                click_action: "FLUTTER_NOTIFICATION_CLICK", // required only for onResume or onLaunch callbacks
                priority: "high",
              },
            };

            return fcm.sendToDevice(tokens, payload);
          });
        });
    }
  });
