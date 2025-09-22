const functions = require('firebase-functions');
const admin = require('firebase-admin');

// English to Arabic clue mapping
const clueTranslations = {
  // Add your English clues and their Arabic translations here
  "Stomach rumbling": "قرقرة المعدة",
  "Heart racing": "تسارع دقات القلب",
  "Butterflies in stomach": "فراشات في المعدة",
  "Cold sweat": "عرق بارد",
  "Goosebumps": "قشعريرة",
  "Tears of joy": "دموع الفرح",
  "Lump in throat": "كتلة في الحلق",
  "Shaking hands": "ارتجاف اليدين",
  "Dry mouth": "جفاف الفم",
  "Blushing": "احمرار الوجه",
  // Add more mappings as needed
};

exports.updateDailyChallengeClues = functions.https.onCall(async (data, context) => {
  try {
    const db = admin.firestore();
    const batch = db.batch();
    
    // Get all daily challenge documents
    const dailyChallengesRef = db.collection('daily_challenges');
    const snapshot = await dailyChallengesRef.get();
    
    let updateCount = 0;
    
    snapshot.forEach((doc) => {
      const data = doc.data();
      const englishClue = data.clue;
      
      if (englishClue && clueTranslations[englishClue]) {
        const arabicClue = clueTranslations[englishClue];
        
        // Update the document with Arabic clue
        batch.update(doc.ref, {
          clueAr: arabicClue,
          clueEn: englishClue, // Also set English explicitly
        });
        
        updateCount++;
        console.log(`Updated: ${doc.id} - "${englishClue}" -> "${arabicClue}"`);
      } else {
        console.log(`No translation found for: "${englishClue}"`);
      }
    });
    
    // Commit the batch
    await batch.commit();
    
    return {
      success: true,
      message: `Updated ${updateCount} daily challenge documents`,
      updatedCount: updateCount
    };
    
  } catch (error) {
    console.error('Error updating daily challenges:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update daily challenges');
  }
});
