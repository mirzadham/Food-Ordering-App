// ============================================
// FUNCTION 1: getMenu
// ============================================
// Service name: get-menu
// Entry point: getMenu
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

functions.http('getMenu', async (req, res) => {
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
        await validateToken(req);

        // Get menu from Firestore
        const menuSnapshot = await db.collection('menu').get();

        let menuItems = [];

        if (menuSnapshot.empty) {
            // Default menu items if Firestore is empty
            menuItems = [
                {
                    id: '1',
                    name: 'Burger',
                    description: 'Juicy beef burger with fresh vegetables',
                    price: 12.99,
                    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
                },
                {
                    id: '2',
                    name: 'Pizza',
                    description: 'Classic Italian pizza with mozzarella and tomato sauce',
                    price: 15.99,
                    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
                },
                {
                    id: '3',
                    name: 'Sushi',
                    description: 'Fresh salmon sushi rolls with wasabi and ginger',
                    price: 18.99,
                    imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
                },
                {
                    id: '4',
                    name: 'Pasta',
                    description: 'Creamy carbonara pasta with crispy bacon',
                    price: 14.99,
                    imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400',
                },
                {
                    id: '5',
                    name: 'Salad',
                    description: 'Fresh garden salad with grilled chicken',
                    price: 10.99,
                    imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
                },
                {
                    id: '6',
                    name: 'Tacos',
                    description: 'Authentic Mexican tacos with seasoned beef',
                    price: 11.99,
                    imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
                },
            ];
        } else {
            menuSnapshot.forEach((doc) => {
                menuItems.push({ id: doc.id, ...doc.data() });
            });
        }

        res.status(200).json({ success: true, data: menuItems });
    } catch (error) {
        console.error('Error:', error.message);
        if (error.message.includes('Authorization')) {
            return res.status(401).json({ success: false, error: 'Unauthorized: ' + error.message });
        }
        res.status(500).json({ success: false, error: 'Failed to fetch menu items' });
    }
});
