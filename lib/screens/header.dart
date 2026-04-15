import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class Header extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onHomeTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContectTap;
  final String activePage;

  const Header({
    super.key,
    required this.onAboutTap,
    required this.onHomeTap,
    required this.onTarifTap,
    required this.onContectTap,
    this.activePage = 'HOME',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Enhanced blur for premium feel
        child: Container(
          height: 90, // Slightly increased height for breathing room
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7), 
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            children: [
              // --- LUXURY LOGO SECTION ---
              _buildLogo(),
              
              const Spacer(),

              // --- NAVIGATION MENU ---
              _buildNavButton('HOME', onHomeTap),
              _buildNavButton('ABOUT', onAboutTap),
              _buildNavButton('TARIFF', onTarifTap),
              _buildNavButton('CONTACT', onContectTap),

              const SizedBox(width: 40),

              // --- PREMIUM CALL TO ACTION ---
              _buildBookingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return InkWell(
      onTap: () => Get.toNamed('/dashboard'),
      borderRadius: BorderRadius.circular(15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
  height: 65,
  width: 65,
  padding: const EdgeInsets.all(8), // Logo inner space-ku padding
  decoration: BoxDecoration(

    borderRadius: BorderRadius.circular(12),
    
  ),
  child: // Ithai try pannu
Image.asset(
  'assets/pktlogo.png', // Build-ku ithu thaan correct configuration
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_taxi, color: Colors.white),
),
),
          const SizedBox(width: 15),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PKT',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  height: 1,
                ),
              ),
              Text(
                'CALL TAXI',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, VoidCallback onTap) {
    bool isActive = activePage == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF134E4A) : const Color(0xFF475569),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            // Active Indicator with Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF134E4A),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF134E4A).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onHomeTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A), // Dark Midnight for contrast
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Row(
          children: [
            Text(
              'BOOK NOW',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}