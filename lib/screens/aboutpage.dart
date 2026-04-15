import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final Key? aboutKey;

  const AboutPage({super.key, this.aboutKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: aboutKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- LEFT SIDE: PREMIUM IMAGE ---
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // A subtle background shape for luxury feel
                    Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    Hero(
                      tag: 'car_image',
                      child: Image.asset(
                        'assets/sedan.png',
                        fit: BoxFit.contain,
                        height: 450,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 80),

              // --- RIGHT SIDE: CONTENT ---
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accent Line
                    Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF134E4A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Experience the Pinnacle of Professional Travel',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _buildLuxuryDescription(
                      "At PKT Call Taxi, we don't just provide rides; we deliver excellence. Specializing in reliable, convenient, and premium one-way taxi services tailored for your journey."
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildLuxuryDescription(
                      "Whether it's an airport transfer or a corporate meeting, our fleet of pristine vehicles and elite drivers ensure you arrive not just on time, but in comfort and style."
                    ),

                    const SizedBox(height: 40),

                    // Luxury Badge Section
                    Row(
                      children: [
                        _buildFeatureBadge(Icons.verified_user_outlined, "Safety First"),
                        const SizedBox(width: 20),
                        _buildFeatureBadge(Icons.timer_outlined, "24/7 Service"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryDescription(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        height: 1.8,
        color: Colors.blueGrey.shade700,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF134E4A)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}