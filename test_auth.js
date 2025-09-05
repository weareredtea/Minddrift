const admin = require('firebase-admin');

// Initialize Firebase Admin (you'll need to download your service account key)
// Download from: Firebase Console → Project Settings → Service Accounts → Generate New Private Key

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function generateCustomToken(uid) {
  try {
    const customToken = await admin.auth().createCustomToken(uid);
    console.log('Custom Token:', customToken);
    
    // You can also create a user if it doesn't exist
    try {
      await admin.auth().createUser({
        uid: uid,
        email: 'test@example.com',
        password: 'password123'
      });
      console.log('User created successfully');
    } catch (error) {
      if (error.code === 'auth/uid-already-exists') {
        console.log('User already exists');
      } else {
        console.error('Error creating user:', error);
      }
    }
    
  } catch (error) {
    console.error('Error generating custom token:', error);
  }
}

// Generate token for a test user
generateCustomToken('test-user-123');
