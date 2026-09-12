import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const privacyPolicyUrl =
    'https://kddhhh23.github.io/mintonary/privacy-policy.html';

class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({super.key});

  Future<void> _open(BuildContext context) async {
    try {
      if (await launchUrl(
        Uri.parse(privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // 브라우저를 사용할 수 없는 경우에도 앱은 계속 사용할 수 있다.
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('브라우저를 열지 못했어요. 아래 주소를 복사해 브라우저에서 열어 주세요.'),
            SizedBox(height: 12),
            SelectableText(privacyPolicyUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => _open(context),
    child: const Text('개인정보 처리방침'),
  );
}
