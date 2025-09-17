// functions/dailyChallenge.js

const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onCall } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

// Daily challenge templates (same as client-side for consistency)
const dailyChallengeTemplates = [
  // Week 1: Easy Start
  { id: 'day_001', categoryId: 'hungry_satiated', range: 1, specificClue: 'Starving', difficulty: 'easy' },
  { id: 'day_002', categoryId: 'spicy_mild', range: 5, specificClue: 'Plain rice', difficulty: 'easy' },
  { id: 'day_003', categoryId: 'magic_science', range: 1, specificClue: 'Dragon\'s breath', difficulty: 'easy' },
  { id: 'day_004', categoryId: 'myth_history', range: 5, specificClue: 'DNA evidence', difficulty: 'easy' },
  { id: 'day_005', categoryId: 'hungry_satiated', range: 5, specificClue: 'Food coma', difficulty: 'easy' },
  { id: 'day_006', categoryId: 'spicy_mild', range: 1, specificClue: 'Ghost pepper', difficulty: 'easy' },
  { id: 'day_007', categoryId: 'magic_science', range: 5, specificClue: 'Quantum physics', difficulty: 'easy' },
  
  // Week 2: Medium Difficulty
  { id: 'day_008', categoryId: 'myth_history', range: 2, specificClue: 'Folk tale', difficulty: 'medium' },
  { id: 'day_009', categoryId: 'hungry_satiated', range: 3, specificClue: 'Just right', difficulty: 'medium' },
  { id: 'day_010', categoryId: 'spicy_mild', range: 3, specificClue: 'Black pepper', difficulty: 'medium' },
  { id: 'day_011', categoryId: 'magic_science', range: 4, specificClue: 'Laboratory', difficulty: 'medium' },
  { id: 'day_012', categoryId: 'myth_history', range: 4, specificClue: 'Archaeological find', difficulty: 'medium' },
  { id: 'day_013', categoryId: 'hungry_satiated', range: 2, specificClue: 'Getting hungry', difficulty: 'medium' },
  { id: 'day_014', categoryId: 'spicy_mild', range: 4, specificClue: 'Plain yogurt', difficulty: 'medium' },
  
  // Week 3: Hard Challenges
  { id: 'day_015', categoryId: 'magic_science', range: 3, specificClue: 'Alchemy', difficulty: 'hard' },
  { id: 'day_016', categoryId: 'myth_history', range: 3, specificClue: 'Legend or fact', difficulty: 'hard' },
  { id: 'day_017', categoryId: 'hungry_satiated', range: 4, specificClue: 'Had enough', difficulty: 'hard' },
  { id: 'day_018', categoryId: 'spicy_mild', range: 2, specificClue: 'Hot sauce', difficulty: 'hard' },
  { id: 'day_019', categoryId: 'magic_science', range: 2, specificClue: 'Crystal ball', difficulty: 'hard' },
  { id: 'day_020', categoryId: 'myth_history', range: 1, specificClue: 'Greek gods', difficulty: 'hard' },
  { id: 'day_021', categoryId: 'hungry_satiated', range: 1, specificClue: 'Empty stomach', difficulty: 'hard' },
  
  // Week 4: Mixed
  { id: 'day_022', categoryId: 'spicy_mild', range: 5, specificClue: 'Tasteless', difficulty: 'easy' },
  { id: 'day_023', categoryId: 'magic_science', range: 1, specificClue: 'Magic potion', difficulty: 'medium' },
  { id: 'day_024', categoryId: 'myth_history', range: 5, specificClue: 'Historical fact', difficulty: 'medium' },
  { id: 'day_025', categoryId: 'hungry_satiated', range: 3, specificClue: 'Content', difficulty: 'hard' },
  { id: 'day_026', categoryId: 'spicy_mild', range: 3, specificClue: 'Balanced', difficulty: 'hard' },
  { id: 'day_027', categoryId: 'magic_science', range: 4, specificClue: 'Research', difficulty: 'medium' },
  { id: 'day_028', categoryId: 'myth_history', range: 2, specificClue: 'Ancient legend', difficulty: 'easy' },
];

// Category information for labels
const categoryInfo = {
  'hungry_satiated': { bundleId: 'bundle.food', leftLabel: 'HUNGRY', rightLabel: 'SATIATED' },
  'spicy_mild': { bundleId: 'bundle.food', leftLabel: 'SPICY', rightLabel: 'MILD' },
  'magic_science': { bundleId: 'bundle.fantasy', leftLabel: 'MAGIC', rightLabel: 'SCIENCE' },
  'myth_history': { bundleId: 'bundle.fantasy', leftLabel: 'MYTH', rightLabel: 'HISTORY' },
};

/**
 * Generate daily challenge - runs every day at midnight UTC
 */
exports.generateDailyChallenge = onSchedule({
  schedule: '0 0 * * *', // Every day at midnight UTC
  timeZone: 'UTC',
  region: 'us-central1'
}, async (event) => {
    try {
      const today = new Date();
      const todayId = formatDate(today);
      
      console.log(`Generating daily challenge for ${todayId}`);
      
      // Check if today's challenge already exists
      const existingChallenge = await admin.firestore()
        .collection('daily_challenges')
        .doc(todayId)
        .get();
      
      if (existingChallenge.exists) {
        console.log(`Daily challenge for ${todayId} already exists, skipping generation`);
        return null;
      }
      
      // Get challenge template for today
      const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / (1000 * 60 * 60 * 24));
      const template = dailyChallengeTemplates[dayOfYear % dailyChallengeTemplates.length];
      
      // Generate position within the specified range
      const rangeStart = (template.range - 1) * 0.2;
      const rangeEnd = template.range * 0.2;
      const secretPosition = rangeStart + (Math.random() * (rangeEnd - rangeStart));
      
      // Get category info
      const catInfo = categoryInfo[template.categoryId];
      
      // Create daily challenge document
      const dailyChallenge = {
        categoryId: template.categoryId,
        secretPosition: secretPosition,
        range: template.range,
        clue: template.specificClue,
        difficulty: template.difficulty,
        date: admin.firestore.Timestamp.fromDate(today),
        bundleId: catInfo.bundleId,
        leftLabel: catInfo.leftLabel,
        rightLabel: catInfo.rightLabel,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      // Save to Firestore
      await admin.firestore()
        .collection('daily_challenges')
        .doc(todayId)
        .set(dailyChallenge);
      
      console.log(`Successfully generated daily challenge for ${todayId}: ${template.specificClue}`);
      
      return null;
    } catch (error) {
      console.error('Error generating daily challenge:', error);
      return null;
    }
  });

/**
 * Manual trigger for generating daily challenge (for testing)
 */
exports.generateDailyChallengeManual = onCall({
  region: 'us-central1'
}, async (request) => {
  // Only allow authenticated users to manually trigger (for testing)
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }
  
  try {
    const today = new Date();
    const todayId = formatDate(today);
    
    // Force regenerate today's challenge
    const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / (1000 * 60 * 60 * 24));
    const template = dailyChallengeTemplates[dayOfYear % dailyChallengeTemplates.length];
    
    const rangeStart = (template.range - 1) * 0.2;
    const rangeEnd = template.range * 0.2;
    const secretPosition = rangeStart + (Math.random() * (rangeEnd - rangeStart));
    
    const catInfo = categoryInfo[template.categoryId];
    
    const dailyChallenge = {
      categoryId: template.categoryId,
      secretPosition: secretPosition,
      range: template.range,
      clue: template.specificClue,
      difficulty: template.difficulty,
      date: admin.firestore.Timestamp.fromDate(today),
      bundleId: catInfo.bundleId,
      leftLabel: catInfo.leftLabel,
      rightLabel: catInfo.rightLabel,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    
    await admin.firestore()
      .collection('daily_challenges')
      .doc(todayId)
      .set(dailyChallenge);
    
    return { success: true, challengeId: todayId, clue: template.specificClue };
    
  } catch (error) {
    console.error('Error manually generating daily challenge:', error);
    throw new Error('Failed to generate daily challenge');
  }
});

/**
 * Helper function to format date as YYYY-MM-DD
 */
function formatDate(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
