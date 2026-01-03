import 'package:encrypt/encrypt.dart';

/// AES-256 Encryption Helper for securing sensitive data
/// Uses AES-256-CBC mode for encryption/decryption
class EncryptionHelper {
  // 32-byte key for AES-256 (256 bits)
  // In production, this should be securely stored and managed
  // Consider using flutter_secure_storage or environment variables
  static const String _keyString = 'FoodOrderingApp2024SecureKey1234';

  // 16-byte initialization vector
  static const String _ivString = 'FoodOrderIV12345';

  static final Key _key = Key.fromUtf8(_keyString);
  static final IV _iv = IV.fromUtf8(_ivString);
  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypts a plain text string using AES-256-CBC
  /// Returns Base64 encoded encrypted string
  ///
  /// Example:
  /// ```dart
  /// String encrypted = EncryptionHelper.encryptData('123 Main Street');
  /// ```
  static String encryptData(String plainText) {
    if (plainText.isEmpty) {
      return '';
    }

    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return '';
    }
  }

  /// Decrypts a Base64 encoded encrypted string using AES-256-CBC
  /// Returns the original plain text
  ///
  /// Example:
  /// ```dart
  /// String decrypted = EncryptionHelper.decryptData(encryptedAddress);
  /// ```
  static String decryptData(String cipherText) {
    if (cipherText.isEmpty) {
      return '';
    }

    try {
      final encrypted = Encrypted.fromBase64(cipherText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }

  /// Encrypts a Map of data, encrypting specified sensitive fields
  /// Returns a new Map with encrypted values for specified fields
  ///
  /// Example:
  /// ```dart
  /// Map<String, dynamic> data = {'address': '123 Main St', 'phone': '555-1234'};
  /// Map<String, dynamic> encrypted = EncryptionHelper.encryptFields(
  ///   data,
  ///   ['address', 'phone']
  /// );
  /// ```
  static Map<String, dynamic> encryptFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) {
    final Map<String, dynamic> result = Map.from(data);

    for (String field in sensitiveFields) {
      if (result.containsKey(field) && result[field] is String) {
        result['encrypted${_capitalize(field)}'] = encryptData(result[field]);
        result.remove(field);
      }
    }

    return result;
  }

  /// Helper to capitalize first letter of a string
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Validates that the encryption is working correctly
  /// Returns true if test passes
  static bool validateEncryption() {
    const testString = 'Test encryption validation';
    final encrypted = encryptData(testString);
    final decrypted = decryptData(encrypted);
    return decrypted == testString;
  }
}
