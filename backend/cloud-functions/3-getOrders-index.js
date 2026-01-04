// ============================================
// FUNCTION 3: getOrders
// ============================================
// Service name: get-orders
// Entry point: getOrders
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
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
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

functions.http('getOrders', async (req, res) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        res.set(corsHeaders);
        return res.status(204).send('');
    }

    res.set(corsHeaders);

    // Only allow GET
    if (req.method !== 'GET') {
        return res.status(405).json({ success: false, error: 'Method not allowed' });
    }

    try {
        // Validate token
        const decodedToken = await validateToken(req);

        const ordersSnapshot = await db
            .collection('orders')
            .where('userId', '==', decodedToken.uid)
            .orderBy('createdAt', 'desc')
            .limit(20)
            .get();

        const orders = [];
        ordersSnapshot.forEach((doc) => {
            const data = doc.data();
            orders.push({
                id: doc.id,
                ...data,
                // Convert Firestore Timestamp to ISO string for JSON
                createdAt: data.createdAt ? data.createdAt.toDate().toISOString() : null,
                updatedAt: data.updatedAt ? data.updatedAt.toDate().toISOString() : null,
            });
        });

        res.status(200).json({ success: true, data: orders });
    } catch (error) {
        console.error('Error:', error.message);
        if (error.message.includes('Authorization')) {
            return res.status(401).json({ success: false, error: 'Unauthorized: ' + error.message });
        }
        res.status(500).json({ success: false, error: 'Failed to fetch orders' });
    }
});
