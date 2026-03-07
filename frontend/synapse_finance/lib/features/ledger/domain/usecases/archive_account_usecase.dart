import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class ArchiveAccountUseCase
    implements UseCase<Account, ArchiveAccountParams> {
  final LedgerRepository _repository;

  ArchiveAccountUseCase(this._repository);

  @override
  Future<Either<Failure, Account>> call(ArchiveAccountParams params) {
    return _repository.archiveAccount(id: params.id);
  }
}

class ArchiveAccountParams extends Equatable {
  final int id;

  const ArchiveAccountParams({required this.id});

  @override
  List<Object?> get props => [id];
}

@lazySingleton
class RestoreAccountUseCase
    implements UseCase<Account, RestoreAccountParams> {
  final LedgerRepository _repository;

  RestoreAccountUseCase(this._repository);

  @override
  Future<Either<Failure, Account>> call(RestoreAccountParams params) {
    return _repository.restoreAccount(id: params.id);
  }
}

class RestoreAccountParams extends Equatable {
  final int id;

  const RestoreAccountParams({required this.id});

  @override
  List<Object?> get props => [id];
}
