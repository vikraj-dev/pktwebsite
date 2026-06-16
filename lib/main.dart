import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pktwebsite/firebase_options.dart';
import 'package:pktwebsite/screens/webpage.dart';
import 'package:pktwebsite/screens/privacypolicy.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ── Default home ──────────────────────────────────────
      home: const Webpage(),

      // ── Routes (Play Store URL ku ithuvae use aagum) ──────
      getPages: [
        GetPage(
          name:  '/',
          page:  () => const Webpage(),
        ),
        GetPage(
          name:  '/privacy-policy',       // ← Play Store la itha submit pannu
          page:  () => const PrivacyPolicyPage(),
        ),
      ],

      // ── Flutter Web — URL strategy ─────────────────────────
      // yourdomain.com/privacy-policy → directly open aagum
      routingCallback: (routing) {},
    );
  }
}