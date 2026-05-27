import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/backend_models.dart';
import '../services/backend_api.dart';
import '../services/bank_account_setup_session.dart';

class BankAccountsState extends Equatable {
  final List<BankBalance> accounts;
  final bool loading;
  final bool saving;
  final String? error;

  const BankAccountsState({
    this.accounts = const <BankBalance>[],
    this.loading = false,
    this.saving = false,
    this.error,
  });

  BankAccountsState copyWith({
    List<BankBalance>? accounts,
    bool? loading,
    bool? saving,
    String? error,
  }) {
    return BankAccountsState(
      accounts: accounts ?? this.accounts,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [accounts, loading, saving, error];
}

class BankAccountsCubit extends Cubit<BankAccountsState> {
  BankAccountsCubit({BackendApi? api})
      : _api = api ?? BackendApi(),
        super(const BankAccountsState());

  final BackendApi _api;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final remoteAccounts = await _api.fetchBankBalances();
      final localAccounts = await _LocalBankAccountStore.load();
      final accounts =
          _dedupeBankAccounts([...localAccounts, ...remoteAccounts]);
      emit(BankAccountsState(accounts: accounts));
    } catch (error) {
      final localAccounts = await _LocalBankAccountStore.load();
      emit(BankAccountsState(
        accounts: _dedupeBankAccounts(localAccounts),
        error: error.toString(),
      ));
    }
  }

  Future<void> saveAccounts(
    List<Map<String, dynamic>> payloads, {
    required bool completeSetup,
  }) async {
    emit(state.copyWith(saving: true));
    try {
      final saved = <BankBalance>[];
      for (final payload in payloads) {
        try {
          saved.add(await _api.createBankAccount(payload));
        } catch (error) {
          if (!_isBackendBankWriteUnavailable(error)) {
            rethrow;
          }
          saved.add(_LocalBankAccountStore.fromPayload(payload));
        }
      }
      final allAccounts = _dedupeBankAccounts([...saved, ...state.accounts]);
      await _LocalBankAccountStore.saveLocalOnly(allAccounts);
      if (completeSetup) {
        await BankAccountSetupSession.markComplete();
      }
      emit(BankAccountsState(accounts: allAccounts));
    } catch (error) {
      emit(state.copyWith(saving: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> deleteAccount(String id) async {
    emit(state.copyWith(saving: true));
    try {
      try {
        await _api.deleteBankAccount(id);
      } catch (error) {
        if (!_isBackendBankWriteUnavailable(error)) {
          rethrow;
        }
      }
      final accounts = _dedupeBankAccounts(
          state.accounts.where((account) => account.id != id).toList());
      await _LocalBankAccountStore.saveLocalOnly(accounts);
      emit(BankAccountsState(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(saving: false, error: error.toString()));
    }
  }

  bool _isBackendBankWriteUnavailable(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('route post /api/bank-balances not found') ||
        message.contains('route put /api/bank-balances') ||
        message.contains('route delete /api/bank-balances') ||
        message.contains('not found');
  }

  List<BankBalance> _dedupeBankAccounts(List<BankBalance> accounts) {
    final seen = <String>{};
    final result = <BankBalance>[];

    for (final account in accounts) {
      final key = _bankAccountKey(account);
      if (seen.add(key)) {
        result.add(account);
      }
    }

    return result;
  }

  String _bankAccountKey(BankBalance account) {
    final accountNumber = account.accountNumber.trim().toLowerCase();
    final ifsc = account.ifsc.trim().toLowerCase();
    if (accountNumber.isNotEmpty || ifsc.isNotEmpty) {
      return '$accountNumber|$ifsc';
    }

    return [
      account.accountHolderName,
      account.bankName,
      account.accountType,
    ].map((value) => value.trim().toLowerCase()).join('|');
  }
}

class _LocalBankAccountStore {
  static const _key = 'ledger_local_bank_accounts';

  static Future<List<BankBalance>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const <BankBalance>[];
    }

    try {
      final items = jsonDecode(raw) as List<dynamic>;
      return items
          .whereType<Map<String, dynamic>>()
          .map(BankBalance.fromJson)
          .toList();
    } catch (_) {
      await prefs.remove(_key);
      return const <BankBalance>[];
    }
  }

  static Future<void> saveLocalOnly(List<BankBalance> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final localAccounts =
        accounts.where((account) => account.id.startsWith('local-')).toList();
    await prefs.setString(
      _key,
      jsonEncode(localAccounts.map((account) => account.toJson()).toList()),
    );
  }

  static BankBalance fromPayload(Map<String, dynamic> payload) {
    final holder = payload['accountHolderName']?.toString() ?? '';
    final accountNumber = payload['accountNumber']?.toString() ?? '';
    final ifsc = payload['ifsc']?.toString() ?? '';
    final openingBalance = _toDouble(payload['openingBalance']);
    return BankBalance.fromJson({
      'id': _localId(accountNumber: accountNumber, ifsc: ifsc, holder: holder),
      'accountHolderName': holder,
      'accountName': holder,
      'ownerType': payload['ownerType']?.toString() ?? 'Company',
      'bankName': payload['bankName']?.toString() ?? '',
      'branchName': payload['branchName']?.toString() ?? '',
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'accountType': payload['accountType']?.toString() ?? '',
      'openingBalance': openingBalance,
      'balance': openingBalance,
      'primaryAccount': payload['primaryAccount'] == true,
    });
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _localId({
    required String accountNumber,
    required String ifsc,
    required String holder,
  }) {
    final raw = [
      accountNumber.trim().isEmpty ? holder : accountNumber,
      ifsc,
    ].join('-').toLowerCase();
    final safe = raw.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return 'local-${safe.replaceAll(RegExp(r'^-+|-+$'), '')}';
  }
}
