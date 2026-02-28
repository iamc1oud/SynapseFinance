import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class CreateTransferUseCase implements UseCase<void, CreateTransferParams> {
  final LedgerRepository _repository;

  CreateTransferUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateTransferParams params) {
    return _repository.createTransfer(
      amount: params.amount,
      fromAccountId: params.fromAccountId,
      toAccountId: params.toAccountId,
      date: params.date,
      note: params.note,
      tagIds: params.tagIds,
    );
  }
}

class CreateTransferParams extends Equatable {
  final double amount;
  final int fromAccountId;
  final int toAccountId;
  final DateTime date;
  final String note;
  final List<int> tagIds;

  const CreateTransferParams({
    required this.amount,
    required this.fromAccountId,
    required this.toAccountId,
    required this.date,
    required this.note,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [amount, fromAccountId, toAccountId, date, note, tagIds];
}
