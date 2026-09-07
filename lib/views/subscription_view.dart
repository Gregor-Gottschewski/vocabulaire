import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/subscription_service.dart';
import 'package:vocabulaire/views/widgets/key_value_row.dart';
import 'package:vocabulaire/views/widgets/selectable_option_card.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/primary_action_button.dart';
import 'widgets/text_link_button.dart';

enum _SelectedSubscription { monthly, yearly }

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  final SubscriptionService _subscription = SubscriptionService.instance;
  _SelectedSubscription _selectedSubscription = _SelectedSubscription.yearly;
  late AppLocalizations _l10n;
  List<ProductDetails> _products = const [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _subscription.listenable.addListener(_onPurchaseStateChanged);
  }

  @override
  void dispose() {
    _subscription.listenable.removeListener(_onPurchaseStateChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _subscription.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProducts = false);
      context.showAppError(e);
    }
  }

  void _onPurchaseStateChanged() {
    if (!mounted) return;
    final state = _subscription.listenable.value;
    final error = state.error;
    if (state.status == SubscriptionPurchaseStatus.error && error != null) {
      context.showAppError(error);
    } else if (state.status == SubscriptionPurchaseStatus.success) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {});
  }

  String get _selectedProductId => switch (_selectedSubscription) {
    _SelectedSubscription.yearly => SubscriptionService.yearlyProductId,
    _SelectedSubscription.monthly => SubscriptionService.monthlyProductId,
  };

  ProductDetails? _productFor(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  bool get _isPurchasePending =>
      _subscription.listenable.value.status ==
      SubscriptionPurchaseStatus.pending;

  Future<void> _buy() async {
    final product = _productFor(_selectedProductId);
    if (product == null) return;
    try {
      await _subscription.buy(product);
    } on AppException catch (e) {
      if (mounted) context.showAppError(e);
    }
  }

  Future<void> _restore() async {
    try {
      await _subscription.restorePurchases();
    } on AppException catch (e) {
      if (mounted) context.showAppError(e);
    }
  }

  Future<void> _launchEula() async {
    if (!await launchUrl(
      Uri.parse(
        "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
      ),
    )) {
      throw Exception('Could not launch EULA link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      backLabel: _l10n.back,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.subscriptionHeadline,
            style: AppTypography.headlineSerif.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          Text(
            _l10n.subscriptionSubtitle,
            style: AppTypography.bodySans.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          KeyValueRowGroup(
            children: [
              SelectableOptionCard(
                title: _l10n.subscriptionPlanYearly,
                subtitle:
                    _productFor(SubscriptionService.yearlyProductId)?.price ??
                    '',
                selected: _selectedSubscription == _SelectedSubscription.yearly,
                onTap: () => setState(() {
                  _selectedSubscription = _SelectedSubscription.yearly;
                }),
              ),
              SelectableOptionCard(
                title: _l10n.subscriptionPlanMonthly,
                subtitle:
                    _productFor(SubscriptionService.monthlyProductId)?.price ??
                    '',
                selected:
                    _selectedSubscription == _SelectedSubscription.monthly,
                onTap: () => setState(() {
                  _selectedSubscription = _SelectedSubscription.monthly;
                }),
              ),
            ],
          ),

          const Spacer(),

          PrimaryActionButton(
            label: _l10n.subscriptionCta,
            isLoading: _isPurchasePending,
            onPressed: (_isLoadingProducts || _isPurchasePending) ? null : _buy,
          ),
          const SizedBox(height: AppSpacing.gapLarge),
          SizedBox(
            width: double.infinity,
            child: Text(
              _l10n.subscriptionFinePrint(
                _productFor(_selectedProductId)?.price ?? '',
                _selectedSubscription == _SelectedSubscription.yearly
                    ? _l10n.subscriptionPlanYearly
                    : _l10n.subscriptionPlanMonthly,
              ),
              textAlign: TextAlign.center,
              style: AppTypography.captionSans.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          SizedBox(
            width: double.infinity,
            child: Text(
              _l10n.subscriptionAutoRenewNotice,
              textAlign: TextAlign.center,
              style: AppTypography.captionSans.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextLinkButton(label: "EULA", onPressed: () => _launchEula()),
              TextLinkButton(
                label: _l10n.subscriptionRestore,
                onPressed: _isPurchasePending ? null : _restore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
