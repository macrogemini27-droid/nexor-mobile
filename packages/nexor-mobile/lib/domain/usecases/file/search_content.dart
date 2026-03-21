import '../../repositories/file_repository.dart';
import '../../entities/file_node.dart';

class SearchContent {
  final FileRepository repository;

  SearchContent(this.repository);

  Future<List<FileNode>> call(String serverId, String pattern) async {
    return await repository.searchContent(serverId, pattern);
  }
}
