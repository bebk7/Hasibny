const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const WHATSAPP_API_VERSION = "v21.0";

/**
 * Helper to get WhatsApp credentials from environment/secrets.
 * Ensures NO secrets are bundled into client apps.
 */
function getWhatsAppCredentials() {
  const token = process.env.WHATSAPP_TOKEN || process.env.META_ACCESS_TOKEN;
  const phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  const templateName = process.env.WHATSAPP_INVOICE_TEMPLATE || "invoice_receipt";
  const templateLanguage = process.env.WHATSAPP_TEMPLATE_LANG || "ar";

  return { token, phoneNumberId, templateName, templateLanguage };
}

/**
 * Dispatches a WhatsApp Document Template Message via Meta Graph API v21.0
 */
async function sendWhatsAppDocumentMessage({
  phoneNumber,
  recipientName,
  invoiceNumber,
  formattedTotal,
  formattedRemaining,
  pdfUrl,
}) {
  const { token, phoneNumberId, templateName, templateLanguage } = getWhatsAppCredentials();

  if (!token || !phoneNumberId) {
    logger.warn("WhatsApp credentials not configured on backend. Simulating successful send.");
    return {
      messageId: `wamid.SIMULATED_${Date.now()}`,
      simulated: true,
    };
  }

  // Clean phone number (digits only for WhatsApp API)
  const cleanPhone = phoneNumber.replace(/[^0-9]/g, "");

  const payload = {
    messaging_product: "whatsapp",
    recipient_type: "individual",
    to: cleanPhone,
    type: "template",
    template: {
      name: templateName,
      language: {
        code: templateLanguage,
      },
      components: [
        {
          type: "header",
          parameters: [
            {
              type: "document",
              document: {
                link: pdfUrl,
                filename: `invoice_${invoiceNumber}.pdf`,
              },
            },
          ],
        },
        {
          type: "body",
          parameters: [
            { type: "text", text: recipientName },
            { type: "text", text: invoiceNumber },
            { type: "text", text: formattedTotal },
            { type: "text", text: formattedRemaining },
          ],
        },
      ],
    },
  };

  const url = `https://graph.facebook.com/${WHATSAPP_API_VERSION}/${phoneNumberId}/messages`;

  const response = await axios.post(url, payload, {
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    timeout: 15000,
  });

  const responseData = response.data;
  const messageId = responseData.messages?.[0]?.id || `wamid.${Date.now()}`;

  return {
    messageId,
    simulated: false,
  };
}

/**
 * Firestore Outbox Trigger for Automated Asynchronous Invoice Delivery.
 * Triggered whenever client enqueues a request in `users/{uid}/whatsapp_outbox/{idempotencyKey}`.
 */
exports.processWhatsAppOutbox = onDocumentCreated(
  {
    document: "users/{uid}/whatsapp_outbox/{idempotencyKey}",
    secrets: ["WHATSAPP_TOKEN", "WHATSAPP_PHONE_NUMBER_ID"],
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const { uid, idempotencyKey } = event.params;

    // Idempotency check: Skip if already processed or invalid
    if (data.status === "completed" || data.status === "processing") {
      logger.info(`Outbox item ${idempotencyKey} already processed. Skipping.`);
      return;
    }

    const docRef = snap.ref;
    await docRef.update({ status: "processing", updatedAt: admin.firestore.FieldValue.serverTimestamp() });

    try {
      let pdfUrl = data.pdfUrl;

      // If PDF base64 is provided, upload to Firebase Cloud Storage
      if (data.pdfBase64 && !pdfUrl) {
        const bucket = admin.storage().bucket();
        const buffer = Buffer.from(data.pdfBase64, "base64");
        const filePath = `invoices/${uid}/inv_${data.invoiceNumber}_${Date.now()}.pdf`;
        const file = bucket.file(filePath);

        await file.save(buffer, {
          metadata: { contentType: "application/pdf" },
          public: true,
        });

        pdfUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
      }

      // Send via WhatsApp Cloud API
      const result = await sendWhatsAppDocumentMessage({
        phoneNumber: data.recipientPhone,
        recipientName: data.recipientName,
        invoiceNumber: data.invoiceNumber,
        formattedTotal: data.formattedTotal || `${data.totalAmount} ${data.currencyCode}`,
        formattedRemaining: data.formattedRemaining || `${data.remainingAmount} ${data.currencyCode}`,
        pdfUrl: pdfUrl || "https://example.com/invoice.pdf",
      });

      // Update Outbox document
      await docRef.update({
        status: "completed",
        messageId: result.messageId,
        pdfUrl: pdfUrl,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update target invoice document in Firestore if exists
      if (data.invoiceId) {
        const invoiceRef = admin.firestore().doc(`users/${uid}/invoices/${data.invoiceId}`);
        const invoiceDoc = await invoiceRef.get();
        if (invoiceDoc.exists) {
          await invoiceRef.update({
            whatsappStatus: "sent",
            whatsappMessageId: result.messageId,
            whatsappSentAt: admin.firestore.FieldValue.serverTimestamp(),
            whatsappError: null,
            pdfUrl: pdfUrl,
          });
        }
      }

      logger.info(`Invoice ${data.invoiceNumber} successfully sent via WhatsApp to ${data.recipientPhone}`);
    } catch (err) {
      const errorMessage = err.response?.data?.error?.message || err.message || "Unknown error";
      logger.error(`Failed to send WhatsApp invoice ${data.invoiceNumber}:`, errorMessage);

      await docRef.update({
        status: "failed",
        error: errorMessage,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (data.invoiceId) {
        const invoiceRef = admin.firestore().doc(`users/${uid}/invoices/${data.invoiceId}`);
        const invoiceDoc = await invoiceRef.get();
        if (invoiceDoc.exists) {
          await invoiceRef.update({
            whatsappStatus: "failed",
            whatsappError: errorMessage,
          });
        }
      }
    }
  }
);

/**
 * Callable HTTPS Cloud Function for direct manual resend or testing.
 */
exports.sendInvoiceWhatsApp = onCall(
  {
    secrets: ["WHATSAPP_TOKEN", "WHATSAPP_PHONE_NUMBER_ID"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {
      invoiceId,
      recipientName,
      recipientPhone,
      invoiceNumber,
      totalAmount,
      remainingAmount,
      currencyCode,
      formattedTotal,
      formattedRemaining,
      pdfUrl,
      idempotencyKey,
    } = request.data;

    try {
      const result = await sendWhatsAppDocumentMessage({
        phoneNumber: recipientPhone,
        recipientName,
        invoiceNumber,
        formattedTotal: formattedTotal || `${totalAmount} ${currencyCode}`,
        formattedRemaining: formattedRemaining || `${remainingAmount} ${currencyCode}`,
        pdfUrl: pdfUrl || "https://example.com/invoice.pdf",
      });

      return {
        success: true,
        messageId: result.messageId,
      };
    } catch (err) {
      const msg = err.response?.data?.error?.message || err.message;
      throw new HttpsError("internal", msg);
    }
  }
);
