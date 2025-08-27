// lib/services/audio_service.dart

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton pattern to ensure only one instance
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Pre-load audio files into cache for faster playback
  Future<void> preloadSounds() async {
    await AudioCache().loadAll([
      'audio/ui_tap.mp3',
      'audio/player_join.mp3',
      'audio/player_leave.mp3',
      'audio/score_high.mp3',
      'audio/score_low.mp3',
      'audio/dice_roll.mp3',
      'audio/bg_music.mp3',
      'audio/cheer.mp3',
    ]);
  }

  // --- Sound Effects (SFX) ---

// NEW: Add this method
  void playCheerSound() {
    _sfxPlayer.play(AssetSource('audio/cheer.mp3'));
  }

  void playTapSound() {
    _sfxPlayer.play(AssetSource('audio/ui_tap.mp3'));
  }

  void playPlayerJoinSound() {
    _sfxPlayer.play(AssetSource('audio/player_join.mp3'));
  }

  void playPlayerLeaveSound() {
    _sfxPlayer.play(AssetSource('audio/player_leave.mp3'));
  }
  
  void playDiceRollSound() {
    _sfxPlayer.play(AssetSource('audio/dice_roll.mp3'));
  }
  
  void playScoreSound(int score) {
    if (score > 1) {
      _sfxPlayer.play(AssetSource('audio/score_high.mp3'));
    } else {
      _sfxPlayer.play(AssetSource('audio/score_low.mp3'));
    }
  }

  // --- Background Music (BGM) ---
  
  Future<void> startMusic() async {
    if (_musicPlayer.state == PlayerState.playing) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/bg_music.mp3'), volume: 0.3);
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // --- Music Settings ---
  bool _musicEnabled = true;

  bool isMusicEnabled() => _musicEnabled;

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      startMusic();
    } else {
      stopMusic();
    }
  }
}
