import 'package:flutter/foundation.dart';

// TAHAP 5: Membuat class state terpisah
class CourseState extends ChangeNotifier {
  final Set<String> favorites = {};

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    
    // Fungsinya untuk mengabari UI agar me-render ulang bagian yang berubah
    notifyListeners();
  }
}