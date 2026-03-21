import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/file_node.dart';
import 'files_provider.dart';

part 'file_search_provider.g.dart';

enum SearchType { fileName, content }

@riverpod
class FileSearch extends _$FileSearch {
  @override
  Future<List<FileNode>> build(
    String serverId,
    String query,
    SearchType type,
  ) async {
    if (query.isEmpty) return [];

    final repository = ref.watch(fileRepositoryProvider);

    if (type == SearchType.fileName) {
      return await repository.searchFiles(serverId, query);
    } else {
      return await repository.searchContent(serverId, query);
    }
  }
}
