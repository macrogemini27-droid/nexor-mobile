import '../../repositories/server_repository.dart';
import '../../entities/server.dart';

/// Use case: Get all servers
class GetServers {
  final ServerRepository repository;

  GetServers(this.repository);

  Future<List<Server>> call() async {
    return await repository.getServers();
  }
}
