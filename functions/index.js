const { onCall } = require('firebase-functions/v2/https');
const functions = require('firebase-functions');
const admin = require('firebase-admin');

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

    const { token, sku, platform } = data;
    const userId = auth.uid;

    console.log(`✅ Authentication successful: User ${userId}, SKU: ${sku}, platform: ${platform}`);

    // Validate required parameters
    if (!token || !sku || !platform) {
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
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing user document
      const userData = userDoc.data();
      const ownedSkus = userData.owned_skus || [];
      
      // Add the new SKU if not already owned
      if (!ownedSkus.includes(sku)) {
        ownedSkus.push(sku);
        
        await userRef.update({
          owned_skus: ownedSkus,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
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
