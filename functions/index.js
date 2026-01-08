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

// ==================== SEED MENU ====================
exports.seedMenu = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    // Optional: Add a secret key or check for admin auth to prevent public seeding
    // For now, we'll just allow it for demonstration purposes

    try {
        const menuItems = [
            // Burgers
            {
                id: "1",
                name: "Cheeseburger",
                description: "Juicy beef patty with cheese, lettuce, and tomato.",
                price: 8.99,
                imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200",
                category: "Burgers",
            },
            {
                id: "2",
                name: "Chicken Burger",
                description: "Grilled chicken with lettuce, tomato, and sauce.",
                price: 8.99,
                imageUrl: "https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=200",
                category: "Burgers",
            },
            // Pizza
            {
                id: "3",
                name: "Pepperoni",
                description: "Classic pepperoni pizza with mozzarella cheese.",
                price: 9.99,
                imageUrl: "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=200",
                category: "Pizza",
            },
            {
                id: "4",
                name: "Margherita",
                description: "Fresh tomato, mozzarella, and basil pizza.",
                price: 8.99,
                imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200",
                category: "Pizza",
            },
            // Drinks
            {
                id: "5",
                name: "Cola",
                description: "Refreshing cold cola drink.",
                price: 1.99,
                imageUrl: "https://images.unsplash.com/photo-1554866585-cd94860890b7?w=200",
                category: "Drinks",
            },
            {
                id: "6",
                name: "Orange Juice",
                description: "Freshly squeezed orange juice.",
                price: 2.49,
                imageUrl: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200",
                category: "Drinks",
            },
            // NEW ITEMS
            {
                id: "7",
                name: "Nasi Lemak",
                description: "Fragrant rice cooked in coconut milk and pandan leaf, served with sambal, anchovies, peanuts, and egg.",
                price: 12.90,
                imageUrl: "assets/images/nasi_lemak.png",
                category: "Asian Delight",
            },
            {
                id: "8",
                name: "Pizza",
                description: "Classic delicious pizza with rich cheese and toppings.",
                price: 15.90,
                imageUrl: "assets/images/pizza.png",
                category: "Pizza",
            },
            {
                id: "9",
                name: "Teh Ais",
                description: "Refreshing iced milk tea.",
                price: 3.50,
                imageUrl: "assets/images/teh_ais.png",
                category: "Drinks",
            },
            {
                id: "10",
                name: "Teh O Ais",
                description: "Refreshing iced black tea without milk.",
                price: 3.00,
                imageUrl: "assets/images/teh_o_ais.png",
                category: "Drinks",
            },
        ];

        const batch = db.batch();

        menuItems.forEach((item) => {
            const docRef = db.collection("menu").doc(item.id);
            batch.set(docRef, item);
        });

        await batch.commit();

        res.status(200).json({ success: true, message: "Menu seeded successfully", count: menuItems.length });
    } catch (error) {
        console.error("Error:", error.message);
        res.status(500).json({ success: false, error: "Failed to seed menu" });
    }
});

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
                // Burgers
                {
                    id: "1",
                    name: "Cheeseburger",
                    description: "Juicy beef patty with cheese, lettuce, and tomato.",
                    price: 8.99,
                    imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200",
                    category: "Burgers",
                },
                {
                    id: "2",
                    name: "Chicken Burger",
                    description: "Grilled chicken with lettuce, tomato, and sauce.",
                    price: 8.99,
                    imageUrl: "https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=200",
                    category: "Burgers",
                },
                // Pizza
                {
                    id: "3",
                    name: "Pepperoni",
                    description: "Classic pepperoni pizza with mozzarella cheese.",
                    price: 9.99,
                    imageUrl: "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=200",
                    category: "Pizza",
                },
                {
                    id: "4",
                    name: "Margherita",
                    description: "Fresh tomato, mozzarella, and basil pizza.",
                    price: 8.99,
                    imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200",
                    category: "Pizza",
                },
                // Drinks
                {
                    id: "5",
                    name: "Cola",
                    description: "Refreshing cold cola drink.",
                    price: 1.99,
                    imageUrl: "https://images.unsplash.com/photo-1554866585-cd94860890b7?w=200",
                    category: "Drinks",
                },
                {
                    id: "6",
                    name: "Orange Juice",
                    description: "Freshly squeezed orange juice.",
                    price: 2.49,
                    imageUrl: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200",
                    category: "Drinks",
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

        // Generate queue number using Firestore transaction
        const counterRef = db.collection("counters").doc("queue");
        let queueNumber;

        await db.runTransaction(async (transaction) => {
            const counterDoc = await transaction.get(counterRef);

            if (!counterDoc.exists) {
                // Initialize counter starting at 1
                queueNumber = 1;
                transaction.set(counterRef, { currentNumber: 1 });
            } else {
                // Increment counter
                queueNumber = (counterDoc.data().currentNumber || 0) + 1;
                transaction.update(counterRef, { currentNumber: queueNumber });
            }
        });

        // Create order document with queue number
        const order = {
            userId: user.uid,
            userEmail: user.email || "anonymous",
            queueNumber: queueNumber,
            items: items,
            total: total,
            encryptedAddress: encryptedAddress || null,
            encryptedPhone: encryptedPhone || null,
            status: "pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        const docRef = await db.collection("orders").add(order);

        console.log(`Order created: ${docRef.id} (Queue #${queueNumber}) for user: ${user.uid}`);

        res.status(201).json({
            success: true,
            message: "Order placed successfully",
            data: { orderId: docRef.id, queueNumber: queueNumber, status: "pending" },
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

// ==================== CREATE USER PROFILE ====================
exports.createUserProfile = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    if (req.method !== "POST") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
    }

    try {
        const user = await validateToken(req);
        const { name, email } = req.body;

        // Validate required fields
        if (!name || typeof name !== "string") {
            return res.status(400).json({ success: false, error: "Name is required" });
        }

        // Create or update user profile
        const userProfile = {
            uid: user.uid,
            name: name.trim(),
            email: email || user.email || "",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db.collection("users").doc(user.uid).set(userProfile, { merge: true });

        console.log(`User profile created/updated: ${user.uid}`);

        res.status(201).json({
            success: true,
            message: "User profile created successfully",
            data: { uid: user.uid, name: userProfile.name, email: userProfile.email },
        });
    } catch (error) {
        console.error("Error:", error.message);
        if (error.message.includes("Authorization")) {
            return res.status(401).json({ success: false, error: "Unauthorized: " + error.message });
        }
        res.status(500).json({ success: false, error: "Failed to create user profile" });
    }
});

// ==================== GET USER PROFILE ====================
exports.getUserProfile = onRequest({ region: "asia-southeast1" }, async (req, res) => {
    if (handleCors(req, res)) return;

    if (req.method !== "GET") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
    }

    try {
        const user = await validateToken(req);

        const userDoc = await db.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
            return res.status(404).json({
                success: false,
                error: "User profile not found",
            });
        }

        const userData = userDoc.data();
        const profile = {
            uid: user.uid,
            name: userData.name || "",
            email: userData.email || user.email || "",
            createdAt: userData.createdAt?.toDate?.()?.toISOString() || null,
        };

        res.status(200).json({ success: true, data: profile });
    } catch (error) {
        console.error("Error:", error.message);
        if (error.message.includes("Authorization")) {
            return res.status(401).json({ success: false, error: "Unauthorized: " + error.message });
        }
        res.status(500).json({ success: false, error: "Failed to get user profile" });
    }
});
