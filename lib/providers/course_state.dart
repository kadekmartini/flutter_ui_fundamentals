import 'package:flutter/foundation.dart';

// TAHAP 5: Membuat class state terpisah menggunakan ChangeNotifier
class CourseState extends ChangeNotifier {
  final Set<String> favorites = {};

  // TAHAP 13: Fungsi helper isFavorite
  bool isFavorite(String code) => favorites.contains(code);

  // TAHAP 13: Refactor toggleFavorite menggunakan ternary operator
  void toggleFavorite(String code) {
    favorites.contains(code)
        ? favorites.remove(code)
        : favorites.add(code);
    notifyListeners(); 
  }
}