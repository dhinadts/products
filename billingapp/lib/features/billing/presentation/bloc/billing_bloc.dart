import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/printer/pdf_print_service.dart';
import '../../../../core/printer/thermal_printer_service.dart';
import '../../../../core/payments/payment_service.dart';
import '../../data/models/bill_item_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  BillingBloc({
    BillingRepository? repository,
    PdfPrintService? pdfPrintService,
    ThermalPrinterService? thermalPrinterService,
    PaymentService? paymentService,
  }) : _repository = repository ?? BillingRepository(),
       _pdfPrintService = pdfPrintService ?? PdfPrintService(),
       _thermalPrinterService =
           thermalPrinterService ?? ThermalPrinterService(),
       _paymentService = paymentService ?? const PaymentService(),
       super(
         BillingState(
           billNumber: (repository ?? BillingRepository()).nextBillNumber(),
         ),
       ) {
    on<BillingStarted>(_onStarted);
    on<BillingProductAdded>(_onProductAdded);
    on<BillingManualItemAdded>(_onManualItemAdded);
    on<BillingDemoItemsAdded>(_onDemoItemsAdded);
    on<BillingQuantityChanged>(_onQuantityChanged);
    on<BillingPriceChanged>(_onPriceChanged);
    on<BillingDiscountChanged>(_onDiscountChanged);
    on<BillingPaymentModeChanged>(
      (event, emit) => emit(
        state.copyWith(
          paymentMode: event.paymentMode,
          paymentCompleted: event.paymentMode == PaymentMode.cash,
          paymentReference: '',
          status: BillingStatus.ready,
        ),
      ),
    );
    on<BillingPaymentReferenceChanged>(
      (event, emit) => emit(
        state.copyWith(
          paymentReference: event.reference,
          paymentCompleted: false,
          status: BillingStatus.ready,
        ),
      ),
    );
    on<BillingUpiPaymentStarted>(_onUpiPaymentStarted);
    on<BillingCardPaymentStarted>(_onCardPaymentStarted);
    on<BillingPaymentConfirmed>(_onPaymentConfirmed);
    on<BillingItemRemoved>(_onItemRemoved);
    on<BillingSaved>(_onSaved);
    on<BillingPdfPrinted>(_onPdfPrinted);
    on<BillingThermalPrinted>(_onThermalPrinted);
    on<BillingPdfShared>(_onPdfShared);
    on<BillingCleared>(_onCleared);
  }

  final BillingRepository _repository;
  final PdfPrintService _pdfPrintService;
  final ThermalPrinterService _thermalPrinterService;
  final PaymentService _paymentService;

  Future<void> _onStarted(
    BillingStarted event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(status: BillingStatus.loading));
    try {
      emit(
        state.copyWith(
          status: BillingStatus.ready,
          products: await _repository.getProducts(),
          savedBills: await _repository.getSavedBills(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: BillingStatus.error, message: error.toString()),
      );
    }
  }

  void _onProductAdded(BillingProductAdded event, Emitter<BillingState> emit) {
    emit(
      state.copyWith(
        status: BillingStatus.ready,
        items: [...state.items, BillItemModel.fromProduct(event.product)],
      ),
    );
  }

  Future<void> _onManualItemAdded(
    BillingManualItemAdded event,
    Emitter<BillingState> emit,
  ) async {
    final product = await _repository.findProduct(event.query);
    if (product != null) {
      add(BillingProductAdded(product));
      return;
    }
    emit(
      state.copyWith(
        status: BillingStatus.ready,
        items: [
          ...state.items,
          BillItemModel(
            itemName: event.query.trim().isEmpty
                ? 'Manual Item'
                : event.query.trim(),
            quantity: 1,
            rate: 0,
          ),
        ],
      ),
    );
  }

  void _onDemoItemsAdded(
    BillingDemoItemsAdded event,
    Emitter<BillingState> emit,
  ) {
    final demoBill = _thermalPrinterService.sampleInvoice();
    emit(
      state.copyWith(
        status: BillingStatus.ready,
        items: demoBill.items,
        discount: demoBill.discount,
        paymentMode: demoBill.paymentMode,
      ),
    );
  }

  void _onQuantityChanged(
    BillingQuantityChanged event,
    Emitter<BillingState> emit,
  ) {
    if (event.quantity <= 0) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Quantity must be greater than zero.',
        ),
      );
      return;
    }
    final items = [...state.items];
    items[event.index] = items[event.index].copyWith(quantity: event.quantity);
    emit(state.copyWith(status: BillingStatus.ready, items: items));
  }

  void _onPriceChanged(BillingPriceChanged event, Emitter<BillingState> emit) {
    if (event.price < 0) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Price cannot be negative.',
        ),
      );
      return;
    }
    final items = [...state.items];
    items[event.index] = items[event.index].copyWith(rate: event.price);
    emit(state.copyWith(status: BillingStatus.ready, items: items));
  }

  void _onDiscountChanged(
    BillingDiscountChanged event,
    Emitter<BillingState> emit,
  ) {
    if (event.discount < 0) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Discount cannot be negative.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: BillingStatus.ready, discount: event.discount));
  }

  void _onItemRemoved(BillingItemRemoved event, Emitter<BillingState> emit) {
    final items = [...state.items]..removeAt(event.index);
    emit(state.copyWith(status: BillingStatus.ready, items: items));
  }

  Future<void> _onSaved(BillingSaved event, Emitter<BillingState> emit) async {
    if (!_paymentReady) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Complete or confirm payment before saving the bill.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: BillingStatus.saving));
    try {
      await _repository.saveBill(state.bill);
      emit(
        state.copyWith(
          status: BillingStatus.success,
          message: 'Bill saved.',
          savedBills: await _repository.getSavedBills(),
          billNumber: _repository.nextBillNumber(),
          items: [],
          discount: 0,
          paymentReference: '',
          paymentCompleted: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: BillingStatus.error, message: error.toString()),
      );
    }
  }

  Future<void> _onPdfPrinted(
    BillingPdfPrinted event,
    Emitter<BillingState> emit,
  ) async {
    await _guardPrint(
      emit,
      () => _pdfPrintService.printPdfInvoice(state.bill),
      'PDF print opened.',
    );
  }

  Future<void> _onThermalPrinted(
    BillingThermalPrinted event,
    Emitter<BillingState> emit,
  ) async {
    await _guardPrint(
      emit,
      () => _thermalPrinterService.printThermalReceipt(state.bill),
      'Thermal print sent.',
    );
  }

  Future<void> _onPdfShared(
    BillingPdfShared event,
    Emitter<BillingState> emit,
  ) async {
    await _guardPrint(
      emit,
      () => _pdfPrintService.sharePdf(state.bill),
      'PDF shared.',
    );
  }

  Future<void> _onUpiPaymentStarted(
    BillingUpiPaymentStarted event,
    Emitter<BillingState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Add items before starting payment.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: BillingStatus.saving));
    final result = await _paymentService.launchUpiPayment(state.bill);
    emit(
      state.copyWith(
        status: result.success ? BillingStatus.success : BillingStatus.error,
        paymentReference: result.reference,
        paymentCompleted: false,
        message: result.message,
      ),
    );
  }

  Future<void> _onCardPaymentStarted(
    BillingCardPaymentStarted event,
    Emitter<BillingState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Add items before starting payment.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: BillingStatus.saving));
    final result = await _paymentService.launchHostedCardCheckout(state.bill);
    emit(
      state.copyWith(
        status: result.success ? BillingStatus.success : BillingStatus.error,
        paymentReference: result.reference,
        paymentCompleted: false,
        message: result.message,
      ),
    );
  }

  void _onPaymentConfirmed(
    BillingPaymentConfirmed event,
    Emitter<BillingState> emit,
  ) {
    if (state.paymentMode == PaymentMode.card) {
      final result = _paymentService.confirmCardTerminalPayment(
        reference: state.paymentReference ?? '',
        amount: state.grandTotal,
      );
      emit(
        state.copyWith(
          status: result.success ? BillingStatus.success : BillingStatus.error,
          paymentReference: result.reference,
          paymentCompleted: result.success,
          message: result.message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: BillingStatus.success,
        paymentCompleted: true,
        message: '${state.paymentMode.label} payment confirmed.',
      ),
    );
  }

  Future<void> _guardPrint(
    Emitter<BillingState> emit,
    Future<void> Function() action,
    String success,
  ) async {
    if (state.items.isEmpty) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Add items before printing.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: BillingStatus.printing));
    try {
      await action();
      emit(state.copyWith(status: BillingStatus.success, message: success));
    } catch (error) {
      emit(
        state.copyWith(
          status: BillingStatus.error,
          message: 'Printer failed. ${error.toString()}',
        ),
      );
    }
  }

  void _onCleared(BillingCleared event, Emitter<BillingState> emit) {
    emit(
      state.copyWith(
        status: BillingStatus.ready,
        items: [],
        discount: 0,
        billNumber: _repository.nextBillNumber(),
        paymentReference: '',
        paymentCompleted: false,
      ),
    );
  }

  bool get _paymentReady {
    return switch (state.paymentMode) {
      PaymentMode.cash => true,
      PaymentMode.upi || PaymentMode.card => state.paymentCompleted,
    };
  }
}
