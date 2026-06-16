// ═══════════════════════════════════════════════════════════════
//  otp_service.dart
//  Firebase Phone Auth — OTP send & verify logic
//  Usage: import this file, call OtpService.sendOtp() then verifyOtp()
// ═══════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';

class OtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Holds the verificationId from Firebase after OTP is sent ──
  static String? _verificationId;
  static int?    _resendToken;

  // ════════════════════════════════════════════════════════════
  //  SEND OTP
  //  Call this when user taps "Send OTP"
  //
  //  phone          → must include country code e.g. "+919876543210"
  //  onCodeSent     → called when OTP SMS is sent successfully
  //  onError        → called with error message string
  //  onAutoVerified → (optional) called if Firebase auto-reads the OTP
  // ════════════════════════════════════════════════════════════
  static Future<void> sendOtp({
    required String phone,
    required void Function() onCodeSent,
    required void Function(String error) onError,
    void Function(UserCredential cred)? onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,

        // ── Timeout for auto-retrieval (Android only) ──────
        timeout: const Duration(seconds: 60),

        // ── Called when SMS is sent ────────────────────────
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken    = resendToken;
          onCodeSent();
        },

        // ── Auto verification (Android SMS retrieval API) ──
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerified != null) {
            try {
              final cred = await _auth.signInWithCredential(credential);
              onAutoVerified(cred);
            } catch (e) {
              onError('Auto-verify failed: $e');
            }
          }
        },

        // ── Firebase rejected the request ─────────────────
        verificationFailed: (FirebaseAuthException e) {
          String msg;
          switch (e.code) {
            case 'invalid-phone-number':
              msg = 'Invalid phone number format.';
              break;
            case 'too-many-requests':
              msg = 'Too many attempts. Try again later.';
              break;
            case 'quota-exceeded':
              msg = 'SMS quota exceeded. Contact support.';
              break;
            default:
              msg = e.message ?? 'OTP send failed. Try again.';
          }
          onError(msg);
        },

        // ── Auto-retrieval timed out (normal on iOS / web) ─
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },

        // ── Resend token (speeds up resend on Android) ────
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError('Unexpected error: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  //  VERIFY OTP
  //  Call this when user enters the 6-digit OTP and taps "Verify"
  //
  //  smsCode    → 6 digit code entered by user
  //  onSuccess  → called with UserCredential on success
  //  onError    → called with error message string
  // ════════════════════════════════════════════════════════════
  static Future<void> verifyOtp({
    required String smsCode,
    required void Function(UserCredential cred) onSuccess,
    required void Function(String error) onError,
  }) async {
    if (_verificationId == null) {
      onError('Session expired. Please send OTP again.');
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode:        smsCode.trim(),
      );
      final userCred = await _auth.signInWithCredential(credential);
      onSuccess(userCred);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'invalid-verification-code':
          msg = 'Wrong OTP. Please check and try again.';
          break;
        case 'session-expired':
          msg = 'OTP expired. Please request a new one.';
          _verificationId = null;
          break;
        case 'credential-already-in-use':
          msg = 'This phone is already linked to another account.';
          break;
        default:
          msg = e.message ?? 'Verification failed. Try again.';
      }
      onError(msg);
    } catch (e) {
      onError('Unexpected error: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════

  /// Clears stored verificationId (call on dialog close / reset)
  static void clearSession() {
    _verificationId = null;
    _resendToken    = null;
  }

  /// Returns true if a verificationId is currently stored
  static bool get hasActiveSession => _verificationId != null;

  /// Formats a 10-digit Indian number to E.164 (+91XXXXXXXXXX)
  /// Pass any format — strips spaces, dashes, leading zeros
  static String formatIndianPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    if (digits.length == 10) return '+91$digits';
    return '+$digits'; // fallback — pass as-is with +
  }
}