import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/backend_models.dart';
import '../services/auth_session.dart';

class AuthState extends Equatable {
  final AuthResult? result;

  const AuthState({this.result});

  bool get isAuthenticated => result?.token.isNotEmpty == true;
  AuthUser? get user => result?.user;

  @override
  List<Object?> get props => [result];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(result: AuthSession.current));

  Future<void> authenticate(
    AuthResult result, {
    bool rememberMe = false,
  }) async {
    await AuthSession.save(result, rememberMe: rememberMe);
    emit(AuthState(result: result));
  }

  Future<void> logout() async {
    await AuthSession.clear();
    emit(const AuthState());
  }
}
