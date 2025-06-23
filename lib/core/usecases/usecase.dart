// Base class for Use Cases
// Type: Return type of the use case
// Params: Input parameters type for the use case
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Use case without parameters
abstract class UseCaseWithoutParams<Type> {
  Future<Type> call();
}

// Special type for use cases that don't return anything meaningful
class NoParams {}
class NoOutput {}

