import 'package:flutter/material.dart';

/// Temporary stub screen for Shared Parenting.
/// Replace this with the real SharedParentingScreen once invitations
/// and Cloud Functions are implemented.
class SharedParentingStubScreen extends StatelessWidget {
  const SharedParentingStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3E39)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shared Parenting',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_rounded,
                size: 64,
                color: Color(0xFF6AADCF),
              ),
              SizedBox(height: 24),
              Text(
                'Shared Parenting',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A3E39),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This feature is coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8A7C75),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
