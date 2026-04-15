/**
 * ✅ Firebase Cloud Functions v2 (PRODUCTION READY)
 * PKT Call Taxi - Admin Panel Proxy & Notification System
 */

const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");

// Initialize Firebase Admin
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const API_KEY = "AIzaSyA9W48gjeH6NkyhKOqsPKLX-bWuE76JotI"; // ⚠️ Safety check: API restriction check panniko macha

/**
 * 🚖 AUTO NOTIFY DRIVER WHEN NEW REQUEST CREATED
 */
exports.notifyDriverOnNewRequest = onDocumentCreated(
  "approved_drivers/{driverId}/incoming_requests/{requestId}",
  async (event) => {
    try {
      const snapshot = event.data;
      if (!snapshot) return null;

      const { driverId, requestId } = event.params;
      const driverDoc = await admin.firestore().collection("approved_drivers").doc(driverId).get();
      const fcmToken = driverDoc.data()?.fcmToken;
      if (!fcmToken) return null;

      const requestData = snapshot.data();
      const message = {
        token: fcmToken,
        notification: {
          title: "🚖 New Ride Request",
          body: `${requestData.pickup_name} → ${requestData.drop_name}`,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "ride_request_channel",
            sound: "ftf_sound",
            defaultSound: false,
          },
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          requestId: requestId,
          type: "NEW_RIDE_REQUEST",
        },
      };

      return await admin.messaging().send(message);
    } catch (error) {
      console.error("🔥 Notification Error:", error);
      return null;
    }
  }
);

/**
 * 🧹 CLEANUP: REMOVE DRIVER FROM RTDB WHEN DELETED
 */
exports.onDriverDeleted = onDocumentDeleted(
  "approved_drivers/{driverId}",
  async (event) => {
    try {
      const driverId = event.params.driverId;
      await admin.database().ref(`active_drivers/${driverId}`).remove();
      return null;
    } catch (error) {
      console.error("Delete Error:", error);
      return null;
    }
  }
);

/**
 * 🗺️ 1. AUTOCOMPLETE PROXY (CORS FIXED)
 */
exports.mapsapi = onRequest({ region: "us-central1" }, (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(204).send("");

  const input = req.query.input;
  if (!input) return res.status(400).json({ error: "Input query missing" });

  const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(input)}&key=${API_KEY}&components=country:in`;

  axios.get(url)
    .then(response => res.json(response.data))
    .catch(error => res.status(500).json({ error: error.message }));
});

/**
 * 📍 2. PLACE DETAILS PROXY (Fixes the "Failed to fetch" error)
 */
exports.placeDetailsapi = onRequest({ region: "us-central1" }, (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(204).send("");

  const placeId = req.query.place_id;
  if (!placeId) return res.status(400).json({ error: "Place ID missing" });

  const url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&key=${API_KEY}`;

  axios.get(url)
    .then(response => res.json(response.data))
    .catch(error => res.status(500).json({ error: error.message }));
});

/**
 * 📏 3. DISTANCE MATRIX PROXY
 */
exports.distanceapi = onRequest({ region: "us-central1" }, (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(204).send("");

  const { origins, destinations } = req.query;
  if (!origins || !destinations) return res.status(400).json({ error: "Missing parameters" });

  const url = `https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origins}&destinations=${destinations}&key=${API_KEY}`;

  axios.get(url)
    .then(response => res.json(response.data))
    .catch(error => res.status(500).json({ error: error.message }));
});