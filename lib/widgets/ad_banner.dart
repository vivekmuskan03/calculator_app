import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/providers/monetization_providers.dart';

class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ad = ref.watch(adManagerProvider);
    if (!ad.shouldShowBanner) return const SizedBox.shrink();

    return Semantics(
      container: true,
      label: 'Advertisement',
      child: Container(
        height: 64,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Expanded(child: Text('Ad banner (placeholder)')),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss ad',
              onPressed: () {
                final notifier = ref.read(adManagerProvider);
                notifier.dismissBanner();
              },
            ),
          ],
        ),
      ),
    );
  }
}
