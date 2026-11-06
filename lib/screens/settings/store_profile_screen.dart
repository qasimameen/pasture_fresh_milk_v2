import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/id_generator.dart';
import '../../models/store_profile.dart';
import '../../providers/store_profile_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

/// Store Profile editing screen (plan.md C-M16; Section 2.7, 3.4).
///
/// Allows editing the single store profile entity:
/// - Store name (required)
/// - Phone number (optional)
/// - Store address (optional)
///
/// Saves via [StoreProfileRepository.upsertProfile] and invalidates [storeProfileProvider].
class StoreProfileScreen extends ConsumerStatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  ConsumerState<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends ConsumerState<StoreProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _nameError;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateFields(StoreProfile? profile) {
    if (_isInitialized) return;
    if (profile != null) {
      _nameController.text = profile.name;
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
    }
    _isInitialized = true;
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
      setState(() {
        _nameError = l10n?.errorStoreNameRequired ?? 'Store name cannot be empty';
      });
      return;
    }

    setState(() {
      _nameError = null;
      _isSaving = true;
    });

    try {
      final repository = ref.read(storeProfileRepositoryProvider);
      final currentProfile = ref.read(storeProfileProvider).valueOrNull;

      final now = DateTime.now();
      final updatedProfile = StoreProfile(
        id: currentProfile?.id ?? IdGenerator.generate(),
        name: name,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        createdAt: currentProfile?.createdAt ?? now,
        updatedAt: now,
      );

      await repository.upsertProfile(updatedProfile);
      ref.invalidate(storeProfileProvider);

      if (mounted) {
        final l10n =
            Localizations.of<AppLocalizations>(context, AppLocalizations);
        AppSnackBar.show(
          context,
          message: l10n?.profileSavedSuccess ?? 'Store profile saved successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: e.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final profileAsync = ref.watch(storeProfileProvider);

    profileAsync.whenData((profile) {
      _populateFields(profile);
    });

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.neutralLine, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(
            Symbols.arrow_back,
            color: AppColors.neutralTitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.storeProfileTitle ?? 'Store Profile',
          style: typography.heading.copyWith(
            color: AppColors.neutralTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Store Avatar & Title banner
                  Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.brandTint,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Symbols.storefront,
                          size: 26,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n?.settingsStoreProfile ?? 'Store Profile',
                              style: typography.subhead.copyWith(
                                color: AppColors.neutralTitle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n?.settingsStoreProfileSubtitle ??
                                  'Shop name, contact phone, and address',
                              style: typography.caption.copyWith(
                                color: AppColors.neutralMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceLg),

                  // Store Name
                  AppTextField(
                    label: l10n?.storeNameLabel ?? 'Store Name',
                    hintText: 'e.g. Al-Madina Dairy',
                    controller: _nameController,
                    prefixIcon: Symbols.store,
                    isRequired: true,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() {
                          _nameError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),

                  // Store Phone
                  AppTextField(
                    label: l10n?.storePhoneLabel ?? 'Store Phone',
                    hintText: 'e.g. 0300-1234567',
                    controller: _phoneController,
                    prefixIcon: Symbols.call,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),

                  // Store Address
                  AppTextField(
                    label: l10n?.storeAddressLabel ?? 'Store Address',
                    hintText: 'e.g. Shop #4, Main Market, Civil Lines',
                    controller: _addressController,
                    prefixIcon: Symbols.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.spaceXl),

                  // Save Button
                  AppButton(
                    label: l10n?.saveChangesAction ?? 'Save Changes',
                    isLoading: _isSaving,
                    isFullWidth: true,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
