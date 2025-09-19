// lib/models/match_settings.dart

/// Match settings that persist across games
class MatchSettings {
  final int numberOfRounds;
  final bool musicEnabled;
  final String spectrumSkinId;
  
  const MatchSettings({
    required this.numberOfRounds,
    required this.musicEnabled,
    required this.spectrumSkinId,
  });

  /// Default settings
  static const MatchSettings defaultSettings = MatchSettings(
    numberOfRounds: 5,
    musicEnabled: true,
    spectrumSkinId: 'default',
  );

  /// Create from map (Firebase)
  factory MatchSettings.fromMap(Map<String, dynamic> map) {
    return MatchSettings(
      numberOfRounds: map['numberOfRounds'] as int? ?? 5,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      spectrumSkinId: map['spectrumSkinId'] as String? ?? 'default',
    );
  }

  /// Convert to map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'numberOfRounds': numberOfRounds,
      'musicEnabled': musicEnabled,
      'spectrumSkinId': spectrumSkinId,
    };
  }

  /// Create copy with updated fields
  MatchSettings copyWith({
    int? numberOfRounds,
    bool? musicEnabled,
    String? spectrumSkinId,
  }) {
    return MatchSettings(
      numberOfRounds: numberOfRounds ?? this.numberOfRounds,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      spectrumSkinId: spectrumSkinId ?? this.spectrumSkinId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MatchSettings &&
        other.numberOfRounds == numberOfRounds &&
        other.musicEnabled == musicEnabled &&
        other.spectrumSkinId == spectrumSkinId;
  }

  @override
  int get hashCode {
    return numberOfRounds.hashCode ^
        musicEnabled.hashCode ^
        spectrumSkinId.hashCode;
  }

  @override
  String toString() {
    return 'MatchSettings(numberOfRounds: $numberOfRounds, musicEnabled: $musicEnabled, spectrumSkinId: $spectrumSkinId)';
  }
}
