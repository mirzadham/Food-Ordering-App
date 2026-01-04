// ============================================
// FUNCTION 4: healthCheck
// ============================================
// Service name: health-check
// Entry point: healthCheck
// Runtime: Node.js 20
// Authentication: Allow unauthenticated invocations
// ============================================

// --- index.js ---
const functions = require('@google-cloud/functions-framework');

// CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
};

functions.http('healthCheck', (req, res) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        res.set(corsHeaders);
        return res.status(204).send('');
    }

    res.set(corsHeaders);

    res.status(200).json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString(),
    });
});
