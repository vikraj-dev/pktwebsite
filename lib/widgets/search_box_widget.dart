import 'package:flutter/material.dart';

class SearchBoxWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPickup;
  final FocusNode? focusNode;
  // 🔥 Intha rendu parameters kandippa venum
  final Function(String, bool) onTextChanged; 
  final Function(String, String, bool) onPlaceSelected; 
  final List<dynamic> suggestions;

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
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => onTextChanged(value, isPickup),
        ),
        if (suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final p = suggestions[index];
                return ListTile(
                  title: Text(p['description']),
                  onTap: () => onPlaceSelected(p['place_id'], p['description'], isPickup),
                );
              },
            ),
          ),
      ],
    );
  }
}