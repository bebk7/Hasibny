import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/settings_controller.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  emailUnverified,
}

class AuthController extends GetxController {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  late final Rx<User?> firebaseUser;
  final isLoading = false.obs;
  final isCheckingVerification = false.obs;
  final isEmailVerified = false.obs;
  final isSyncing = false.obs;
  final isGuestMode = true.obs;
  final Rx<AuthState> authState = AuthState.initial.obs;

  bool get isLoggedIn => firebaseUser.value != null;
  bool get canAccessApp => (isLoggedIn && isEmailVerified.value) || isGuestMode.value;
  String get userEmail => firebaseUser.value?.email ?? '';
  String get userId => firebaseUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    try {
      final currentUser = _auth.currentUser;
      firebaseUser = Rx<User?>(currentUser);

      _loadGuestMode();

      if (currentUser != null) {
        isGuestMode.value = false;
        isEmailVerified.value = currentUser.emailVerified;
        authState.value = currentUser.emailVerified
            ? AuthState.authenticated
            : AuthState.emailUnverified;
        // Asynchronously refresh user status from server on startup
        _refreshUserOnStartup();
      } else {
        authState.value = AuthState.unauthenticated;
      }

      firebaseUser.bindStream(_auth.userChanges());
      ever(firebaseUser, _handleAuthChange);
    } catch (_) {
      firebaseUser = Rx<User?>(null);
      authState.value = AuthState.unauthenticated;
      isGuestMode.value = true;
    }
  }

  Future<void> _loadGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_auth.currentUser == null) {
        isGuestMode.value = prefs.getBool('guest_mode') ?? true;
      } else {
        isGuestMode.value = false;
      }
    } catch (_) {
      isGuestMode.value = true;
    }
  }

  Future<void> continueAsGuest() async {
    isGuestMode.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guest_mode', true);
    } catch (_) {}
  }

  Future<void> _refreshUserOnStartup() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshed = _auth.currentUser;
        if (refreshed != null) {
          firebaseUser.value = refreshed;
          final verified = refreshed.emailVerified;
          isEmailVerified.value = verified;
          isGuestMode.value = false;
          authState.value = verified
              ? AuthState.authenticated
              : AuthState.emailUnverified;
          if (verified) {
            await _loadUserProfile(refreshed.uid);
            await _syncOnLogin();
          }
        }
      }
    } catch (e) {
      debugPrint('Startup user reload notice: $e');
    }
  }

  void _handleAuthChange(User? user) {
    if (user != null) {
      isGuestMode.value = false;
      isEmailVerified.value = user.emailVerified;
      authState.value = user.emailVerified
          ? AuthState.authenticated
          : AuthState.emailUnverified;
    } else {
      isEmailVerified.value = false;
      authState.value = AuthState.unauthenticated;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String storeName,
  }) async {
    if (!await _checkNetwork()) return false;
    isLoading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user == null) {
        _showError(_authMessage('unknown-error'));
        return false;
      }

      // Save user profile to Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email.trim(),
          'storeName': storeName.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Warning: Firestore store profile save deferred: $e');
      }

      // Save store name locally
      try {
        final sc = Get.find<SettingsController>();
        await sc.saveStoreProfile(
          name: storeName.trim(),
          phone: '',
          address: '',
          email: email.trim(),
          taxNumber: '',
        );
      } catch (e) {
        debugPrint('Warning: Local store profile save error: $e');
      }

      // Send verification email ONCE on registration
      try {
        await user.sendEmailVerification();
        Get.snackbar(
          'verify_email'.tr,
          'verification_sent'.tr,
          backgroundColor: AppTheme.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } catch (e) {
        debugPrint('Warning: Email verification send error on register: $e');
      }

      firebaseUser.value = user;
      isEmailVerified.value = false;
      isGuestMode.value = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guest_mode', false);
      authState.value = AuthState.emailUnverified;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during registration: [${e.code}] ${e.message}');
      _showError(_authMessage(e.code));
      return false;
    } catch (e) {
      debugPrint('General error during registration: $e');
      _showError(_authMessage('unknown-error'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!await _checkNetwork()) return false;
    isLoading.value = true;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      final verified = user?.emailVerified ?? false;
      firebaseUser.value = user;
      isEmailVerified.value = verified;
      isGuestMode.value = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guest_mode', false);
      authState.value =
          verified ? AuthState.authenticated : AuthState.emailUnverified;

      if (verified && user != null) {
        await _loadUserProfile(user.uid);
        await _syncOnLogin();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during login: [${e.code}] ${e.message}');
      _showError(_authMessage(e.code));
      return false;
    } catch (e) {
      debugPrint('General error during login: $e');
      _showError(_authMessage('unknown-error'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final storeName = data['storeName'] as String? ?? '';
          final storeEmail = data['email'] as String? ?? '';
          if (storeName.isNotEmpty) {
            final sc = Get.find<SettingsController>();
            if (sc.storeName.value.isEmpty) {
              await sc.saveStoreProfile(
                name: storeName,
                phone: sc.storePhone.value,
                address: sc.storeAddress.value,
                email: storeEmail.isNotEmpty ? storeEmail : sc.storeEmail.value,
                taxNumber: sc.storeTaxNumber.value,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _syncOnLogin() async {
    isSyncing.value = true;
    try {
      final localCount = (await DatabaseService.getAllCustomers()).length;
      final hasRemote = await SyncService.hasRemoteData();
      if (localCount == 0 && hasRemote) {
        await SyncService.downloadAll();
      } else if (localCount > 0 && !hasRemote) {
        SyncService.uploadAll();
      }
    } catch (e) {
      debugPrint('Sync on login non-fatal error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      firebaseUser.value = null;
      isEmailVerified.value = false;
      authState.value = AuthState.unauthenticated;
      isGuestMode.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guest_mode', true);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<bool> _checkNetwork() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasNoConnection = connectivityResults.isEmpty ||
          (connectivityResults.length == 1 &&
              connectivityResults.first == ConnectivityResult.none) ||
          connectivityResults.every((r) => r == ConnectivityResult.none);
      if (hasNoConnection) {
        _showError(_authMessage('network-request-failed'));
        return false;
      }
    } catch (_) {}
    return true;
  }

  Future<bool> sendVerificationEmail() async {
    if (!await _checkNetwork()) return false;
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError(_authMessage('user-not-found'));
        return false;
      }
      await user.sendEmailVerification();
      Get.snackbar(
        'success'.tr,
        'verification_sent'.tr,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
      return false;
    } catch (_) {
      _showError(_authMessage('unknown-error'));
      return false;
    }
  }

  Future<void> checkEmailVerified({bool silent = false}) async {
    if (!silent) {
      if (!await _checkNetwork()) return;
      isCheckingVerification.value = true;
    }
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = _auth.currentUser;
        final verified = refreshedUser?.emailVerified ?? false;
        firebaseUser.value = refreshedUser;
        isEmailVerified.value = verified;

        if (verified) {
          authState.value = AuthState.authenticated;
          isGuestMode.value = false;
          await _loadUserProfile(refreshedUser!.uid);
          await _syncOnLogin();
          Get.snackbar(
            'success'.tr,
            'email_verified_success'.tr,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        } else if (!silent) {
          Get.snackbar(
            'info'.tr,
            'email_not_verified_yet'.tr,
            backgroundColor: const Color(0xFF1976D2),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
      } else if (!silent) {
        _showError(_authMessage('user-not-found'));
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      if (!silent) {
        _showError(_authMessage('unknown-error'));
      }
    } finally {
      if (!silent) {
        isCheckingVerification.value = false;
      }
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      _showError(_authMessage('invalid-email'));
      return;
    }
    if (!await _checkNetwork()) return;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        'success'.tr,
        'password_reset_sent'.tr,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
    } catch (_) {
      _showError(_authMessage('unknown-error'));
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (!await _checkNetwork()) return false;
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      // Re-authenticate
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
      Get.snackbar(
        'success'.tr,
        'password_updated_success'.tr,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
      return false;
    } catch (_) {
      _showError(_authMessage('unknown-error'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    if (!await _checkNetwork()) return false;
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      final cred =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (e) {
        debugPrint('Firestore user doc delete error: $e');
      }

      await user.delete();
      await DatabaseService.clearAllData();
      firebaseUser.value = null;
      isEmailVerified.value = false;
      isGuestMode.value = true;
      authState.value = AuthState.unauthenticated;
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
      return false;
    } catch (_) {
      _showError(_authMessage('unknown-error'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  String _authMessage(String code) {
    final isAr = Get.locale?.languageCode == 'ar';
    switch (code) {
      case 'user-not-found':
        return isAr ? 'البريد الإلكتروني غير مسجل' : 'Email not registered';
      case 'wrong-password':
        return isAr ? 'كلمة المرور غير صحيحة' : 'Incorrect password';
      case 'email-already-in-use':
        return isAr
            ? 'البريد الإلكتروني مستخدم بالفعل'
            : 'Email already in use';
      case 'weak-password':
        return isAr
            ? 'كلمة المرور ضعيفة (6 أحرف على الأقل)'
            : 'Password too weak (min 6 chars)';
      case 'invalid-email':
        return isAr ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
      case 'network-request-failed':
        return isAr
            ? 'تحقق من اتصال الإنترنت'
            : 'Check your internet connection';
      case 'too-many-requests':
        return isAr
            ? 'محاولات كثيرة، يرجى الانتظار دقيقة والمحاولة لاحقاً'
            : 'Too many attempts, please wait a moment';
      case 'invalid-credential':
        return isAr
            ? 'البريد أو كلمة المرور غير صحيحة'
            : 'Invalid email or password';
      case 'user-disabled':
        return isAr
            ? 'تم تعطيل هذا الحساب'
            : 'This account has been disabled';
      case 'operation-not-allowed':
        return isAr
            ? 'تسجيل الدخول بالبريد غير مفعل في Firebase'
            : 'Email/password sign-in is not enabled in Firebase';
      case 'requires-recent-login':
        return isAr
            ? 'يرجى إعادة تسجيل الدخول للمتابعة'
            : 'Please re-authenticate and try again';
      case 'channel-error':
        return isAr
            ? 'يرجى إدخال جميع الحقول المطلوبة'
            : 'Please fill in all required fields';
      default:
        return isAr ? 'حدث خطأ، حاول مرة أخرى' : 'An error occurred, try again';
    }
  }
}
