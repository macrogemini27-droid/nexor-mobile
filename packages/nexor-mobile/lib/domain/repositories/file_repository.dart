import '../entities/file_node.dart';
import '../entities/file_content.dart';

abstract class FileRepository {
  Future<List<FileNode>> listFiles(String serverId, String path);
  Future<FileContent> readFile(String serverId, String path);
  Future<List<FileNode>> searchFiles(String serverId, String query);
  Future<List<FileNode>> searchContent(String serverId, String pattern);
  Future<Map<String, String>> getGitStatus(String serverId, String path);
}
