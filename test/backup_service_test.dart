import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cryptographic Core Tests', () {
    test('PBKDF2-HMAC-SHA256 and AES-256-GCM encryption/decryption roundtrip', () async {
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 1000,
        bits: 256,
      );
      final aesGcm = AesGcm.with256bits();

      const password = 'StrongPassword123!';
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );

      const testPayload = '{"app":"AccountBook","balance":5000}';
      final plaintext = utf8.encode(testPayload);
      final nonce = aesGcm.newNonce();

      final secretBox = await aesGcm.encrypt(
        plaintext,
        secretKey: secretKey,
        nonce: nonce,
      );

      // Decrypt with correct key
      final decryptedBytes = await aesGcm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      expect(utf8.decode(decryptedBytes), equals(testPayload));

      // Decrypt with wrong password fails
      final wrongKey = await pbkdf2.deriveKeyFromPassword(
        password: 'WrongPassword!',
        nonce: salt,
      );
      expect(
        () => aesGcm.decrypt(secretBox, secretKey: wrongKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );

      // Tampered ciphertext fails
      final tamperedCiphertext = List<int>.from(secretBox.cipherText);
      tamperedCiphertext[0] ^= 0xFF;
      final tamperedBox = SecretBox(
        tamperedCiphertext,
        nonce: secretBox.nonce,
        mac: secretBox.mac,
      );
      expect(
        () => aesGcm.decrypt(tamperedBox, secretKey: secretKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });

  group('BackupService Container & Decryption Tests', () {
    const validPassword = 'SecureBackupPass123';

    Future<Uint8List> createMockBackupBytes({
      required String password,
      int iterations = 1000,
      bool corruptMagic = false,
      bool corruptCiphertext = false,
      bool corruptMac = false,
    }) async {
      final aesGcm = AesGcm.with256bits();
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      );

      final salt = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160];
      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );

      final payload = {
        'magic': corruptMagic ? 'WRONG_MAGIC' : BackupService.magicHeader,
        'version': 1,
        'app': 'Hasibny Account Book',
        'exportedAt': DateTime.now().toIso8601String(),
        'customers': [
          {'id': 1, 'name': 'Ahmed Ali', 'phoneNumber': '777123456', 'currencyCode': 'YER'}
        ],
        'transactions': [
          {'id': 1, 'amount': 1500.0, 'type': 'got', 'description': 'Payment', 'currencyCode': 'YER', 'customerId': 1}
        ],
        'merchants': [],
        'invoices': [],
        'shortages': [],
      };

      final plaintext = utf8.encode(jsonEncode(payload));
      final nonce = aesGcm.newNonce();
      final box = await aesGcm.encrypt(plaintext, secretKey: secretKey, nonce: nonce);

      var ciphertext = box.cipherText;
      if (corruptCiphertext) {
        final tampered = List<int>.from(ciphertext);
        tampered[0] ^= 0xAA;
        ciphertext = tampered;
      }

      var macBytes = box.mac.bytes;
      if (corruptMac) {
        final tampered = List<int>.from(macBytes);
        tampered[0] ^= 0xBB;
        macBytes = tampered;
      }

      final container = {
        'magic': corruptMagic ? 'WRONG_MAGIC' : BackupService.magicHeader,
        'version': 1,
        'kdf': 'PBKDF2-HMAC-SHA256',
        'iterations': iterations,
        'cipher': 'AES-256-GCM',
        'salt': base64Encode(salt),
        'nonce': base64Encode(box.nonce),
        'mac': base64Encode(macBytes),
        'ciphertext': base64Encode(ciphertext),
        'exportedAt': payload['exportedAt'],
      };

      return Uint8List.fromList(utf8.encode(jsonEncode(container)));
    }

    test('decryptBackupData succeeds with correct password', () async {
      final bytes = await createMockBackupBytes(password: validPassword);
      final result = await BackupService.decryptBackupData(
        backupBytes: bytes,
        password: validPassword,
      );

      expect(result['magic'], equals(BackupService.magicHeader));
      expect(result['customers'], isA<List>());
      expect((result['customers'] as List).length, equals(1));
      expect(result['transactions'], isA<List>());
      expect((result['transactions'] as List).length, equals(1));
    });

    test('decryptBackupData rejects empty or short password', () async {
      final bytes = await createMockBackupBytes(password: validPassword);
      expect(
        () => BackupService.decryptBackupData(backupBytes: bytes, password: '   '),
        throwsA(isA<BackupException>()),
      );
    });

    test('decryptBackupData fails on wrong password', () async {
      final bytes = await createMockBackupBytes(password: validPassword);
      expect(
        () => BackupService.decryptBackupData(backupBytes: bytes, password: 'IncorrectPassword'),
        throwsA(isA<BackupException>()),
      );
    });

    test('decryptBackupData rejects tampered ciphertext or altered MAC', () async {
      final tamperedCipherBytes = await createMockBackupBytes(
        password: validPassword,
        corruptCiphertext: true,
      );
      expect(
        () => BackupService.decryptBackupData(backupBytes: tamperedCipherBytes, password: validPassword),
        throwsA(isA<BackupException>()),
      );

      final tamperedMacBytes = await createMockBackupBytes(
        password: validPassword,
        corruptMac: true,
      );
      expect(
        () => BackupService.decryptBackupData(backupBytes: tamperedMacBytes, password: validPassword),
        throwsA(isA<BackupException>()),
      );
    });

    test('decryptBackupData rejects invalid magic header', () async {
      final wrongMagicBytes = await createMockBackupBytes(
        password: validPassword,
        corruptMagic: true,
      );
      expect(
        () => BackupService.decryptBackupData(backupBytes: wrongMagicBytes, password: validPassword),
        throwsA(isA<BackupException>()),
      );
    });
  });
}
