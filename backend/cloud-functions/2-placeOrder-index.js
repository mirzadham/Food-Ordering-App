// ============================================
// FUNCTION 2: placeOrder
// ============================================
// Service name: place-order
// Entry point: placeOrder
// Runtime: Node.js 20
// Authentication: Allow unauthenticated invocations
// ============================================

// --- index.js ---
const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();

// CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// Token validation helper
async function validateToken(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        throw new Error('Missing or invalid Authorization header');
    }
    const idToken = authHeader.split('Bearer ')[1];
    return await admin.auth().verifyIdToken(idToken);
}

functions.http('placeOrder', async (req, res) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        res.set(corsHeaders);
        return res.status(204).send('');
    }

    res.set(corsHeaders);

    // Only allow POST
    if (req.method !== 'POST') {
        return res.status(405).json({ success: false, error: 'Method not allowed' });
    }

    try {
        // Validate token
        const decodedToken = await validateToken(req);

        const { items, total, encryptedAddress, encryptedPhone } = req.body;

        // Validate required fields
        if (!items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid order: items array is required',
            });
        }

        if (typeof total !== 'number' || total <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid order: valid total amount is required',
            });
        }

        // Create order document
        const order = {
            userId: decodedToken.uid,
            userEmail: decodedToken.email || 'anonymous',
            items: items,
            total: total,
            encryptedAddress: encryptedAddress || null,
            encryptedPhone: encryptedPhone || null,
            status: 'pending',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        const docRef = await db.collection('orders').add(order);

        console.log(`Order created: ${docRef.id} for user: ${decodedToken.uid}`);

        res.status(201).json({
            success: true,
            message: 'Order placed successfully',
            data: {
                orderId: docRef.id,
                status: 'pending',
            },
        });
    } catch (error) {
        console.error('Error:', error.message);
        if (error.message.includes('Authorization')) {
            return res.status(401).json({ success: false, error: 'Unauthorized: ' + error.message });
        }
        res.status(500).json({ success: false, error: 'Failed to place order' });
    }
});
