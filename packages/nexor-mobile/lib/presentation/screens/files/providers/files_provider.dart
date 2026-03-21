import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/file_node.dart';
import '../../../../domain/entities/file_content.dart';
import '../../../../domain/repositories/file_repository.dart';
import '../../../../data/repositories/file_repository_impl.dart';
import '../../../../core/ssh/ssh_client.dart';
import '../../../../core/ssh/sftp_client.dart';
import '../../../providers/ssh_connection_provider.dart';

part 'files_provider.g.dart';

@riverpod
FileRepository fileRepository(FileRepositoryRef ref) {
  final sshClient = ref.watch(sshClientProvider);
  final sftpClient = SFTPClient(sshClient);
  return FileRepositoryImpl(sshClient, sftpClient);
}

@riverpod
class Files extends _$Files {
  @override
  Future<List<FileNode>> build(String serverId, String path) async {
    final repository = ref.watch(fileRepositoryProvider);
    return await repository.listFiles(serverId, path);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
Future<FileContent> fileContent(
  FileContentRef ref,
  String serverId,
  String path,
) async {
  final repository = ref.watch(fileRepositoryProvider);
  return await repository.readFile(serverId, path);
}

@riverpod
Future<Map<String, String>> gitStatus(
  GitStatusRef ref,
  String serverId,
  String path,
) async {
  final repository = ref.watch(fileRepositoryProvider);
  return await repository.getGitStatus(serverId, path);
}
