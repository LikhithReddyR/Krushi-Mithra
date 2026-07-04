import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();


/**
 * Triggered when a new message is added to the 'messaging' collection.
 * This connects the Messaging Dashboard to the Flutter app by automatically
 * broadcasting any message created there.
 */
export const onMessagingCreated = onDocumentCreated("messaging/{messageId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const data = snapshot.data();
  const title = data.title || "Krushi Mithra Update";
  const body = data.body || "You have a new message from the farm.";
  const type = data.type || "info";

  console.log(`🚀 New campaign detected: ${title}. Broadcasting to all users...`);

  const payload = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      type: type,
    },
    topic: "daily_alerts",
  };

  try {
    const response = await admin.messaging().send(payload);
    console.log("✅ Successfully broadcasted dashboard message:", response);
    
    // Also save to a global history so it shows in everyone's notification screen
    await admin.firestore().collection('global_notifications').add({
      title: title,
      body: body,
      type: type,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      broadcasted: true
    });
  } catch (error) {
    console.error("❌ Error broadcasting dashboard message:", error);
  }
});
