"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMessagingCreated = exports.sendDailyAgriAlert = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios_1 = require("axios");
admin.initializeApp();
exports.sendDailyAgriAlert = (0, scheduler_1.onSchedule)({
    schedule: "0 20 * * *", // Runs every single day at 8:00 PM (20:00)
    timeZone: "Asia/Kolkata",
    memory: "256MiB",
}, async (event) => {
    try {
        // 1. Fetch live agricultural news/schemes using a public RSS-to-JSON API
        // We are fetching the highly reliable Economic Times India Agriculture feed without needing an API key!
        const API_URL = "https://api.rss2json.com/v1/api.json?rss_url=https://economictimes.indiatimes.com/news/economy/agriculture/rssfeeds/21468427.cms";
        const response = await axios_1.default.get(API_URL);
        const items = response.data.items;
        const FALLBACK_SCHEMES = [
            {
                title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
                description: "Ensure your crops against natural calamities! The season enrollment window is closing soon. Check with your local CSC."
            },
            {
                title: "PM-Kisan Samman Nidhi",
                description: "The next installment of ₹2000 under PM-Kisan will be released shortly. Ensure your e-KYC is complete on the portal."
            },
            {
                title: "Soil Health Card Scheme",
                description: "Test your soil! Knowing your soil's exact nutrient profile saves fertilizer costs and increases yield."
            }
        ];
        let latestNews;
        if (!items || items.length === 0) {
            console.log("⚠️ Live news feed is empty today. Using a highly useful fallback scheme...");
            latestNews = FALLBACK_SCHEMES[Math.floor(Math.random() * FALLBACK_SCHEMES.length)];
        }
        else {
            // 2. Pick the absolute latest news/scheme article
            latestNews = items[0];
        }
        // Clean up the description (often contains HTML tags from RSS)
        const cleanBody = latestNews.description.replace(/<[^>]*>?/gm, "").substring(0, 140) + "...";
        // 3. Prepare the notification payload
        const payload = {
            notification: {
                title: `📰 Daily Agri Alert: ${latestNews.title.substring(0, 40)}...`,
                body: cleanBody,
            },
            topic: "daily_alerts", // Broadcasts to EVERY user subscribed to this topic
        };
        // 4. Send the message via Firebase Admin
        const fcmResponse = await admin.messaging().send(payload);
        console.log("Successfully broadcasted live API alert:", fcmResponse);
    }
    catch (error) {
        console.error("Error fetching API or broadcasting alert:", error);
    }
});
/**
 * Triggered when a new message is added to the 'messaging' collection.
 * This connects the Messaging Dashboard to the Flutter app by automatically
 * broadcasting any message created there.
 */
exports.onMessagingCreated = (0, firestore_1.onDocumentCreated)("messaging/{messageId}", async (event) => {
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
    }
    catch (error) {
        console.error("❌ Error broadcasting dashboard message:", error);
    }
});
//# sourceMappingURL=index.js.map