const path = require('path');
const admin = require('firebase-admin');

function _readServiceAccount() {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      return JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    }

    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const absolutePath = path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
      return require(absolutePath);
    }

    return null;
  } catch (error) {
    console.error('Firebase service account parse error:', error.message);
    return null;
  }
}

function getMessaging() {
  try {
    if (!admin.apps.length) {
      const serviceAccount = _readServiceAccount();
      if (!serviceAccount) return null;

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }

    return admin.messaging();
  } catch (error) {
    console.error('Firebase Admin init error:', error.message);
    return null;
  }
}

module.exports = { getMessaging };
