import '../../repositories/file_repository.dart';
import '../../entities/file_content.dart';

class ReadFile {
  final FileRepository repository;

  ReadFile(this.repository);

  Future<FileContent> call(String serverId, String path) async {
    return await repository.readFile(serverId, path);
  }
}
