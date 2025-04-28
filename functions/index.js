const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const crypto = require("crypto");

admin.initializeApp();

const CASHFREE_APP_ID = functions.config().cashfree.app_id || "TEST10548850e9cc2ac5290bec219fbe05884501";
const CASHFREE_SECRET_KEY = functions.config().cashfree.secret_key || "cfsk_ma_test_cfb6d9cd5b765c7b6ee27ae1cb5a9391_6ff2275c";
const CASHFREE_API_URL = "https://sandbox.cashfree.com/pg/orders";

// Generate Cashfree Token Function
exports.generateCashfreeToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  }

  const orderId = data.orderId;
  const orderAmount = data.orderAmount;

  try {
    const response = await axios.post(
      CASHFREE_API_URL,
      {
        order_id: orderId,
        order_amount: orderAmount,
        order_currency: "INR",
        customer_details: {
          customer_id: context.auth.uid,
          customer_email: context.auth.token.email || "test@upi",
          customer_phone: context.auth.token.phone_number || "1234567890",
        },
      },
      {
        headers: {
          "x-client-id": CASHFREE_APP_ID,
          "x-client-secret": CASHFREE_SECRET_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    let qrCode = "";
    if (
      response.data &&
      response.data.payments &&
      response.data.payments.upi &&
      response.data.payments.upi.qrcode
    ) {
      qrCode = response.data.payments.upi.qrcode;
    }

    return {
      token: response.data.cf_order_id || "test_token",
      paymentLink:
        response.data.payment_link ||
        `https://sandbox.cashfree.com/pg/orders/${orderId}`,
      qrCodeUrl: qrCode || `https://sandbox.cashfree.com/pg/qr/${orderId}`,
    };
  } catch (error) {
    console.error("Cashfree token generation error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Cashfree Webhook Function
exports.cashfreeWebhook = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();

  try {
    const payload = JSON.stringify(req.body);
    const signature = req.headers["x-webhook-signature"];

    const expectedSignature = crypto
      .createHmac("sha256", CASHFREE_SECRET_KEY)
      .update(payload)
      .digest("hex");

    if (signature !== expectedSignature) {
      console.log("Invalid signature");
      return res.status(401).send({ status: "INVALID_SIGNATURE" });
    }

    const orderId = req.body.data.order_id;
    const transactionStatus = req.body.data.transaction_status;

    await db.collection("payments").doc(orderId).update({
      status: transactionStatus === "SUCCESS" ? "completed" : transactionStatus.toLowerCase(),
      webhookTimestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (transactionStatus === "SUCCESS") {
      const paymentDoc = await db.collection("payments").doc(orderId).get();
      const paymentData = paymentDoc.data();

      if (paymentData && paymentData.userId) {
        await db.collection("orders").add({
          userId: paymentData.userId,
          orderId: orderId,
          amount: paymentData.amount,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          status: "confirmed",
        });
      }
    }

    res.status(200).send({ status: "OK" });
  } catch (error) {
    console.error("Webhook error:", error);
    res.status(500).send({ error: error.message });
  }
});
