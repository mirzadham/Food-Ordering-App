/**
 * Secure Food Ordering Backend
 * Express server with Firebase Admin SDK for Google Cloud Run
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// In production, Cloud Run will use the default service account
// For local development, you can use a service account key file
if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
} else {
  // Initialize without credentials for demo/local testing
  // In production, always use proper credentials
  admin.initializeApp({
    projectId: 'food-ordering-demo',
  });
}

const db = admin.firestore();
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(bodyParser.json());

/**
 * Token Validation Middleware
 * Verifies Firebase ID Token from Authorization header
 */
const validateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized: Missing or invalid Authorization header',
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    
    try {
      // Verify the ID token using Firebase Admin SDK
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      req.user = decodedToken;
      next();
    } catch (error) {
      console.error('Token verification failed:', error.message);
      return res.status(401).json({
        success: false,
        error: 'Unauthorized: Invalid or expired token',
      });
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error during authentication',
    });
  }
};

/**
 * GET /menu
 * Returns list of food items from Firestore
 * Protected by token validation
 */
app.get('/menu', validateToken, async (req, res) => {
  try {
    // Try to get menu from Firestore
    const menuSnapshot = await db.collection('menu').get();
    
    let menuItems = [];
    
    if (menuSnapshot.empty) {
      // Return default menu items if Firestore is empty
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

    res.status(200).json({
      success: true,
      data: menuItems,
    });
  } catch (error) {
    console.error('Error fetching menu:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch menu items',
    });
  }
});

/**
 * POST /placeOrder
 * Accepts encrypted order payload and saves to Firestore
 * Protected by token validation
 */
app.post('/placeOrder', validateToken, async (req, res) => {
  try {
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
      userId: req.user.uid,
      userEmail: req.user.email || 'anonymous',
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

    console.log(`Order created: ${docRef.id} for user: ${req.user.uid}`);

    res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      data: {
        orderId: docRef.id,
        status: 'pending',
      },
    });
  } catch (error) {
    console.error('Error placing order:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to place order',
    });
  }
});

/**
 * GET /orders
 * Returns orders for the authenticated user
 * Protected by token validation
 */
app.get('/orders', validateToken, async (req, res) => {
  try {
    const ordersSnapshot = await db
      .collection('orders')
      .where('userId', '==', req.user.uid)
      .orderBy('createdAt', 'desc')
      .limit(20)
      .get();

    const orders = [];
    ordersSnapshot.forEach((doc) => {
      orders.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).json({
      success: true,
      data: orders,
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch orders',
    });
  }
});

/**
 * Health check endpoint (no auth required)
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Food Ordering Backend running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`📍 Menu endpoint: http://localhost:${PORT}/menu`);
  console.log(`📍 Place order: http://localhost:${PORT}/placeOrder`);
});

module.exports = app;
