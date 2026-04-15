import 'package:flutter/material.dart';

class Contectpage extends StatelessWidget {
  final Key? contectkey;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContactTap;

  const Contectpage({
    super.key,
    this.contectkey,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onTarifTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: contectkey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: const BoxDecoration(
        // Luxury Deep Gradient
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. QUICK LINKS SECTION
              _buildFooterColumn(
                title: 'Quick Links',
                children: [
                  _buildFooterLink("HOME", onHomeTap),
                  _buildFooterLink("ABOUT US", onAboutTap),
                  _buildFooterLink("TARIFF PLAN", onTarifTap),
                  _buildFooterLink("CONTACT", onContactTap),
                ],
              ),

              // 2. ADDRESS SECTION
              _buildFooterColumn(
                title: 'Our Address',
                children: [
                  const Text(
                    'PKT Call Taxi Cab',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildAddressText(
                    'We, PKT Call Taxi, situated at Pattukkottai,\nTamil Nadu, have a profound understanding of\n our consumers travel needs and preferences.\nWe aim to offer individuals as well as corporate\na wide range of cars on hire.',
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Icon(Icons.phone_android, color: Color(0xFF38BDF8), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '+91 76677 33771',
                        style: TextStyle(
                          color: Colors.blueGrey.shade100,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildSectionTitle('Contact Us'),
    const SizedBox(height: 25),
    Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Light background for contrast
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Section
          _contactRow(Icons.email_rounded, "info@pktcalltaxi.com", Colors.amber),
          const SizedBox(height: 20),
          
          // Phone Numbers
          _contactRow(Icons.phone_android_rounded, "76677 33771", Colors.amber),
          const SizedBox(height: 15),
          _contactRow(Icons.phone_android_rounded, "98942 04941", Colors.amber),
          const SizedBox(height: 15),
          _contactRow(Icons.phone_in_talk_rounded, "0437 3252785", Colors.amber),
          const SizedBox(height: 20),
          
          // Location
          _contactRow(Icons.location_on_rounded, "Pattukkottai", Colors.amber),
        ],
      ),
    ),
  ],
)
              // 3. MAP / IMAGE SECTION
 
            ],
          ),
        ),
      ),
    );
  }

Widget _contactRow(IconData icon, String text, Color iconColor) {
  return Row(
    children: [
      Icon(icon, color: iconColor, size: 22),
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ],
  );
}



  Widget _buildFooterColumn({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 30),
        ...children,
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8), // Electric Blue Accent
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.blueGrey.shade300,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.blueGrey.shade200,
        fontSize: 15,
        height: 1.8,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}