import '../../repositories/server_repository.dart';

/// Use case: Delete server
class DeleteServer {
  final ServerRepository repository;

  DeleteServer(this.repository);

  Future<void> call(String id) async {
    await repository.deleteServer(id);
  }
}
