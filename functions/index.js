/**
 * Cloud Functions for Food Ordering App
 * Firebase Functions v2 (2nd Gen)
 */

const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// CORS headers
const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

// Token validation helper
async function validateToken(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new Error("Missing or invalid Authorization header");
    }
    const idToken = authHeader.split("Bearer ")[1];
    return await admin.auth().verifyIdToken(idToken);
}

// Handle CORS preflight
function handleCors(req, res) {
    res.set(corsHeaders);
    if (req.method === "OPTIONS") {
        res.status(204).send("");
        return true;
    }
    return false;
}

// ==================== GET MENU ====================
exports.getMenu = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    if (req.method !== "GET") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
    }

    try {
        await validateToken(req);

        const menuSnapshot = await db.collection("menu").get();
        let menuItems = [];

        if (menuSnapshot.empty) {
            // Default menu items if Firestore is empty
            menuItems = [
                {
                    id: "1",
                    name: "Burger",
                    description: "Juicy beef burger with fresh vegetables",
                    price: 12.99,
                    imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
                },
                {
                    id: "2",
                    name: "Pizza",
                    description: "Classic Italian pizza with mozzarella and tomato sauce",
                    price: 15.99,
                    imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400",
                },
                {
                    id: "3",
                    name: "Sushi",
                    description: "Fresh salmon sushi rolls with wasabi and ginger",
                    price: 18.99,
                    imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400",
                },
                {
                    id: "4",
                    name: "Pasta",
                    description: "Creamy carbonara pasta with crispy bacon",
                    price: 14.99,
                    imageUrl: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400",
                },
                {
                    id: "5",
                    name: "Salad",
                    description: "Fresh garden salad with grilled chicken",
                    price: 10.99,
                    imageUrl: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400",
                },
                {
                    id: "6",
                    name: "Tacos",
                    description: "Authentic Mexican tacos with seasoned beef",
                    price: 11.99,
                    imageUrl: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400",
                },
            ];
        } else {
            menuSnapshot.forEach((doc) => {
                menuItems.push({ id: doc.id, ...doc.data() });
            });
        }

        res.status(200).json({ success: true, data: menuItems });
    } catch (error) {
        console.error("Error:", error.message);
        if (error.message.includes("Authorization")) {
            return res.status(401).json({ success: false, error: "Unauthorized: " + error.message });
        }
        res.status(500).json({ success: false, error: "Failed to fetch menu items" });
    }
});

// ==================== PLACE ORDER ====================
exports.placeOrder = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    if (req.method !== "POST") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
    }

    try {
        const user = await validateToken(req);
        const { items, total, encryptedAddress, encryptedPhone } = req.body;

        // Validate required fields
        if (!items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ success: false, error: "Invalid order: items array is required" });
        }

        if (typeof total !== "number" || total <= 0) {
            return res.status(400).json({ success: false, error: "Invalid order: valid total amount is required" });
        }

        // Create order document
        const order = {
            userId: user.uid,
            userEmail: user.email || "anonymous",
            items: items,
            total: total,
            encryptedAddress: encryptedAddress || null,
            encryptedPhone: encryptedPhone || null,
            status: "pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        const docRef = await db.collection("orders").add(order);

        console.log(`Order created: ${docRef.id} for user: ${user.uid}`);

        res.status(201).json({
            success: true,
            message: "Order placed successfully",
            data: { orderId: docRef.id, status: "pending" },
        });
    } catch (error) {
        console.error("Error:", error.message);
        if (error.message.includes("Authorization")) {
            return res.status(401).json({ success: false, error: "Unauthorized: " + error.message });
        }
        res.status(500).json({ success: false, error: "Failed to place order" });
    }
});

// ==================== GET ORDERS ====================
exports.getOrders = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    if (req.method !== "GET") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
    }

    try {
        const user = await validateToken(req);

        const ordersSnapshot = await db
            .collection("orders")
            .where("userId", "==", user.uid)
            .orderBy("createdAt", "desc")
            .limit(20)
            .get();

        const orders = [];
        ordersSnapshot.forEach((doc) => {
            const data = doc.data();
            orders.push({
                id: doc.id,
                ...data,
                createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
                updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
            });
        });

        res.status(200).json({ success: true, data: orders });
    } catch (error) {
        console.error("Error:", error.message);
        if (error.message.includes("Authorization")) {
            return res.status(401).json({ success: false, error: "Unauthorized: " + error.message });
        }
        res.status(500).json({ success: false, error: "Failed to fetch orders" });
    }
});

// ==================== HEALTH CHECK ====================
exports.healthCheck = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    res.status(200).json({
        success: true,
        message: "Server is running",
        timestamp: new Date().toISOString(),
    });
});
