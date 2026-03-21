import '../../repositories/server_repository.dart';
import '../../entities/server.dart';

/// Use case: Add new server
class AddServer {
  final ServerRepository repository;

  AddServer(this.repository);

  Future<void> call(Server server) async {
    await repository.addServer(server);
  }
}
