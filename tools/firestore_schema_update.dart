// tools/firestore_schema_update.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wavelength_clone_fresh/firebase_options.dart';  // ← adjust to your package name

Future<void> main() async {
  // 1️⃣ Initialize Firebase with your generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final db = FirebaseFirestore.instance;

  // 2️⃣ Iterate all rooms
  final rooms = await db.collection('rooms').get();
  for (final room in rooms.docs) {
    final roomRef = room.reference;

    // A) Add teamBattleEnabled: false if missing
    await roomRef.set({'teamBattleEnabled': false}, SetOptions(merge: true));

    // B) For each player doc, add team: "A"
    final players = await roomRef.collection('players').get();
    for (final p in players.docs) {
      await p.reference.set({'team': 'A'}, SetOptions(merge: true));
    }

    // C) Migrate old history entries with `score` → split into teamAScore/teamBScore
    final history = await roomRef.collection('history').get();
    for (final h in history.docs) {
      final data = h.data();
      if (data.containsKey('score')) {
        final oldScore = data['score'];
        await h.reference.set({
          'teamAScore': oldScore,
          'teamBScore': 0,
        }, SetOptions(merge: true));
      }
    }

    print('Updated room ${room.id}');
  }

  print('✅ All rooms schema updated.');
}
