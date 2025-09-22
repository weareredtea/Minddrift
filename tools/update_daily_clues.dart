import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// English to Arabic clue mapping
const Map<String, String> clueTranslations = {
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

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  
  try {
    // Get all daily challenge documents
    final snapshot = await db.collection('daily_challenges').get();
    
    int updateCount = 0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final englishClue = data['clue'] as String?;
      
      if (englishClue != null && clueTranslations.containsKey(englishClue)) {
        final arabicClue = clueTranslations[englishClue]!;
        
        // Update the document with Arabic clue
        batch.update(doc.reference, {
          'clueAr': arabicClue,
          'clueEn': englishClue, // Also set English explicitly
        });
        
        updateCount++;
        print('Updated: ${doc.id} - "$englishClue" -> "$arabicClue"');
      } else {
        print('No translation found for: "$englishClue"');
      }
    }
    
    // Commit the batch
    await batch.commit();
    
    print('\n✅ Successfully updated $updateCount daily challenge documents');
    
  } catch (e) {
    print('❌ Error updating daily challenges: $e');
  }
  
  exit(0);
}
