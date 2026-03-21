import '../../repositories/file_repository.dart';
import '../../entities/file_node.dart';

class SearchFiles {
  final FileRepository repository;

  SearchFiles(this.repository);

  Future<List<FileNode>> call(String serverId, String query) async {
    return await repository.searchFiles(serverId, query);
  }
}
