// lib/providers/user_profile_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  UserProfile? _userProfile;
  StreamSubscription? _profileSubscription;

  UserProfile? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;

  UserProfileProvider({required ProfileService profileService})
      : _profileService = profileService;

  /// Starts listening to the profile stream for the given user ID.
  void listenToProfile(String? uid) {
    // Stop listening to the old profile stream
    _profileSubscription?.cancel();

    if (uid == null) {
      _userProfile = null;
      notifyListeners();
      return;
    }

    _profileSubscription = _profileService.getProfileStream(uid).listen((profile) {
      _userProfile = profile;
      notifyListeners();
    });
  }

  /// Updates the user's profile and notifies listeners.
  Future<void> updateProfile(UserProfile profile) async {
    await _profileService.updateProfile(profile);
    // The stream will automatically update _userProfile and notify listeners
  }

  /// Gets the current user's profile once (non-streaming).
  Future<UserProfile?> getCurrentProfile() async {
    if (_userProfile?.uid != null) {
      return await _profileService.getProfile(_userProfile!.uid);
    }
    return null;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
