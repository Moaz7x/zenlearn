import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

/// Abstract class for a Use Case specific to the Notes feature.
/// This Use Case returns an [Either] type, explicitly handling success or failure.
/// [Type] represents the return type on success.
/// [Params] represents the parameters required by the use case.
abstract class NotesUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// A class to be used when a Notes Use Case does not require any parameters.
/// This can extend the global NoParams if it's compatible, or be a separate one.
/// For simplicity, we'll use the global NoParams as it's just a marker.
// class NotesNoParams extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
