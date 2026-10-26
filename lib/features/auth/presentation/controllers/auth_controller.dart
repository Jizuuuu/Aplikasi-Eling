import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/user_account.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final currentUserProvider = StateProvider<UserAccount?>((ref) => null);

class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final DatabaseHelper _dbHelper;
  final Ref _ref;

  AuthNotifier(this._dbHelper, this._ref) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final userMap = await _dbHelper.authenticateUser(email, password);
      if (userMap != null) {
        final user = UserAccount.fromMap(userMap);
        _ref.read(currentUserProvider.notifier).state = user;
        state = const AuthState(isLoading: false);
        return true;
      } else {
        state = const AuthState(
          isLoading: false,
          errorMessage: 'Email atau password salah. Silakan coba lagi.',
        );
        return false;
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan login: $e',
      );
      return false;
    }
  }

  void logout() {
    _ref.read(currentUserProvider.notifier).state = null;
    state = const AuthState();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthNotifier(dbHelper, ref);
});
