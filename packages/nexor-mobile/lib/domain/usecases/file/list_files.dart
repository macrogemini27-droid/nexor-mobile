import '../../repositories/file_repository.dart';
import '../../entities/file_node.dart';

class ListFiles {
  final FileRepository repository;

  ListFiles(this.repository);

  Future<List<FileNode>> call(String serverId, String path) async {
    return await repository.listFiles(serverId, path);
  }
}
