const { onCall } = require('firebase-functions/v2/https');
const { onRequest } = require('firebase-functions/v2/https');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// Import daily challenge functions
const { generateDailyChallenge, generateDailyChallengeManual } = require('./dailyChallenge');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

/**
 * Verifies Google Play purchase and grants user access to the bundle
 * This function is called from the Flutter app after a successful purchase
 */
exports.verifyPurchase = onCall({
  region: 'us-central1',
  maxInstances: 10
}, async (request) => {
  try {
    const { data, auth } = request;
    
    // Debug logging for authentication context
    console.log('🔍 Debug: Function called with context:', {
      hasAuth: !!auth,
      authUid: auth?.uid,
      authEmail: auth?.email,
      authProvider: auth?.providerData?.[0]?.providerId,
      data: data
    });
    
    // Check if user is authenticated
    if (!auth) {
      console.error('❌ Authentication failed: auth is null/undefined');
      throw new Error('User must be authenticated');
    }

    const { token, sku, platform, transactionId, originalTransactionId } = data;
    const userId = auth.uid;

    console.log(`✅ Authentication successful: User ${userId}, SKU: ${sku}, platform: ${platform}`);

    // Validate required parameters
    if (!token || !sku || !platform || !transactionId) {
      throw new Error('Missing required parameters');
    }

    // For now, we'll trust the client-side verification
    // In production, you should implement Google Play server-side verification
    // using the Google Play Developer API
    
    // TODO: Implement proper Google Play server-side verification
    // const isValidPurchase = await verifyWithGooglePlay(token, sku, platform);
    // if (!isValidPurchase) {
    //   throw new functions.https.HttpsError('permission-denied', 'Invalid purchase');
    // }

    // Update user's owned bundles in Firestore
    const userRef = db.collection('users').doc(userId);
    
    // Get current user document
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      // Create new user document
      await userRef.set({
        owned_skus: [sku],
        transactions: [transactionId],
        subscription_info: {
          [sku]: {
            transactionId,
            originalTransactionId: originalTransactionId || transactionId,
            platform,
            granted_at: admin.firestore.FieldValue.serverTimestamp()
          }
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing user document
      const userData = userDoc.data();
      const ownedSkus = userData.owned_skus || [];
      const transactions = userData.transactions || [];
      const subscriptionInfo = userData.subscription_info || {};
      
      // Add the new SKU if not already owned
      if (!ownedSkus.includes(sku)) {
        ownedSkus.push(sku);
      }
      
      // Add transaction if not already recorded
      if (!transactions.includes(transactionId)) {
        transactions.push(transactionId);
      }
      
      // Update subscription info
      subscriptionInfo[sku] = {
        transactionId,
        originalTransactionId: originalTransactionId || transactionId,
        platform,
        granted_at: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await userRef.update({
        owned_skus: ownedSkus,
        transactions: transactions,
        subscription_info: subscriptionInfo,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    console.log(`Successfully granted access to ${sku} for user ${userId}`);
    
    return {
      success: true,
      message: `Access granted to ${sku}`,
      ownedSkus: [sku]
    };

  } catch (error) {
    console.error('Error verifying purchase:', error);
    
    if (error instanceof Error) {
      throw error;
    }
    
    throw new Error('Failed to verify purchase', error.message);
  }
});

/**
 * Creates a user document in Firestore with default values
 * This function has admin privileges and can create documents
 */
exports.createUserDocument = onCall({
  region: 'us-central1',
  maxInstances: 10
}, async (request) => {
  try {
    const { data, auth } = request;
    
    // Check if user is authenticated
    if (!auth) {
      throw new Error('User must be authenticated');
    }

    const { userId } = data;
    
    // Verify the user is creating their own document
    if (auth.uid !== userId) {
      throw new Error('User can only create their own document');
    }

    console.log(`Creating user document for: ${userId}`);

    // Check if document already exists
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (userDoc.exists) {
      console.log(`User document already exists for: ${userId}`);
      return {
        success: true,
        message: 'User document already exists',
        existed: true
      };
    }

    // Create the user document
    await userRef.set({
      owned_skus: ['bundle.free'],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Successfully created user document for: ${userId}`);
    
    return {
      success: true,
      message: 'User document created successfully',
      existed: false
    };

  } catch (error) {
    console.error('Error creating user document:', error);
    throw error;
  }
});

/**
 * Creates a user document in Firestore with default values.
 * This function can be called manually or automatically to ensure user documents exist.
 * This eliminates the chicken-and-egg problem for new users.
 */
exports.ensureUserDocument = onCall({
  region: 'us-central1',
  maxInstances: 10
}, async (request) => {
  try {
    const { data, auth } = request;
    
    // Check if user is authenticated
    if (!auth) {
      throw new Error('User must be authenticated');
    }

    const userId = auth.uid;
    console.log(`🔧 Ensuring user document exists for: ${userId}`);

    // Check if document already exists
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (userDoc.exists) {
      console.log(`✅ User document already exists for: ${userId}`);
      return {
        success: true,
        message: 'User document already exists',
        existed: true
      };
    }

    // Create the user document
    await userRef.set({
      owned_skus: ['bundle.free'],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Successfully created user document for: ${userId}`);
    
    return {
      success: true,
      message: 'User document created successfully',
      existed: false
    };

  } catch (error) {
    console.error('Error ensuring user document:', error);
    throw error;
  }
});

/**
 * App Store Server Notifications Handler
 * This endpoint receives notifications from Apple about in-app purchase events
 * Documentation: https://developer.apple.com/documentation/appstoreservernotifications
 */
exports.appStoreNotifications = onRequest({
  region: 'us-central1',
  maxInstances: 10
}, async (request, response) => {
  try {
    console.log('📱 App Store notification received');
    
    // Verify the notification signature (optional but recommended)
    const signature = request.headers['x-apple-notification-signature'];
    const notificationData = request.body;
    
    console.log('🔍 Notification data:', JSON.stringify(notificationData, null, 2));
    
    // Parse the notification
    const notification = notificationData;
    const notificationType = notification.notification_type;
    const unifiedReceipt = notification.unified_receipt;
    
    console.log(`📋 Notification type: ${notificationType}`);
    
    // Handle different notification types
    switch (notificationType) {
      case 'INITIAL_BUY':
        await handleInitialBuy(notification, unifiedReceipt);
        break;
      case 'DID_RENEW':
        await handleRenewal(notification, unifiedReceipt);
        break;
      case 'DID_FAIL_TO_RENEW':
        await handleRenewalFailure(notification, unifiedReceipt);
        break;
      case 'DID_CANCEL':
        await handleCancellation(notification, unifiedReceipt);
        break;
      case 'REFUND':
        await handleRefund(notification, unifiedReceipt);
        break;
      case 'REVOKE':
        await handleRevocation(notification, unifiedReceipt);
        break;
      default:
        console.log(`⚠️ Unhandled notification type: ${notificationType}`);
    }
    
    // Always respond with 200 OK to acknowledge receipt
    response.status(200).send('OK');
    
  } catch (error) {
    console.error('❌ Error processing App Store notification:', error);
    // Still respond with 200 to prevent Apple from retrying
    response.status(200).send('OK');
  }
});

/**
 * Handle initial purchase
 */
async function handleInitialBuy(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      const transactionId = receipt.transaction_id;
      
      console.log(`✅ Initial purchase: ${productId} for transaction ${transactionId}`);
      
      // Find user by original transaction ID or other identifier
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await grantAccessToProduct(userId, productId, {
          transactionId,
          originalTransactionId,
          purchaseDate: receipt.purchase_date_ms,
          expiresDate: receipt.expires_date_ms
        });
      } else {
        console.log(`⚠️ Could not find user for transaction ${originalTransactionId}`);
      }
    }
  } catch (error) {
    console.error('❌ Error handling initial buy:', error);
  }
}

/**
 * Handle subscription renewal
 */
async function handleRenewal(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      const transactionId = receipt.transaction_id;
      
      console.log(`🔄 Renewal: ${productId} for transaction ${transactionId}`);
      
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await updateSubscriptionStatus(userId, productId, {
          transactionId,
          originalTransactionId,
          purchaseDate: receipt.purchase_date_ms,
          expiresDate: receipt.expires_date_ms,
          isActive: true
        });
      }
    }
  } catch (error) {
    console.error('❌ Error handling renewal:', error);
  }
}

/**
 * Handle renewal failure
 */
async function handleRenewalFailure(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      
      console.log(`❌ Renewal failed: ${productId} for transaction ${originalTransactionId}`);
      
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await updateSubscriptionStatus(userId, productId, {
          originalTransactionId,
          isActive: false,
          failureReason: 'renewal_failed'
        });
      }
    }
  } catch (error) {
    console.error('❌ Error handling renewal failure:', error);
  }
}

/**
 * Handle cancellation
 */
async function handleCancellation(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      
      console.log(`🚫 Cancellation: ${productId} for transaction ${originalTransactionId}`);
      
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await updateSubscriptionStatus(userId, productId, {
          originalTransactionId,
          isActive: false,
          cancelled: true,
          cancellationDate: receipt.cancellation_date_ms
        });
      }
    }
  } catch (error) {
    console.error('❌ Error handling cancellation:', error);
  }
}

/**
 * Handle refund
 */
async function handleRefund(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      
      console.log(`💰 Refund: ${productId} for transaction ${originalTransactionId}`);
      
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await revokeAccessToProduct(userId, productId, {
          originalTransactionId,
          refunded: true,
          refundDate: receipt.cancellation_date_ms
        });
      }
    }
  } catch (error) {
    console.error('❌ Error handling refund:', error);
  }
}

/**
 * Handle revocation (family sharing, etc.)
 */
async function handleRevocation(notification, unifiedReceipt) {
  try {
    const latestReceiptInfo = unifiedReceipt.latest_receipt_info;
    
    for (const receipt of latestReceiptInfo) {
      const productId = receipt.product_id;
      const originalTransactionId = receipt.original_transaction_id;
      
      console.log(`🔒 Revocation: ${productId} for transaction ${originalTransactionId}`);
      
      const userId = await findUserByTransactionId(originalTransactionId);
      
      if (userId) {
        await revokeAccessToProduct(userId, productId, {
          originalTransactionId,
          revoked: true,
          revocationDate: Date.now()
        });
      }
    }
  } catch (error) {
    console.error('❌ Error handling revocation:', error);
  }
}

/**
 * Find user by transaction ID
 * You'll need to store transaction IDs when users make purchases
 */
async function findUserByTransactionId(transactionId) {
  try {
    // Query users collection for the transaction ID
    const usersSnapshot = await db.collection('users')
      .where('transactions', 'array-contains', transactionId)
      .limit(1)
      .get();
    
    if (!usersSnapshot.empty) {
      return usersSnapshot.docs[0].id;
    }
    
    // If not found, you might need to implement a different lookup strategy
    console.log(`⚠️ User not found for transaction ${transactionId}`);
    return null;
  } catch (error) {
    console.error('❌ Error finding user by transaction ID:', error);
    return null;
  }
}

/**
 * Grant access to a product
 */
async function grantAccessToProduct(userId, productId, transactionInfo) {
  try {
    const userRef = db.collection('users').doc(userId);
    
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        // Create new user document
        transaction.set(userRef, {
          owned_skus: [productId],
          transactions: [transactionInfo.transactionId],
          subscription_info: {
            [productId]: {
              ...transactionInfo,
              granted_at: admin.firestore.FieldValue.serverTimestamp()
            }
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        const userData = userDoc.data();
        const ownedSkus = userData.owned_skus || [];
        const transactions = userData.transactions || [];
        const subscriptionInfo = userData.subscription_info || {};
        
        // Add product if not already owned
        if (!ownedSkus.includes(productId)) {
          ownedSkus.push(productId);
        }
        
        // Add transaction if not already recorded
        if (!transactions.includes(transactionInfo.transactionId)) {
          transactions.push(transactionInfo.transactionId);
        }
        
        // Update subscription info
        subscriptionInfo[productId] = {
          ...transactionInfo,
          granted_at: admin.firestore.FieldValue.serverTimestamp()
        };
        
        transaction.update(userRef, {
          owned_skus: ownedSkus,
          transactions: transactions,
          subscription_info: subscriptionInfo,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });
    
    console.log(`✅ Granted access to ${productId} for user ${userId}`);
  } catch (error) {
    console.error('❌ Error granting access to product:', error);
  }
}

/**
 * Update subscription status
 */
async function updateSubscriptionStatus(userId, productId, statusInfo) {
  try {
    const userRef = db.collection('users').doc(userId);
    
    await userRef.update({
      [`subscription_info.${productId}`]: {
        ...statusInfo,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    console.log(`✅ Updated subscription status for ${productId} for user ${userId}`);
  } catch (error) {
    console.error('❌ Error updating subscription status:', error);
  }
}

/**
 * Revoke access to a product
 */
async function revokeAccessToProduct(userId, productId, revocationInfo) {
  try {
    const userRef = db.collection('users').doc(userId);
    
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (userDoc.exists) {
        const userData = userDoc.data();
        const ownedSkus = userData.owned_skus || [];
        const subscriptionInfo = userData.subscription_info || {};
        
        // Remove product from owned list
        const updatedOwnedSkus = ownedSkus.filter(sku => sku !== productId);
        
        // Update subscription info
        subscriptionInfo[productId] = {
          ...subscriptionInfo[productId],
          ...revocationInfo,
          revoked_at: admin.firestore.FieldValue.serverTimestamp()
        };
        
        transaction.update(userRef, {
          owned_skus: updatedOwnedSkus,
          subscription_info: subscriptionInfo,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });
    
    console.log(`✅ Revoked access to ${productId} for user ${userId}`);
  } catch (error) {
    console.error('❌ Error revoking access to product:', error);
  }
}

/**
 * Helper function to verify purchase with Google Play (to be implemented)
 * This would use the Google Play Developer API to verify the purchase token
 */
async function verifyWithGooglePlay(token, sku, platform) {
  // TODO: Implement Google Play server-side verification
  // This would involve:
  // 1. Using the Google Play Developer API
  // 2. Verifying the purchase token
  // 3. Checking if the purchase is valid and not refunded
  
  // For now, return true to allow the purchase
  // In production, this should always verify with Google's servers
  return true;
}

// Export daily challenge functions
exports.generateDailyChallenge = generateDailyChallenge;
exports.generateDailyChallengeManual = generateDailyChallengeManual;
