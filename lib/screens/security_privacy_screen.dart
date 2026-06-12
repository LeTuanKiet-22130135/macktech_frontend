import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Security and Privacy", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Data We Collect"),
            _buildParagraph("We collect information to provide better services:"),
            _buildBullet("Account Data: Name, email, phone number, university (for student verification)."),
            _buildBullet("Transaction Data: Purchase history, payment methods (encrypted)."),
            _buildBullet("Device Data: OS version, app crashes (for troubleshooting)."),
            _buildBullet("Permissions: Location (for store pickup), camera (for repair tickets), notifications."),
            _buildParagraph('"We never sell your data to third parties."'),
            const SizedBox(height: 24),

            _buildSectionTitle("2. How We Use Your Data"),
            _buildBullet("Process orders and repairs."),
            _buildBullet("Personalize recommendations (e.g., student discounts)."),
            _buildBullet("Send security alerts (e.g., login attempts)."),
            _buildBullet("Improve app performance via analytics (anonymous where possible)."),
            const SizedBox(height: 24),

            _buildSectionTitle("3. Security Measures"),
            _buildBullet("Encryption: All data transmitted via TLS/SSL."),
            _buildBullet("Payments: PCI-compliant processors (card details never stored on our servers)."),
            _buildBullet("Access Controls: Staff training and strict data access policies."),
            const SizedBox(height: 24),

            _buildSectionTitle("4. Your Rights"),
            _buildBullet("Access/Delete Data: Via Account Settings or email [privacy@macktech.com]."),
            _buildBullet("Opt-Out: Disable notifications or location in device settings."),
            _buildBullet("Report Issues: Security vulnerabilities? Contact [security@macktech.com]."),
            const SizedBox(height: 24),

            _buildSectionTitle("5. Third-Party Services"),
            _buildBullet("Payment Gateways: Stripe, PayPal (see their policies)."),
            _buildBullet("Analytics: Google Firebase (aggregated data only)."),
            const SizedBox(height: 24),

            _buildSectionTitle("6. Updates to This Policy"),
            _buildParagraph("We'll notify users of material changes via:"),
            _buildBullet("In-app banners."),
            _buildBullet("Email (if subscribed)."),
            const SizedBox(height: 32),

            _buildSectionTitle("Contact Us"),
            _buildParagraph("For questions or data requests:"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("✉️ ", style: TextStyle(fontSize: 16)),
                Expanded(child: _buildParagraph("Email: privacy@macktech.com", paddingBottom: 0)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("📍 ", style: TextStyle(fontSize: 16)),
                Expanded(child: _buildParagraph("Address: 162 Kaduwela Rd, Malabe .", paddingBottom: 0)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('"Your trust is our priority."', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text, {double paddingBottom = 8.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
