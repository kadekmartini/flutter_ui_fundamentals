import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseState extends ChangeNotifier {
  CourseState({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  final Set<String> favorites = {};
  final Set<String> _pendingChanges = {};

  bool isLoading = false;
  String? error;
  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  Future<void> loadFavorites({bool forceRefresh = false}) async {
    if (isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    final user = _client.auth.currentUser;

    if (user == null) {
      favorites.clear();
      _hasLoaded = false;
      error = 'Pengguna belum login.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('course_favorites')
          .select('course_code')
          .eq('user_id', user.id);

      favorites
        ..clear()
        ..addAll(response.map((row) => row['course_code'] as String));

      _hasLoaded = true;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String code) async {
    final normalizedCode = code.trim();
    final user = _client.auth.currentUser;

    if (normalizedCode.isEmpty || user == null) return;
    if (_pendingChanges.contains(normalizedCode)) return;

    final wasFavorite = favorites.contains(normalizedCode);

    _pendingChanges.add(normalizedCode);

    if (wasFavorite) {
      favorites.remove(normalizedCode);
    } else {
      favorites.add(normalizedCode);
    }

    error = null;
    notifyListeners();

    try {
      if (wasFavorite) {
        await _client
            .from('course_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('course_code', normalizedCode);
      } else {
        await _client
            .from('course_favorites')
            .upsert(
              {'user_id': user.id, 'course_code': normalizedCode},
              onConflict: 'user_id,course_code',
              ignoreDuplicates: true,
            );
      }
    } catch (e) {
      if (wasFavorite) {
        favorites.add(normalizedCode);
      } else {
        favorites.remove(normalizedCode);
      }

      error = e.toString();
    } finally {
      _pendingChanges.remove(normalizedCode);
      notifyListeners();
    }
  }
}
