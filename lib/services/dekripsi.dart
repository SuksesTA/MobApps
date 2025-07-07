import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class AESGCMDecryptor {
  final SecretKey _key;
  final AesGcm _algorithm;

  AESGCMDecryptor.fromBase64Key(String base64Key)
      : _key = SecretKey(base64Decode(base64Key)),
        _algorithm = AesGcm.with128bits(); // ⬅️ pakai AES-GCM 128-bit

  Future<String?> decryptBase64(String base64Cipher) async {
    try {
      final raw = base64Decode(base64Cipher);
      if (raw.length < 28) throw Exception("Payload terlalu pendek");

      final nonce = raw.sublist(0, 12);
      final ct_tag = raw.sublist(12);

      final ciphertext = ct_tag.sublist(0, ct_tag.length - 16);
      final tag = ct_tag.sublist(ct_tag.length - 16);

      debugPrint("📥 Base64 Payload : $base64Cipher");
      debugPrint(
          "🔓 Nonce (hex)     : ${nonce.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
      debugPrint("🔐 Ciphertext len  : ${ciphertext.length} byte");
      debugPrint(
          "🔐 Tag (hex)       : ${tag.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
      debugPrint(
          "🗝️ Key (hex)        : ${(await _key.extractBytes()).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

      final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac(tag));
      final clearText =
          await _algorithm.decrypt(secretBox, secretKey: _key, aad: <int>[]);
      return utf8.decode(clearText);
    } catch (e) {
      debugPrint("❌ AES-GCM Decryption failed: $e");
      return null;
    }
  }
}
