sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erro de autenticação']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erro inesperado']);
}
