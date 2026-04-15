import 'package:flutter/material.dart';
import 'package:pktwebsite/screens/contectpage.dart';
import 'package:pktwebsite/screens/tarifpage.dart';
import 'aboutpage.dart';
import 'homepage.dart';
import 'header.dart';

class Webpage extends StatefulWidget {
  const Webpage({super.key});

  @override
  State<Webpage> createState() => _WebpageState();
}

class _WebpageState extends State<Webpage> {
  // GlobalKeys for scrolling
  final aboutKey = GlobalKey();
  final homeKey = GlobalKey();
  final tarifkey = GlobalKey();
  final contectkey = GlobalKey();
  
  final ScrollController scrollController = ScrollController();
  String activeSection = 'HOME';

  @override
  void initState() {
    super.initState();
    // Scroll aagum pothu section detect panna listener
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    
    double offset = scrollController.offset;
    
    // Offset values based on your section heights
    setState(() {
      if (offset < 700) {
        activeSection = 'HOME';
      } else if (offset >= 700 && offset < 1500) {
        activeSection = 'ABOUT';
      } else if (offset >= 1500 && offset < 2300) {
        activeSection = 'TARIFF';
      } else {
        activeSection = 'CONTACT';
      }
    });
  }

  // Smooth Scroll Function
  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Stack use panni Header-ai fixed-ah mela vachukalam
      body: Stack(
        children: [
          // 1. MAIN CONTENT LAYER
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header space (Do not use Expanded here)
                  const SizedBox(height: 90), 
                  
                  // Homepage Section
                  Homepage(key: homeKey),
                  
                  // About Section
                  AboutPage(aboutKey: aboutKey),
                  
                  // Luxury Divider
                  _buildSectionDivider(),
                  
                  // Tariff Section
                  TarifPage(tarifkey: tarifkey),
                  
                  // Contact & Footer Section
                  Contectpage(
                    contectkey: contectkey,
                    onHomeTap: () => _scrollTo(homeKey),
                    onAboutTap: () => _scrollTo(aboutKey),
                    onTarifTap: () => _scrollTo(tarifkey),
                    onContactTap: () => _scrollTo(contectkey),
                  ),
                ],
              ),
            ),
          ),

          // 2. FIXED HEADER LAYER (Top-most)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Header(
              activePage: activeSection,
              onHomeTap: () => _scrollTo(homeKey),
              onAboutTap: () => _scrollTo(aboutKey),
              onTarifTap: () => _scrollTo(tarifkey),
              onContectTap: () => _scrollTo(contectkey),
            ),
          ),
          
          // 3. SCROLL TO TOP BUTTON
          _buildScrollToTopButton(),
        ],
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: (scrollController.hasClients && scrollController.offset > 500) ? 30 : -100,
      right: 30,
      child: FloatingActionButton(
        mini: true,
        elevation: 10,
        backgroundColor: const Color(0xFF134E4A),
        onPressed: () => _scrollTo(homeKey),
        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 1, width: 80, color: Colors.grey.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 24),
          ),
          Container(height: 1, width: 80, color: Colors.grey.withOpacity(0.2)),
        ],
      ),
    );
  }
}