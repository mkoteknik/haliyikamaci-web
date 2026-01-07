import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/system_settings_repository.dart';

/// Helper class for profanity filtering
class ProfanityHelper {
  final List<String> blockedWords;

  ProfanityHelper(this.blockedWords);

  /// Check if text contains any blocked words
  /// Returns 'true' if profanity is found
  bool hasProfanity(String text) {
    if (text.isEmpty || blockedWords.isEmpty) return false;

    // Normalize text: lowercase
    final normalizedText = text.toLowerCase();
    
    // Check for each blocked word
    for (final word in blockedWords) {
      if (word.isEmpty) continue;
      
      final normalizedWord = word.toLowerCase();
      
      // Word boundary check - kelime bağımsız olarak mı geçiyor?
      // "yarak" kelimesi "anlayarak" içinde geçerse ENGELLENMEMEL
      // "yarak" kelimesi " yarak " veya "yarak." gibi bağımsız geçerse ENGELLENMELİ
      
      // Regex ile kelime sınırı kontrolü
      // Türkçe karakterler için özel boundary pattern
      // Kelime başı ve sonu: boşluk, noktalama, satır başı/sonu
      final pattern = RegExp(
        r'(?<![a-zA-ZğüşöçıİĞÜŞÖÇ])' + RegExp.escape(normalizedWord) + r'(?![a-zA-ZğüşöçıİĞÜŞÖÇ])',
        caseSensitive: false,
      );
      
      if (pattern.hasMatch(normalizedText)) {
        return true;
      }
    }

    return false;
  }
}

/// Provider for Profanity Helper
/// It watches the system settings to always have the latest list.
final profanityHelperProvider = Provider<ProfanityHelper>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  
  // Default to empty list while loading or on error
  final blockedWords = settingsAsync.maybeWhen(
    data: (settings) => settings.blockedWords,
    orElse: () => <String>[],
  );

  return ProfanityHelper(blockedWords);
});
