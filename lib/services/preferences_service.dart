// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _selectedDateKey = 'selected_date';

  /// Save selected date
  Future<void> saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDateKey, date.toIso8601String());
  }

  /// Load selected date
  Future<DateTime?> loadSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_selectedDateKey);

    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }
}
