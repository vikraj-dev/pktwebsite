import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    // --- PROFESSIONAL COLORS ---
    final Color kCardLight = const Color(0xFFF1F5F9); // Soft Slate Gray
    final Color kActiveBlue = const Color(0xFFE0E7FF); // Very Light Indigo
    final Color kIconColor = const Color(0xFF64748B); // Muted Blue-Gray
    final Color kTextColor = const Color(0xFF1E293B); // Deep Navy

    return Expanded(
      child: InkWell(
        onTap: () async {
  // 🔹 Remove focus BEFORE opening
  FocusManager.instance.primaryFocus?.unfocus();

  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(DateTime.now().year + 5),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF2563EB),
            onSurface: kTextColor,
          ),
        ),
        child: child!,
      );
    },
  );

  // 🔹 Remove focus AGAIN after dialog closes
  Future.delayed(const Duration(milliseconds: 100), () {
    FocusManager.instance.primaryFocus?.unfocus();
  });

  if (picked != null) {
    onDateSelected(picked);
  }
},

        child: Container(
          height: size.height * 0.062, // Uniform height
          padding:  EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selectedDate == null ? kCardLight : kActiveBlue,
            borderRadius: BorderRadius.circular(size.height*0.017),
            border: Border.all(
              color: selectedDate == null ? Colors.black12 : const Color(0xFFC7D2FE),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded, 
                size: size.height*0.02, 
                color: selectedDate == null ? kIconColor : const Color(0xFF4F46E5)
              ),
               SizedBox(width: size.height*0.015),
              Flexible(
                child: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('dd MMM yyyy').format(selectedDate!),
                  style: TextStyle(
                    fontSize: size.height*0.017,
                    fontWeight: FontWeight.w600,
                    color: selectedDate == null ? kIconColor : const Color(0xFF4338CA),
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