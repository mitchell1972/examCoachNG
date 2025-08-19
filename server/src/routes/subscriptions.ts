import { Router, Request, Response } from 'express';
import { google } from 'googleapis';
import jwt from 'jsonwebtoken';
import { query } from '../config/database';
import { Logger } from '../utils/logger';

const router = Router();

// Google Play API configuration
// You'll need to download a service account JSON key from Google Cloud Console
// and set the path in your environment variables
const GOOGLE_SERVICE_ACCOUNT_KEY = process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH;
const PACKAGE_NAME = process.env.ANDROID_PACKAGE_NAME || 'com.example.examcoach_app';

// Apple App Store configuration for iOS (if needed later)
const APPLE_SHARED_SECRET = process.env.APPLE_SHARED_SECRET;
const APPLE_SANDBOX = process.env.NODE_ENV !== 'production';

// Initialize Google Play API client
let androidPublisher: any = null;

if (GOOGLE_SERVICE_ACCOUNT_KEY) {
  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: GOOGLE_SERVICE_ACCOUNT_KEY,
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });

    androidPublisher = google.androidpublisher({
      version: 'v3',
      auth,
    });
  } catch (error) {
    Logger.error('Failed to initialize Google Play API client:', error);
  }
}

// Subscription product IDs
const SUBSCRIPTION_PRODUCTS = {
  BASIC_MONTHLY: 'examcoach_basic_monthly',
  PREMIUM_MONTHLY: 'examcoach_premium_monthly',
  PREMIUM_ANNUAL: 'examcoach_premium_annual',
};

// Subscription features by tier
const SUBSCRIPTION_FEATURES = {
  [SUBSCRIPTION_PRODUCTS.BASIC_MONTHLY]: [
    'practice_questions',
    'basic_explanations',
    'progress_tracking',
  ],
  [SUBSCRIPTION_PRODUCTS.PREMIUM_MONTHLY]: [
    'practice_questions',
    'detailed_explanations',
    'progress_tracking',
    'mock_exams',
    'performance_analytics',
    'offline_mode',
    'priority_support',
  ],
  [SUBSCRIPTION_PRODUCTS.PREMIUM_ANNUAL]: [
    'practice_questions',
    'detailed_explanations',
    'progress_tracking',
    'mock_exams',
    'performance_analytics',
    'offline_mode',
    'priority_support',
    'early_access',
  ],
};

/**
 * Verify Google Play receipt
 */
async function verifyGooglePlayReceipt(
  productId: string,
  purchaseToken: string
): Promise<any> {
  if (!androidPublisher) {
    throw new Error('Google Play API client not initialized');
  }

  try {
    const response = await androidPublisher.purchases.subscriptions.get({
      packageName: PACKAGE_NAME,
      subscriptionId: productId,
      token: purchaseToken,
    });

    return response.data;
  } catch (error: any) {
    Logger.error('Google Play receipt verification failed:', error);
    throw new Error(`Receipt verification failed: ${error.message}`);
  }
}

/**
 * Verify Apple App Store receipt (for future iOS support)
 */
async function verifyAppleReceipt(receiptData: string): Promise<any> {
  const verifyUrl = APPLE_SANDBOX
    ? 'https://sandbox.itunes.apple.com/verifyReceipt'
    : 'https://buy.itunes.apple.com/verifyReceipt';

  const requestBody = {
    'receipt-data': receiptData,
    password: APPLE_SHARED_SECRET,
  };

  try {
          const response = await fetch(verifyUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      });

      const data = await response.json() as any;

      if (data.status === 21007) {
        // Receipt is from sandbox, retry with sandbox URL
        return verifyAppleReceipt(receiptData);
      }

      if (data.status !== 0) {
        throw new Error(`Apple receipt validation failed with status: ${data.status}`);
      }

      return data;
  } catch (error: any) {
    Logger.error('Apple receipt verification failed:', error);
    throw new Error(`Receipt verification failed: ${error.message}`);
  }
}

/**
 * Save subscription to database
 */
async function saveSubscription(data: {
  userId: string;
  productId: string;
  platform: 'android' | 'ios';
  orderId: string;
  purchaseToken?: string;
  expiryDate: Date;
  autoRenewing: boolean;
}) {
  const query_text = `
    INSERT INTO subscriptions (
      user_id, product_id, platform, order_id, 
      purchase_token, expiry_date, auto_renewing, 
      created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
    ON CONFLICT (user_id, platform) 
    DO UPDATE SET
      product_id = EXCLUDED.product_id,
      order_id = EXCLUDED.order_id,
      purchase_token = EXCLUDED.purchase_token,
      expiry_date = EXCLUDED.expiry_date,
      auto_renewing = EXCLUDED.auto_renewing,
      updated_at = NOW()
      RETURNING *
    `;
    
  const values = [
    data.userId,
    data.productId,
    data.platform,
    data.orderId,
    data.purchaseToken || null,
    data.expiryDate,
    data.autoRenewing,
  ];

  const result = await query(query_text, values);
  return result.rows[0];
}

/**
 * Verify receipt endpoint
 */
router.post('/verify-receipt', async (req: Request, res: Response) => {
  try {
    const {
      productId,
      purchaseId,
      purchaseToken,
      verificationData,
      platform,
      userId,
    } = req.body;

    // Validate required fields
    if (!productId || !platform) {
      return res.status(400).json({
        valid: false,
        error: 'Missing required fields',
      });
    }

    // Get authenticated user ID from middleware
    const authenticatedUserId = req.user?.id || userId;
    
    if (!authenticatedUserId) {
      return res.status(401).json({
        valid: false,
        error: 'User authentication required',
      });
    }

    let subscriptionData: any;
    let expiryDate: Date;
    let autoRenewing: boolean;
    let orderId: string;

    if (platform === 'android') {
      // Verify Google Play receipt
      if (!purchaseToken) {
        return res.status(400).json({
          valid: false,
          error: 'Purchase token required for Android',
        });
      }

      const googleReceipt = await verifyGooglePlayReceipt(productId, purchaseToken);

      // Check if payment was received
      if (googleReceipt.paymentState !== 1) {
        return res.status(400).json({
          valid: false,
          error: 'Payment not received',
        });
      }

      expiryDate = new Date(parseInt(googleReceipt.expiryTimeMillis));
      autoRenewing = googleReceipt.autoRenewing || false;
      orderId = googleReceipt.orderId;

    } else if (platform === 'ios') {
      // Verify Apple receipt
      if (!verificationData) {
        return res.status(400).json({
          valid: false,
          error: 'Receipt data required for iOS',
        });
      }

      const appleReceipt = await verifyAppleReceipt(verificationData);
      
      // Find the latest receipt info for this product
      const latestReceipt = appleReceipt.latest_receipt_info?.find(
        (r: any) => r.product_id === productId
      );

      if (!latestReceipt) {
        return res.status(400).json({
          valid: false,
          error: 'No valid subscription found',
        });
      }

      expiryDate = new Date(parseInt(latestReceipt.expires_date_ms));
      autoRenewing = latestReceipt.auto_renew_status === '1';
      orderId = latestReceipt.transaction_id;

    } else {
      return res.status(400).json({
        valid: false,
        error: 'Invalid platform',
      });
    }

    // Check if subscription is still valid
    const isValid = expiryDate > new Date();

    if (!isValid) {
      return res.status(400).json({
        valid: false,
        error: 'Subscription expired',
        expiryDate,
      });
    }

    // Save subscription to database
    const subscription = await saveSubscription({
      userId: authenticatedUserId,
      productId,
      platform,
      orderId,
      purchaseToken,
      expiryDate,
      autoRenewing,
    });

    // Return success response
    return res.json({
      valid: true,
      subscription: {
        id: subscription.id,
        productId: subscription.product_id,
        expiryDate: subscription.expiry_date,
        autoRenewing: subscription.auto_renewing,
        features: SUBSCRIPTION_FEATURES[productId] || [],
      },
    });

  } catch (error: any) {
    Logger.error('Receipt verification error:', error);
    return res.status(500).json({ 
      valid: false,
      error: 'Internal server error',
    });
  }
});

/**
 * Get user's active subscription
 */
router.get('/active', async (req: Request, res: Response) => {
  try {
    // Get user ID from auth (implement proper auth middleware)
    const userId = req.query.userId as string;

    if (!userId) {
      return res.status(401).json({
        error: 'User authentication required',
      });
    }

    const query_text = `
      SELECT * FROM subscriptions 
      WHERE user_id = $1 
        AND expiry_date > NOW()
      ORDER BY expiry_date DESC
      LIMIT 1
    `;
    
    const result = await query(query_text, [userId]);
    
    if (result.rows.length === 0) {
      return res.json({
        hasActiveSubscription: false,
      });
    }

    const subscription = result.rows[0];

    return res.json({
      hasActiveSubscription: true,
      subscription: {
        id: subscription.id,
        productId: subscription.product_id,
        expiryDate: subscription.expiry_date,
        autoRenewing: subscription.auto_renewing,
        platform: subscription.platform,
        features: SUBSCRIPTION_FEATURES[subscription.product_id] || [],
      },
    });

  } catch (error: any) {
    Logger.error('Error fetching active subscription:', error);
    return res.status(500).json({
      error: 'Internal server error',
    });
  }
});

/**
 * Cancel subscription (directs to store)
 */
router.post('/cancel', async (req: Request, res: Response) => {
  try {
    const { userId, platform } = req.body;

    if (!userId) {
      return res.status(401).json({
        error: 'User authentication required',
      });
    }

    // Update auto_renewing status in database
    const query_text = `
      UPDATE subscriptions
      SET auto_renewing = false, updated_at = NOW()
      WHERE user_id = $1 AND expiry_date > NOW()
      RETURNING *
    `;

    await query(query_text, [userId]);

    // Return appropriate store URL for management
    let manageUrl = '';
    if (platform === 'android') {
      manageUrl = `https://play.google.com/store/account/subscriptions?package=${PACKAGE_NAME}`;
    } else if (platform === 'ios') {
      manageUrl = 'https://apps.apple.com/account/subscriptions';
    }

    return res.json({
      success: true,
      message: 'Subscription will not auto-renew',
      manageUrl,
    });

  } catch (error: any) {
    Logger.error('Error canceling subscription:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
    });
  }
});

/**
 * Webhook for Google Play real-time developer notifications
 */
router.post('/webhook/google', async (req: Request, res: Response) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Invalid webhook data' });
    }

    // Decode the base64 message
    const decodedData = Buffer.from(message.data, 'base64').toString();
    const notification = JSON.parse(decodedData);

    Logger.info('Google Play webhook received:', notification);

    // Handle different notification types
    switch (notification.notificationType) {
      case 1: // SUBSCRIPTION_RECOVERED
      case 2: // SUBSCRIPTION_RENEWED
      case 7: // SUBSCRIPTION_RESTARTED
        // Update subscription as active
        await handleSubscriptionRenewal(notification);
        break;

      case 3: // SUBSCRIPTION_CANCELED
      case 10: // SUBSCRIPTION_PAUSED
      case 13: // SUBSCRIPTION_EXPIRED
        // Update subscription as inactive
        await handleSubscriptionCancellation(notification);
        break;

      case 4: // SUBSCRIPTION_PURCHASED
        // New subscription
        await handleNewSubscription(notification);
        break;
    }

    return res.status(200).json({ success: true });

  } catch (error: any) {
    Logger.error('Google webhook error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Helper functions for webhook handling
async function handleSubscriptionRenewal(notification: any) {
  // Implementation for renewal
  Logger.info('Handling subscription renewal:', notification);
}

async function handleSubscriptionCancellation(notification: any) {
  // Implementation for cancellation
  Logger.info('Handling subscription cancellation:', notification);
}

async function handleNewSubscription(notification: any) {
  // Implementation for new subscription
  Logger.info('Handling new subscription:', notification);
}

export default router;