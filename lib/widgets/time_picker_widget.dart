import 'package:flutter/material.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // --- LUXURY GOLD & BLACK THEME ---
    final Color kPremiumBlack = const Color(0xFF121212); // Deep Obsidian
    final Color kLuxuryGold = const Color(0xFFD4AF37);  // Classic Gold
    final Color kGoldLight = const Color(0xFFFFD700);   // Vibrant Gold for accents
    final Color kTextWhite = const Color(0xFFFFFFFF);   // Pure White for contrast

    return Expanded(
      child: InkWell(
        onTap: () async {
          // 🔹 Before opening picker
          FocusManager.instance.primaryFocus?.unfocus();

          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark( // Dark theme for luxury picker
                    primary: kLuxuryGold,
                    onPrimary: kPremiumBlack,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: kTextWhite,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: kLuxuryGold, // Button text color
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          // 🔹 IMPORTANT: After dialog closes
          Future.delayed(const Duration(milliseconds: 100), () {
            FocusManager.instance.primaryFocus?.unfocus();
          });

          if (picked != null) {
            onTimeSelected(picked);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: size.height * 0.062, 
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            // Luxury Gradient Background
            gradient: LinearGradient(
              colors: selectedTime == null 
                  ? [const Color(0xFF2C2C2C), kPremiumBlack] 
                  : [const Color(0xFF1A1A1A), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size.height * 0.017),
            border: Border.all(
              color: selectedTime == null ? Colors.white12 : kLuxuryGold,
              width: 1.5,
            ),
            boxShadow: selectedTime == null ? [] : [
              BoxShadow(
                color: kLuxuryGold.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: size.height * 0.022,
                color: selectedTime == null ? Colors.grey : kGoldLight,
              ),
              SizedBox(width: size.height * 0.015),
              Flexible(
                child: Text(
                  selectedTime == null
                      ? 'Select Time'
                      : selectedTime!.format(context),
                  style: TextStyle(
                    fontSize: size.height * 0.017,
                    fontWeight: FontWeight.w700, // Thicker font for luxury feel
                    letterSpacing: 0.5,
                    color: selectedTime == null ? Colors.grey : kGoldLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}