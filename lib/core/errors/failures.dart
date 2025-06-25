// failures\n// Created: 2025-05-19\n\n
import 'package:equatable/equatable.dart';

/// Represents a failure that occurs due to a cache-related error.
class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

/// Represents a failure that occurs due to a database-related error (e.g., Isar operations).
class DatabaseFailure extends Failure {
  const DatabaseFailure({super.message});
}

/// Represents a generic failure in the application.
/// All specific failure types should extend this class.
abstract class Failure extends Equatable {
  final String? message;
  final int? statusCode;

  const Failure({this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure that occurs due to an unexpected or unhandled error.
class GenericFailure extends Failure {
  const GenericFailure({super.message});
}

/// Represents a failure that occurs due to invalid input data.
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message});
}

/// Represents a failure that occurs due to a network-related error (e.g., no internet connection).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

/// Represents a failure that occurs when an entity is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}

/// Represents a failure that occurs due to a server-side error.
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode});
}
