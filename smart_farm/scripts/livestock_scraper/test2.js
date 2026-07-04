const admin = require('firebase-admin');
const path = require('path');
const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}
const db = admin.firestore();

async function checkData() {
  const mandi = await db.collection('mandi_prices').limit(5).get();
  console.log('MANDI PRICES DB DUMP:');
  mandi.forEach(doc => console.log(doc.id, doc.data()));

  const livestock = await db.collection('livestock_prices').limit(5).get();
  console.log('LIVESTOCK PRICES DB DUMP:');
  livestock.forEach(doc => console.log(doc.id, doc.data()));
  process.exit();
}
checkData();
