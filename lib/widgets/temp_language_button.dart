// TEMPORARY - remove later
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../providers/locale_provider.dart';

/// Temporary language toggle icon button for AppBar / header rows.
/// Taps toggle English <-> Urdu using the shared [localeProvider].
/// TEMPORARY - remove later.
class TempLanguageButton extends ConsumerWidget {
  const TempLanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isUrdu = locale.languageCode == 'ur';
    // Tooltip shows the language it will switch TO.
    final tooltip = isUrdu ? 'English' : 'اردو';

    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Symbols.language, size: 22),
      onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
    );
  }
}
