import '../../repositories/server_repository.dart';
import '../../entities/server.dart';

/// Use case: Update existing server
class UpdateServer {
  final ServerRepository repository;

  UpdateServer(this.repository);

  Future<void> call(Server server) async {
    await repository.updateServer(server);
  }
}
