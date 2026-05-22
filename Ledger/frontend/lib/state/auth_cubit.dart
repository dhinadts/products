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

  void authenticate(AuthResult result) {
    AuthSession.save(result);
    emit(AuthState(result: result));
  }

  void logout() {
    AuthSession.clear();
    emit(const AuthState());
  }
}
