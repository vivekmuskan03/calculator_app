import 'package:flutter/material.dart';
import 'package:nexacalc/core/theme/theme_editor_impl.dart';
import 'package:nexacalc/core/billing/in_app_purchase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/providers/monetization_providers.dart';
import 'package:nexacalc/core/billing/pro_upgrade_notifier.dart';
import 'package:nexacalc/core/billing/receipt_validator.dart';
import 'package:nexacalc/screens/model_download_dialog.dart';
import 'package:nexacalc/screens/theme_editor_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _themeEditor = ThemeEditorImpl();
  final _validatorController = TextEditingController();

  void _openThemeEditor(ProUpgradeNotifier pro) async {
    // Only allow opening if Pro is active
    if (!pro.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme editor is Pro-only')));
      return;
    }
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ThemeEditorScreen(themeEditor: _themeEditor)),
    );
    if (updated == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pro = ref.watch(proUpgradeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          ListTile(
            title: const Text('Pro Upgrade'),
            subtitle: Text(pro.isActive ? 'Active' : 'Not active'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Attempt Play Store purchase if available
                    final svc = InAppPurchaseService();
                    final available = await svc.isAvailable();
                    if (available) {
                      await svc.init((detail) async {
                        // For now, simply treat any successful purchase as pro
                        if (detail.status == PurchaseStatus.purchased || detail.status == PurchaseStatus.restored) {
                          await pro.purchase();
                        }
                      });
                      await svc.buyPro();
                      await svc.dispose();
                    } else {
                      // Fallback to local dev purchase
                      await pro.purchase();
                    }
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase failed: $e')));
                  }
                },
                child: const Text('Buy'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await pro.restore();
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore failed')));
                  }
                },
                child: const Text('Restore'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Theme Editor (Pro)'),
            subtitle: const Text('Open theme editor'),
            trailing: ElevatedButton(
              onPressed: () => _openThemeEditor(pro),
              child: const Text('Open'),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Download LLM model'),
            subtitle: const Text('Download model for on-device NL'),
            trailing: ElevatedButton(
              onPressed: () async {
                await showDialog(context: context, builder: (_) => const ModelDownloadDialog());
              },
              child: const Text('Download'),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Validate receipt with server'),
            subtitle: const Text('Enter validation server URL and validate stored receipt'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            titleTextStyle: Theme.of(context).textTheme.bodyLarge,
            trailing: SizedBox(
              width: 200,
              child: Row(children: [
                Expanded(
                  child: TextField(controller: _validatorController, decoration: const InputDecoration(hintText: 'https://validator.example/validate')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final url = _validatorController.text.trim();
                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter validator URL')));
                      return;
                    }
                    try {
                      final validator = ReceiptValidator(serverUrl: Uri.parse(url));
                      final ok = await pro.validateWithServer(validator);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Receipt valid — Pro active' : 'Receipt invalid')));
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Validation failed: $e')));
                    }
                  },
                  child: const Text('Validate'),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
