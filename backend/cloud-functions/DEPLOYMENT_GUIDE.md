# Cloud Functions Deployment Guide

## Overview
Deploy 4 separate Cloud Functions via Google Cloud Console UI.

## Functions to Deploy

| # | Service Name | Entry Point | Files |
|---|-------------|-------------|-------|
| 1 | `get-menu` | `getMenu` | `1-getMenu-index.js`, `1-getMenu-package.json` |
| 2 | `place-order` | `placeOrder` | `2-placeOrder-index.js`, `2-placeOrder-package.json` |
| 3 | `get-orders` | `getOrders` | `3-getOrders-index.js`, `3-getOrders-package.json` |
| 4 | `health-check` | `healthCheck` | `4-healthCheck-index.js`, `4-healthCheck-package.json` |

---

## Step-by-Step Deployment

### For EACH function, repeat these steps:

1. **Go to Cloud Console**
   - Open: https://console.cloud.google.com/run/overview?project=sse3401-483210

2. **Click "Write a function"**

3. **Configure Service Settings**
   - **Service name**: Use lowercase with hyphens (e.g., `get-menu`)
   - **Region**: `us-central1` (or your preferred region)
   - **Runtime**: `Node.js 20`
   - **Authentication**: `Allow unauthenticated invocations`
   - **Entry point**: Use camelCase function name (e.g., `getMenu`)

4. **Paste the Code**
   - **index.js**: Copy content from the corresponding `*-index.js` file
   - **package.json**: Copy content from the corresponding `*-package.json` file

5. **Click "Create" / "Deploy"**

6. **Copy the URL** after deployment completes

---

## Expected URLs After Deployment

After deploying all 4 functions, you'll have URLs like:

```
https://get-menu-HASH-uc.a.run.app
https://place-order-HASH-uc.a.run.app
https://get-orders-HASH-uc.a.run.app
https://health-check-HASH-uc.a.run.app
```

(The exact URL format will be shown after each deployment)

---

## Update Flutter Frontend

After deployment, update `lib/services/api_service.dart` with the actual URLs you receive.

---

## Testing

Test the health-check endpoint first (no auth required):

```bash
curl https://health-check-HASH-uc.a.run.app
```

Expected response:
```json
{"success":true,"message":"Server is running","timestamp":"2026-01-04T..."}
```
