import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';

class VisionStageView extends StatelessWidget {
  const VisionStageView({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
          border: Border.all(color: ArgusTokens.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: const HtmlElementView(viewType: 'argus-vision-stage'),
      );
    }

    // Non-web / test environment placeholder
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070A0F),
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_outlined, size: 48, color: ArgusTokens.textTertiary),
            SizedBox(height: 12),
            Text(
              'Hardware Vision Engine Stage',
              style: TextStyle(color: ArgusTokens.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Running in native desktop / test environment',
              style: TextStyle(color: ArgusTokens.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
