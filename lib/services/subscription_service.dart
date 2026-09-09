import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'app_exception.dart';
import 'auth_service.dart';

enum SubscriptionPurchaseStatus { idle, pending, success, error }

/// Snapshot of the current purchase flow.
class SubscriptionPurchaseState {
  final SubscriptionPurchaseStatus status;
  final AppException? error;

  const SubscriptionPurchaseState._(this.status, [this.error]);

  static const idle = SubscriptionPurchaseState._(
    SubscriptionPurchaseStatus.idle,
  );
  static const pending = SubscriptionPurchaseState._(
    SubscriptionPurchaseStatus.pending,
  );
  static const success = SubscriptionPurchaseState._(
    SubscriptionPurchaseStatus.success,
  );

  factory SubscriptionPurchaseState.error(AppException error) =>
      SubscriptionPurchaseState._(SubscriptionPurchaseStatus.error, error);
}

/// Handles Apple in-app-purchase subscriptions.
class SubscriptionService {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  static const String monthlyProductId = 'full_access_monthly';
  static const String yearlyProductId = 'full_access_yearly';
  static const Set<String> productIds = {monthlyProductId, yearlyProductId};

  static const String _region = 'europe-west1';
  static const Duration _restoreTimeout = Duration(seconds: 8);

  final InAppPurchase _iap = InAppPurchase.instance;
  final ValueNotifier<SubscriptionPurchaseState> _stateNotifier = ValueNotifier(
    SubscriptionPurchaseState.idle,
  );
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ValueListenable<SubscriptionPurchaseState> get listenable => _stateNotifier;

  /// Starts listening for purchase updates.
  void attach() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('SubscriptionService: purchase stream error: $error');
      },
    );
  }

  void detach() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(productIds);
    if (response.error != null || response.productDetails.isEmpty) {
      throw AppException(AppError.subscriptionProductsUnavailable);
    }
    return response.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    _stateNotifier.value = SubscriptionPurchaseState.pending;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      _stateNotifier.value = SubscriptionPurchaseState.idle;
      throw AppException(AppError.subscriptionPurchaseFailed, details: e);
    }
  }

  /// Triggers restoration of previous purchases.
  Future<void> restorePurchases() async {
    _stateNotifier.value = SubscriptionPurchaseState.pending;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _stateNotifier.value = SubscriptionPurchaseState.idle;
      throw AppException(AppError.subscriptionRestoreFailed, details: e);
    }
    await Future.delayed(_restoreTimeout);

    if (_stateNotifier.value.status == SubscriptionPurchaseStatus.pending) {
      _stateNotifier.value = SubscriptionPurchaseState.idle;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _stateNotifier.value = SubscriptionPurchaseState.pending;
        case PurchaseStatus.canceled:
          _stateNotifier.value = SubscriptionPurchaseState.idle;
        case PurchaseStatus.error:
          _stateNotifier.value = SubscriptionPurchaseState.error(
            AppException(
              AppError.subscriptionPurchaseFailed,
              details: purchase.error,
            ),
          );
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndComplete(purchase);
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchase) async {
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) {
        throw AppException(AppError.subscriptionVerificationFailed);
      }
      await FirebaseFunctions.instanceFor(
        region: _region,
      ).httpsCallable('verifyAppleSubscription').call<void>({
        'signedTransactionInfo':
            purchase.verificationData.serverVerificationData,
      });
      _stateNotifier.value = SubscriptionPurchaseState.success;
    } on AppException catch (e) {
      _stateNotifier.value = SubscriptionPurchaseState.error(e);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        final details = e.details;
        final email = details is Map ? details['email'] as String? : null;
        _stateNotifier.value = SubscriptionPurchaseState.error(
          AppException(AppError.subscriptionAlreadyLinked, details: email),
        );
      } else {
        _stateNotifier.value = SubscriptionPurchaseState.error(
          AppException(AppError.subscriptionVerificationFailed, details: e),
        );
      }
    } finally {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}
