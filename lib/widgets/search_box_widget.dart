import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD — SearchBoxWidget
//  Fix: Instant tap on suggestions (no delay)
// ══════════════════════════════════════════════════════════════

class SearchBoxWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPickup;
  final FocusNode? focusNode;
  final Function(String, bool) onTextChanged;
  final Function(String, String, bool) onPlaceSelected;
  final List<dynamic> suggestions;

  // ── Luxury Colors ─────────────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);

  const SearchBoxWidget({
    super.key,
    required this.controller,
    required this.onTextChanged,
    required this.onPlaceSelected,
    required this.suggestions,
    this.hint = '',
    this.isPickup = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Input Field ──────────────────────────────────────
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: suggestions.isNotEmpty
                ? const BorderRadius.vertical(top: Radius.circular(8))
                : BorderRadius.circular(8),
            border: Border.all(color: kBorder),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                isPickup
                    ? Icons.radio_button_checked_outlined
                    : Icons.location_on_outlined,
                color: isPickup ? kGold : kGoldDim,
                size: 15,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: kTextMuted, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) => onTextChanged(value, isPickup),
          ),
        ),

        // ── Suggestions Dropdown ─────────────────────────────
        if (suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 210),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border.all(color: kBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: kBorder,
              ),
              itemBuilder: (context, index) {
                final p = suggestions[index];
                final String description = p['description'] ?? '';

                // Split: bold first part, muted second part
                final parts = description.split(',');
                final String mainText = parts.first.trim();
                final String subText =
                    parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

                return GestureDetector(
                  // ✅ KEY FIX: opaque catches tap instantly,
                  //    no scroll-vs-tap conflict
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // ✅ Clear suggestions & set text FIRST (instant UI)
                    controller.text = description;
                    // Then fire the callback
                    onPlaceSelected(
                        p['place_id'], description, isPickup);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        // Pin icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: kGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: kBorder),
                          ),
                          child: Icon(
                            isPickup
                                ? Icons.trip_origin_rounded
                                : Icons.place_outlined,
                            color: kGoldDim,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mainText,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subText,
                                  style: const TextStyle(
                                    color: kTextMuted,
                                    fontSize: 10,
                                    letterSpacing: 0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.north_west_rounded,
                            color: kTextMuted, size: 11),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}