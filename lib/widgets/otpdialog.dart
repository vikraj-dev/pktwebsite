// ═══════════════════════════════════════════════════════════════
//  otp_dialog_widget.dart
//  Full OTP flow widget — matches Homepage gold/dark theme
//
//  HOW TO USE in homepage.dart:
//  ─────────────────────────────
//  Step 1: Add this import at top of homepage.dart
//    import 'package:pktwebsite/widgets/otp_dialog_widget.dart';
//    import 'otp_service.dart'; (or your actual path)
//
//  Step 2: In _buildCustomerInfo(), replace the phone TextField with:
//    _luxuryPhoneInput()     ← new method shown at bottom of this file
//
//  Step 3: In _confirmBooking(), add OTP check BEFORE saving to Firebase:
//    Replace direct call to _saveBooking() with _verifyThenBook()
//    (exact code shown at bottom of this file)
// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:pktwebsite/widgets/otpservice.dart';

// ── Color constants (same as Homepage) ────────────────────────
const Color kBg          = Color(0xFF0A0A0A);
const Color kPanel       = Color(0xFF111111);
const Color kCardBg      = Color(0xFF161616);
const Color kGold        = Color(0xFFE8B84B);
const Color kGoldDim     = Color(0xFF9A7838);
const Color kTextPrimary = Color(0xFFF0E6C8);
const Color kTextMuted   = Color(0xFF6A5C40);
const Color kHintText    = Color(0xFFB09060);
const Color kBorder      = Color(0x33E8B84B);

// ═══════════════════════════════════════════════════════════════
//  showOtpDialog()
//  Call this function from your _confirmBooking() flow.
//
//  Returns true  → OTP verified, safe to save booking
//  Returns false → user cancelled or verification failed
// ═══════════════════════════════════════════════════════════════
Future<bool> showOtpDialog(
  BuildContext context, {
  required String phoneNumber, // raw 10-digit or +91 format
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (_) => OtpDialog(phoneNumber: phoneNumber),
  ).then((v) => v ?? false);
}

// ═══════════════════════════════════════════════════════════════
//  OtpDialog Widget
// ═══════════════════════════════════════════════════════════════
class OtpDialog extends StatefulWidget {
  final String phoneNumber;
  const OtpDialog({super.key, required this.phoneNumber});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> with SingleTickerProviderStateMixin {
  // ── OTP input (6 boxes) ──────────────────────────────────────
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // ── State ────────────────────────────────────────────────────
  bool _isSending    = false;
  bool _isVerifying  = false;
  bool _otpSent      = false;
  String? _errorMsg;
  String? _successMsg;

  // ── Resend cooldown timer ────────────────────────────────────
  int  _resendSeconds = 30;
  Timer? _resendTimer;

  // ── Animation ────────────────────────────────────────────────
  late AnimationController _shakeController;
  late Animation<double>   _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));

    // Auto-send OTP when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _shakeController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes)     f.dispose();
    super.dispose();
  }

  // ── SEND OTP ─────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    setState(() { _isSending = true; _errorMsg = null; _successMsg = null; });

    final formatted = OtpService.formatIndianPhone(widget.phoneNumber);

    await OtpService.sendOtp(
      phone: formatted,
      onCodeSent: () {
        if (!mounted) return;
        setState(() {
          _isSending  = false;
          _otpSent    = true;
          _successMsg = 'OTP sent to $formatted';
        });
        _startResendTimer();
        // Auto-focus first OTP box
        Future.delayed(const Duration(milliseconds: 300),
            () => _focusNodes[0].requestFocus());
      },
      onError: (err) {
        if (!mounted) return;
        setState(() { _isSending = false; _errorMsg = err; });
      },
      onAutoVerified: (cred) {
        // Android auto-read: fill boxes and close
        if (!mounted) return;
        Navigator.of(context).pop(true);
      },
    );
  }

  // ── VERIFY OTP ───────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showError('Enter all 6 digits.');
      return;
    }

    setState(() { _isVerifying = true; _errorMsg = null; });

    await OtpService.verifyOtp(
      smsCode: code,
      onSuccess: (UserCredential cred) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // ← booking proceeds
      },
      onError: (err) {
        if (!mounted) return;
        setState(() { _isVerifying = false; });
        _showError(err);
        _shakeController.forward(from: 0);
        _clearOtpBoxes();
      },
    );
  }

  // ── RESEND COOLDOWN ──────────────────────────────────────────
  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── HELPERS ──────────────────────────────────────────────────
  void _showError(String msg) => setState(() => _errorMsg = msg);

  void _clearOtpBoxes() {
    for (final c in _otpControllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  // ── OTP BOX NAVIGATION ───────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {}); // refresh verify button state
  }

  // ════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (_, child) {
            final dx = _shakeAnimation.value == 0
                ? 0.0
                : 8.0 * (0.5 - (_shakeAnimation.value % 0.2) / 0.2);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: kGold.withOpacity(0.08),
                  blurRadius: 40, spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildPhoneDisplay(),
                const SizedBox(height: 20),
                if (_isSending) _buildSendingState(),
                if (!_isSending && _otpSent) ...[
                  _buildOtpBoxes(),
                  const SizedBox(height: 16),
                  _buildResendRow(),
                ],
                if (!_isSending && !_otpSent && _errorMsg != null)
                  _buildRetryState(),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
                  _buildErrorBanner(),
                ],
                if (_successMsg != null && _errorMsg == null) ...[
                  const SizedBox(height: 8),
                  _buildSuccessBanner(),
                ],
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder),
        ),
        child: const Icon(Icons.verified_user_outlined, color: kGold, size: 16),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('VERIFY PHONE', style: TextStyle(
          color: kGold, fontSize: 12,
          fontWeight: FontWeight.w900, letterSpacing: 2.5,
        )),
        Text('OTP Authentication', style: TextStyle(
          color: kTextMuted, fontSize: 9, letterSpacing: 1.2,
        )),
      ]),
      const Spacer(),
      GestureDetector(
        onTap: () {
          OtpService.clearSession();
          Navigator.of(context).pop(false);
        },
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: kCardBg, borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorder),
          ),
          child: const Icon(Icons.close, color: kTextMuted, size: 14),
        ),
      ),
    ]);
  }

  // ── PHONE DISPLAY ────────────────────────────────────────────
  Widget _buildPhoneDisplay() {
    final formatted = OtpService.formatIndianPhone(widget.phoneNumber);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(children: [
        const Icon(Icons.phone_android_outlined, color: kGold, size: 14),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MOBILE NUMBER', style: TextStyle(
            color: kTextMuted, fontSize: 7,
            fontWeight: FontWeight.w700, letterSpacing: 1.8,
          )),
          const SizedBox(height: 2),
          Text(formatted, style: const TextStyle(
            color: kTextPrimary, fontSize: 14,
            fontWeight: FontWeight.w600, letterSpacing: 1.5,
          )),
        ]),
      ]),
    );
  }

  // ── SENDING STATE (spinner) ───────────────────────────────────
  Widget _buildSendingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Sending OTP...', style: TextStyle(
          color: kHintText, fontSize: 12, letterSpacing: 0.5,
        )),
      ]),
    );
  }

  // ── OTP INPUT BOXES ───────────────────────────────────────────
  Widget _buildOtpBoxes() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ENTER OTP', style: TextStyle(
        color: kGold, fontSize: 8,
        fontWeight: FontWeight.w900, letterSpacing: 2,
      )),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) => _buildOtpBox(i)),
      ),
    ]);
  }

  Widget _buildOtpBox(int index) {
    final isFilled = _otpControllers[index].text.isNotEmpty;
    return SizedBox(
      width: 42, height: 52,
      child: TextField(
        controller:   _otpControllers[index],
        focusNode:    _focusNodes[index],
        textAlign:    TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength:    1,
        style: const TextStyle(
          color: kGold, fontSize: 20,
          fontWeight: FontWeight.w900, letterSpacing: 0,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled:      true,
          fillColor:   isFilled ? kGold.withOpacity(0.08) : kCardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isFilled ? kGold : kBorder,
              width: isFilled ? 1.5 : 0.8,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isFilled ? kGold.withOpacity(0.5) : kBorder,
              width: isFilled ? 1.2 : 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kGold, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) => _onOtpChanged(v, index),
      ),
    );
  }

  // ── RESEND ROW ────────────────────────────────────────────────
  Widget _buildResendRow() {
    final canResend = _resendSeconds == 0 && !_isSending;
    return Row(children: [
      const Text("Didn't receive?", style: TextStyle(color: kTextMuted, fontSize: 11)),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: canResend ? _sendOtp : null,
        child: Text(
          canResend
              ? 'Resend OTP'
              : 'Resend in ${_resendSeconds}s',
          style: TextStyle(
            color:      canResend ? kGold : kGoldDim,
            fontSize:   11,
            fontWeight: canResend ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ),
    ]);
  }

  // ── RETRY STATE ───────────────────────────────────────────────
  Widget _buildRetryState() {
    return Center(child: GestureDetector(
      onTap: _sendOtp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.refresh, color: kGold, size: 13),
          SizedBox(width: 8),
          Text('Retry Send OTP', style: TextStyle(
            color: kGold, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.2,
          )),
        ]),
      ),
    ));
  }

  // ── ERROR / SUCCESS BANNERS ───────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x15E53935),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0x55E53935)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 13),
        const SizedBox(width: 8),
        Expanded(child: Text(_errorMsg!, style: const TextStyle(
          color: Color(0xFFEF9A9A), fontSize: 11, letterSpacing: 0.2,
        ))),
      ]),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: kBorder),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, color: kGold, size: 13),
        const SizedBox(width: 8),
        Expanded(child: Text(_successMsg!, style: const TextStyle(
          color: kHintText, fontSize: 11, letterSpacing: 0.2,
        ))),
      ]),
    );
  }

  // ── ACTION BUTTONS ────────────────────────────────────────────
  Widget _buildActionButtons() {
    final canVerify = _otpSent && _otp.length == 6 && !_isVerifying;
    return Row(children: [
      // Cancel
      Expanded(child: SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: () {
            OtpService.clearSession();
            Navigator.of(context).pop(false);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: kTextMuted,
            side: const BorderSide(color: kBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('CANCEL', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2,
          )),
        ),
      )),
      const SizedBox(width: 10),
      // Verify
      Expanded(flex: 2, child: SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: canVerify ? _verifyOtp : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canVerify ? kGold : kGold.withOpacity(0.3),
            foregroundColor: kBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(color: kBg, strokeWidth: 2))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.verified_outlined, size: 13, color: kBg),
                  SizedBox(width: 8),
                  Text('VERIFY & BOOK', style: TextStyle(
                    color: kBg, fontSize: 10,
                    fontWeight: FontWeight.w900, letterSpacing: 1.8,
                  )),
                ]),
        ),
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
//  ──────────────────────────────────────────────────────────────
//  HOW TO INTEGRATE INTO homepage.dart
//  ──────────────────────────────────────────────────────────────
//
//  STEP 1 ── Add imports at top of homepage.dart:
//  ───────────────────────────────────────────────
//  import 'otp_service.dart';
//  import 'otp_dialog_widget.dart';
//
//  ──────────────────────────────────────────────────────────────
//  STEP 2 ── Add a bool flag to _HomepageState:
//  ──────────────────────────────────────────────────────────────
//  bool _isPhoneVerified = false;
//
//  ──────────────────────────────────────────────────────────────
//  STEP 3 ── Add "Send OTP" button next to phoneController field.
//            In _buildCustomerInfo(), change the phone field to:
//  ──────────────────────────────────────────────────────────────
//
//  Row(children: [
//    Expanded(child: _luxuryInput('Phone Number', phoneController, Icons.phone_android_outlined)),
//    const SizedBox(width: 8),
//    GestureDetector(
//      onTap: () async {
//        final phone = phoneController.text.trim();
//        if (phone.isEmpty || phone.length < 10) {
//          _showLuxurySnackBar('Enter a valid 10-digit number.', isError: true);
//          return;
//        }
//        setState(() => _isPhoneVerified = false);
//        final verified = await showOtpDialog(context, phoneNumber: phone);
//        setState(() => _isPhoneVerified = verified);
//        if (verified) {
//          _showLuxurySnackBar('Phone verified ✓');
//        }
//      },
//      child: AnimatedContainer(
//        duration: const Duration(milliseconds: 200),
//        height: 44,
//        padding: const EdgeInsets.symmetric(horizontal: 12),
//        decoration: BoxDecoration(
//          color: _isPhoneVerified ? kGold.withOpacity(0.15) : kCardBg,
//          borderRadius: BorderRadius.circular(8),
//          border: Border.all(
//            color: _isPhoneVerified ? kGold : kBorder,
//            width: _isPhoneVerified ? 1.2 : 0.8,
//          ),
//        ),
//        child: Row(mainAxisSize: MainAxisSize.min, children: [
//          Icon(
//            _isPhoneVerified ? Icons.verified_outlined : Icons.send_outlined,
//            color: _isPhoneVerified ? kGold : kHintText, size: 13,
//          ),
//          const SizedBox(width: 6),
//          Text(
//            _isPhoneVerified ? 'VERIFIED' : 'SEND OTP',
//            style: TextStyle(
//              color: _isPhoneVerified ? kGold : kHintText,
//              fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.8,
//            ),
//          ),
//        ]),
//      ),
//    ),
//  ])
//
//  ──────────────────────────────────────────────────────────────
//  STEP 4 ── In _confirmBooking(), add this check at the TOP,
//            before the existing validation:
//  ──────────────────────────────────────────────────────────────
//
//  Future<void> _confirmBooking() async {
//    // ── NEW: OTP check ──────────────────────────────────────
//    if (!_isPhoneVerified) {
//      final phone = phoneController.text.trim();
//      if (phone.isEmpty || phone.length < 10) {
//        _showLuxurySnackBar('Enter a valid phone number.', isError: true);
//        return;
//      }
//      final verified = await showOtpDialog(context, phoneNumber: phone);
//      if (!verified) return; // user cancelled or wrong OTP
//      setState(() => _isPhoneVerified = true);
//    }
//    // ── EXISTING validation continues below ────────────────
//    if (nameController.text.isEmpty || ...) { ... }
//    ...
//  }
//
//  ──────────────────────────────────────────────────────────────
//  STEP 5 ── In _resetFields(), add:
//  ──────────────────────────────────────────────────────────────
//    _isPhoneVerified = false;
//    OtpService.clearSession();
//
//  ──────────────────────────────────────────────────────────────
//  STEP 6 ── pubspec.yaml — make sure these are added:
//  ──────────────────────────────────────────────────────────────
//  dependencies:
//    firebase_auth: ^4.x.x     # or latest
//    firebase_core: ^2.x.x
//
//  ──────────────────────────────────────────────────────────────
//  STEP 7 ── Firebase Console setup:
//  ──────────────────────────────────────────────────────────────
//  1. Go to Firebase Console → Authentication → Sign-in method
//  2. Enable "Phone" provider
//  3. For testing: Add test phone numbers under "Phone numbers for testing"
//     e.g., +91 9999999999 → OTP: 123456
// ═══════════════════════════════════════════════════════════════