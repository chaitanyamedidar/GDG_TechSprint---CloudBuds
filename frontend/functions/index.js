const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const { Client } = require("pg");
const { VertexAI } = require('@google-cloud/vertexai');
const axios = require('axios');
const {GoogleAuth} = require('google-auth-library');

admin.initializeApp();

// --- CONFIGURATION ---
const dbConfig = {
  user: "postgres",
  password: "sxLVaPCC;xG_-2}}",
  database: "postgres",
  host: "35.226.128.196",
  port: 5432,
  ssl: { rejectUnauthorized: false },
};

// --- NEW: Cloud Run Integration ---
const CLOUD_RUN_URL = "https://safelabs-712078236186.asia-south1.run.app"; // <-- ✅  URL Updated
let auth;
let client;

async function getAuthenticatedClient() {
  if (!auth) {
    auth = new GoogleAuth();
  }
  if (!client) {
    client = await auth.getIdTokenClient(CLOUD_RUN_URL);
  }
  return client;
}

/**
 * Builds the strict JSON prompt for the XAI explanation.
 */
function buildXaiPrompt(riskJson) {
  return `Return ONLY valid JSON. No markdown. No explanations. No comments.

Schema:
{
  "summary": {
    "overall_risk_level": "LOW | MEDIUM | HIGH | CRITICAL",
    "primary_risk": "string",
    "confidence": "float"
  },
  "key_contributors": [
    {
      "feature": "string",
      "impact": "LOW | MEDIUM | HIGH",
      "value": "float"
    }
  ],
  "decision_rationale": "string",
  "recommended_action_justification": "string",
  "urgency_level": "LOW | MEDIUM | HIGH | CRITICAL"
}

Input:
${JSON.stringify(riskJson)}`;
}

/**
 * Builds the strict JSON prompt for the counterfactual explanation.
 */
function buildCounterfactualPrompt(riskJson) {
  return `Return ONLY valid JSON. No markdown. No explanations. No comments.

Schema:
{
  "current_risk_level": "LOW | MEDIUM | HIGH | CRITICAL",
  "counterfactuals": [
    {
      "feature": "string",
      "current_value": "float",
      "suggested_value": "float",
      "expected_risk_change": "string"
    }
  ],
  "summary": "string"
}

Input:
${JSON.stringify(riskJson)}`;
}

/**
 * Safely parses a JSON string that might be wrapped in markdown.
 */
function safeJsonParse(text) {
  try {
    return JSON.parse(text);
  } catch (e) {
    const startIndex = text.indexOf('{');
    const endIndex = text.lastIndexOf('}') + 1;
    if (startIndex !== -1 && endIndex !== -1) {
      const jsonString = text.substring(startIndex, endIndex);
      return JSON.parse(jsonString);
    }
    throw new Error("Gemini returned invalid JSON and it could not be recovered.");
  }
}

/**
 * The main Cloud Function to analyze risk and generate explanations.
 */
exports.analyzeRisk = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be logged in.");
  }
  
  if (!CLOUD_RUN_URL || CLOUD_RUN_URL === "YOUR_CLOUD_RUN_SERVICE_URL_HERE") {
      throw new functions.https.HttpsError("internal", "Cloud Run service URL is not configured.");
  }

  let riskOutput;
  try {
    // 1. Get authenticated client and call the Cloud Run service
    const authenticatedClient = await getAuthenticatedClient();
    const response = await authenticatedClient.post(`/analyze`, data); // Make POST request
    riskOutput = response.data;

  } catch (error) {
    console.error("Error calling Cloud Run service:", error.message);
    throw new functions.https.HttpsError("internal", "Failed to compute risk score from the external service.");
  }

  // 2. Initialize Gemini Client
  const vertex_ai = new VertexAI({ project: 'woven-phoenix-447410-h8', location: 'asia-south1' });
  const generativeModel = vertex_ai.getGenerativeModel({ model: 'gemini-1.5-flash' });

  try {
    // 3. Generate XAI explanation
    const xaiPrompt = buildXaiPrompt(riskOutput);
    const xaiResponse = await generativeModel.generateContent(xaiPrompt);
    const xaiExplanation = safeJsonParse(xaiResponse.response.candidates[0].content.parts[0].text);

    // 4. Generate Counterfactual Explanation
    const cfPrompt = buildCounterfactualPrompt(riskOutput);
    const cfResponse = await generativeModel.generateContent(cfPrompt);
    const counterfactualExplanation = safeJsonParse(cfResponse.response.candidates[0].content.parts[0].text);

    // 5. Return only user-facing data (riskOutput already contains the scores)
    return {
      ...riskOutput, 
      xai_explanation: xaiExplanation,
      counterfactual_explanation: counterfactualExplanation,
    };

  } catch (error) {
    console.error("Error during AI analysis:", error);
    throw new functions.https.HttpsError("internal", "An error occurred while analyzing the risk data.", error.message);
  }
});

// --- EXISTING FUNCTIONS (No changes needed) ---

exports.generateChatResponse = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be logged in to use the AI chat.");
  }
  const { prompt } = data;
  if (!prompt) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with a 'prompt'.");
  }

  const vertex_ai = new VertexAI({ project: 'woven-phoenix-447410-h8', location: 'asia-south1' });
  const generativeModel = vertex_ai.getGenerativeModel({ model: 'gemini-1.5-flash' });

  try {
    const resp = await generativeModel.generateContent(prompt);
    const content = resp.response.candidates[0].content.parts[0].text;
    return { response: content };
  } catch (error) {
    console.error("Error generating chat response:", error);
    throw new functions.https.HttpsError("internal", "An error occurred while generating the AI response.");
  }
});

exports.verifyDeanAccess = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }
  // Allow all authenticated users for now
  return { status: "success", message: "Access granted." };
});

exports.getDashboardData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }

  return {
    user: {
      name: context.auth.token.name || "Dean User",
      email: context.auth.token.email,
      role: "Dean of Engineering",
      photoUrl: context.auth.token.picture || ""
    }
  };
});

