import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final isLoading = false.obs;
  final isEmailVerified = false.obs;
  final isSyncing = false.obs;

  bool get isLoggedIn => firebaseUser.value != null;
  String get userEmail => firebaseUser.value?.email ?? '';
  String get userId => firebaseUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChange);
  }

  void _handleAuthChange(User? user) {
    if (user != null) {
      isEmailVerified.value = user.emailVerified;
    } else {
      isEmailVerified.value = false;
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
          email: email.trim(), password: password.trim());
      
      // Save user profile to Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email.trim(),
        'storeName': storeName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save store name locally
      final sc = Get.find<SettingsController>();
      await sc.saveStoreProfile(
        name: storeName,
        phone: '',
        address: '',
        email: email.trim(),
        taxNumber: '',
      );

      await cred.user?.sendEmailVerification();
      isEmailVerified.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
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
          email: email.trim(), password: password.trim());
      isEmailVerified.value = cred.user?.emailVerified ?? false;
      if (cred.user?.emailVerified == true) {
        await _loadUserProfile(cred.user!.uid);
        await _syncOnLogin();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final storeName = data['storeName'] as String? ?? '';
        final storeEmail = data['email'] as String? ?? '';
        if (storeName.isNotEmpty) {
          final sc = Get.find<SettingsController>();
          if (sc.storeName.value.isEmpty) {
            await sc.saveStoreProfile(
              name: storeName,
              phone: sc.storePhone.value,
              address: sc.storeAddress.value,
              email: storeEmail,
              taxNumber: sc.storeTaxNumber.value,
            );
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
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> logout() async {
    await DatabaseService.clearAllData(); // Clears local cache only
    await _auth.signOut();
  }

  Future<bool> _checkNetwork() async {
    final connectivityResults = await (Connectivity().checkConnectivity());
    if (connectivityResults.contains(ConnectivityResult.none)) {
      _showError(_authMessage('network-request-failed'));
      return false;
    }
    return true;
  }

  Future<void> sendVerificationEmail() async {
    if (!await _checkNetwork()) return;
    try {
      await _auth.currentUser?.sendEmailVerification();
      Get.snackbar(
        'success'.tr,
        'verification_sent'.tr,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {}
  }

  Future<void> checkEmailVerified() async {
    if (!await _checkNetwork()) return;
    isLoading.value = true;
    try {
      await _auth.currentUser?.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      isEmailVerified.value = verified;
      if (verified && _auth.currentUser != null) {
        await _loadUserProfile(_auth.currentUser!.uid);
        await _syncOnLogin();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
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
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (!await _checkNetwork()) return false;
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;
      
      // Re-authenticate
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      
      // Update password
      await user.updatePassword(newPassword);
      Get.snackbar(
        'success'.tr,
        'Password updated successfully',
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
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
      
      // Re-authenticate
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete auth account
      await user.delete();
      
      await DatabaseService.clearAllData();
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(_authMessage(e.code));
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
        return isAr ? 'البريد الإلكتروني مستخدم بالفعل' : 'Email already in use';
      case 'weak-password':
        return isAr ? 'كلمة المرور ضعيفة (6 أحرف على الأقل)' : 'Password too weak (min 6 chars)';
      case 'invalid-email':
        return isAr ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
      case 'network-request-failed':
        return isAr ? 'تحقق من اتصال الإنترنت' : 'Check your internet connection';
      case 'too-many-requests':
        return isAr ? 'محاولات كثيرة، حاول لاحقاً' : 'Too many attempts, try later';
      case 'invalid-credential':
        return isAr ? 'البريد أو كلمة المرور غير صحيحة' : 'Invalid email or password';
      default:
        return isAr ? 'حدث خطأ، حاول مرة أخرى' : 'An error occurred, try again';
    }
  }
}
