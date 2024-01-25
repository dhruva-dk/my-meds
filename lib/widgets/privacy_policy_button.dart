import 'package:flutter/material.dart';
import 'package:medication_tracker/widgets/outline_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyButton extends StatelessWidget {
  final String url;

  const PrivacyPolicyButton({
    Key? key,
    this.url = 'https://sites.google.com/view/mymedsapp/home',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WhiteOutlineButton(
      title: "Privacy Policy",
      onTap: () => _openPrivacyPolicy(context),
    );
  }

  void _openPrivacyPolicy(BuildContext context) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      _showErrorSnackbar(context, 'Could not launch the privacy policy');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
