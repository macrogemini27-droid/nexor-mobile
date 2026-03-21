import '../../repositories/file_repository.dart';

class GetGitStatus {
  final FileRepository repository;

  GetGitStatus(this.repository);

  Future<Map<String, String>> call(String serverId, String path) async {
    return await repository.getGitStatus(serverId, path);
  }
}
