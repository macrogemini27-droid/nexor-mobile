import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/file_node.dart';
import '../../../../domain/entities/file_content.dart';
import '../../../../domain/repositories/file_repository.dart';
import '../../../../data/repositories/file_repository_impl.dart';
import '../../../../core/ssh/ssh_client.dart';
import '../../../../core/ssh/sftp_client.dart';
import '../../../providers/ssh_connection_provider.dart';
import 'dart:async';

part 'files_provider.g.dart';

@riverpod
FileRepository fileRepository(FileRepositoryRef ref) {
  final sshClient = ref.watch(sshClientProvider);
  final sftpClient = SFTPClient(sshClient, allowedRoot: '/home');
  
  ref.onDispose(() async {
    await sftpClient.close();
  });
  
  return FileRepositoryImpl(sshClient, sftpClient);
}

@riverpod
class Files extends _$Files {
  Timer? _debounceTimer;
  Completer<void>? _completer;
  
  @override
  Future<List<FileNode>> build(String serverId, String path) async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _debounceTimer = null;
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.completeError(StateError('Provider disposed'));
      }
      _completer = null;
    });
    
    final repository = ref.watch(fileRepositoryProvider);
    return await repository.listFiles(serverId, path);
  }

  Future<void> refresh() async {
    _debounceTimer?.cancel();
    
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(StateError('Refresh cancelled'));
    }
    
    final completer = Completer<void>();
    _completer = completer;
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!completer.isCompleted) {
        try {
          ref.invalidateSelf();
          completer.complete();
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      }
    });
    
    return completer.future;
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
