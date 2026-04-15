import 'package:flutter/material.dart';

class TarifPage extends StatefulWidget {
  final Key? tarifkey;
  TarifPage({super.key, this.tarifkey});

  @override
  State<TarifPage> createState() => _TarifPageState();
}

class _TarifPageState extends State<TarifPage> {
  String selectedTarif = 'oneway';
  List<bool> isHovering = [false, false, false];

  // Images logic (Using placeholder styles if assets are not found)
  final List<String> onewayImages = [
    'assets/sedanwhite.png',
    'assets/sedan.png',
    'assets/mini.png',
  ];

  final List<String> roundtripImages = [
    'assets/sedanwhite.png',
    'assets/sedan.png',
    'assets/mini.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.tarifkey,
      width: double.infinity,
      color: const Color(0xFFF8FAFC), // Light Slate Background
      child: Column(
        children: [
          const SizedBox(height: 80),

          // --- LUXURY TOGGLE SELECTOR ---
          _buildTarifSelector(),

          const SizedBox(height: 60),

          // --- HEADER & DESCRIPTION ---
          Text(
            selectedTarif == 'oneway' ? 'Oneway Special' : 'Roundtrip Premium',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                selectedTarif == 'oneway'
                    ? 'Experience premium one-way travel. Pay only for the drop-off distance. No return charges. Simple, transparent, and luxury.'
                    : 'The ultimate round-trip experience. Your driver waits for you while you finish your work. Perfect for outstation travel.',
                style: TextStyle(fontSize: 17, color: Colors.blueGrey.shade600, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 80),

          // --- CAR PRICING GRID ---
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1100) {
                return Column(
                  children: List.generate(3, (index) => _buildLuxuryCarCard(index, true)),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _buildLuxuryCarCard(index, false)),
                );
              }
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Custom Premium Toggle Button
  Widget _buildTarifSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('oneway', 'Oneway Tarif'),
          _buildToggleButton('roundtrip', 'Roundtrip Tarif'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String type, String label) {
    bool isSelected = selectedTarif == type;
    return InkWell(
      onTap: () => setState(() => selectedTarif = type),
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF134E4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF134E4A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryCarCard(int index, bool isMobile) {
    String carName;
    String price;
    if (index == 0) {
      carName = 'Mini Comfort';
      price = selectedTarif == 'oneway' ? '15' : '14';
    } else if (index == 1) {
      carName = 'Premium Sedan';
      price = selectedTarif == 'oneway' ? '14' : '13';
    } else {
      carName = 'Luxury SUV';
      price = selectedTarif == 'oneway' ? '18' : '16';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovering[index] = true),
        onExit: (_) => setState(() => isHovering[index] = false),
        child: AnimatedScale(
          scale: isHovering[index] ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: isMobile ? 350 : 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isHovering[index] ? 0.1 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Vehicle Image
                Container(
                  height: 160,
                  width: 260,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(selectedTarif == 'oneway' ? onewayImages[index] : roundtripImages[index]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Details Section
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        carName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        index == 2 ? "Xylo, Ertiga, Lodgy" : "Swift, Etios, Dzire",
                        style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 25),
                      
                      // Price Tag
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("₹", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF134E4A))),
                            Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF134E4A))),
                            const Text(" / km", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}