import 'package:equatable/equatable.dart';

import '../../data/models/bill_model.dart';
import '../../data/models/product_model.dart';

sealed class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class BillingStarted extends BillingEvent {
  const BillingStarted();
}

class BillingProductAdded extends BillingEvent {
  const BillingProductAdded(this.product);
  final ProductModel product;
  @override
  List<Object?> get props => [product];
}

class BillingManualItemAdded extends BillingEvent {
  const BillingManualItemAdded(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class BillingDemoItemsAdded extends BillingEvent {
  const BillingDemoItemsAdded();
}

class BillingQuantityChanged extends BillingEvent {
  const BillingQuantityChanged(this.index, this.quantity);
  final int index;
  final double quantity;
  @override
  List<Object?> get props => [index, quantity];
}

class BillingPriceChanged extends BillingEvent {
  const BillingPriceChanged(this.index, this.price);
  final int index;
  final double price;
  @override
  List<Object?> get props => [index, price];
}

class BillingDiscountChanged extends BillingEvent {
  const BillingDiscountChanged(this.discount);
  final double discount;
  @override
  List<Object?> get props => [discount];
}

class BillingPaymentModeChanged extends BillingEvent {
  const BillingPaymentModeChanged(this.paymentMode);
  final PaymentMode paymentMode;
  @override
  List<Object?> get props => [paymentMode];
}

class BillingPaymentReferenceChanged extends BillingEvent {
  const BillingPaymentReferenceChanged(this.reference);
  final String reference;
  @override
  List<Object?> get props => [reference];
}

class BillingUpiPaymentStarted extends BillingEvent {
  const BillingUpiPaymentStarted();
}

class BillingCardPaymentStarted extends BillingEvent {
  const BillingCardPaymentStarted();
}

class BillingPaymentConfirmed extends BillingEvent {
  const BillingPaymentConfirmed();
}

class BillingItemRemoved extends BillingEvent {
  const BillingItemRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class BillingSaved extends BillingEvent {
  const BillingSaved();
}

class BillingPdfPrinted extends BillingEvent {
  const BillingPdfPrinted();
}

class BillingThermalPrinted extends BillingEvent {
  const BillingThermalPrinted();
}

class BillingPdfShared extends BillingEvent {
  const BillingPdfShared();
}

class BillingCleared extends BillingEvent {
  const BillingCleared();
}
