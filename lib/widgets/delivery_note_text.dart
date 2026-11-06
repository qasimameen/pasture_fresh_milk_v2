import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class DeliveryNoteText extends StatelessWidget {
  const DeliveryNoteText({
    super.key,
    required this.note,
  });

  final String? note;

  @override
  Widget build(BuildContext context) {
    if (note == null || note!.trim().isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return Directionality(
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          '${l10n.receiverNamePrefix.trim()} ${note!.trim()}',
          textAlign: TextAlign.start,
          style: typography.caption.copyWith(
            color: AppColors.neutralMuted,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
