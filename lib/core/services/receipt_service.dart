import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

class ReceiptService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Captures the widget as an image and shares it.
  Future<void> generateAndShareReceipt(BuildContext context, Widget receiptWidget, {String? fileName, Locale? locale}) async {
    try {
      // In newer Flutter versions, passing MaterialApp directly to captureFromWidget
      // can crash because it expects a View ancestor for MediaQuery initialization.
      // Therefore, we manually assemble the required ancestors in the requested order:
      // ProviderScope -> Localizations -> MediaQuery -> Directionality
      final wrappedWidget = UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: locale ?? const Locale('en'),
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 1200),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Material(
                color: Colors.white,
                child: Center(
                  child: receiptWidget,
                ),
              ),
            ),
          ),
        ),
      );

      // captureFromWidget renders the widget in a standalone view.
      final image = await _screenshotController.captureFromWidget(
        wrappedWidget,
        delay: const Duration(milliseconds: 500),
        context: context,
      );

      final directory = await getTemporaryDirectory();
      final name = fileName ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      final imagePath = await File('${directory.path}/$name').create();
      await imagePath.writeAsBytes(image);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Here is your receipt from Al-Madina Dairy.',
      );
    } catch (e, stackTrace) {
      debugPrint("Error generating receipt: $e\n$stackTrace");
    }
  }
}
