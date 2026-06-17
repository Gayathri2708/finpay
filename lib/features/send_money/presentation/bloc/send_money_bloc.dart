import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/usecases/send_money_usecase.dart';

part 'send_money_event.dart';
part 'send_money_state.dart';

class SendMoneyBloc extends Bloc<SendMoneyEvent, SendMoneyState> {
  final SendMoneyUseCase sendMoneyUseCase;

  SendMoneyBloc({required this.sendMoneyUseCase}) : super(SendMoneyInitial()) {
    on<SendMoneySubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    SendMoneySubmitted event,
    Emitter<SendMoneyState> emit,
  ) async {
    emit(SendMoneyLoading());
    final result = await sendMoneyUseCase(
      toPhone: event.toPhone,
      amount: event.amount,
      description: event.description,
    );
    result.fold(
      (failure) => emit(SendMoneyFailure(message: failure.message)),
      (wallet) => emit(SendMoneySuccess(updatedWallet: wallet)),
    );
  }
}
