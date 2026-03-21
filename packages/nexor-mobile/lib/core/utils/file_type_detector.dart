import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/colors.dart';

class FileTypeDetector {
  static String getLanguage(String path) {
    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      case 'dart':
        return 'dart';
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      case 'jsx':
        return 'javascript';
      case 'tsx':
        return 'typescript';
      case 'py':
        return 'python';
      case 'java':
        return 'java';
      case 'kt':
      case 'kts':
        return 'kotlin';
      case 'swift':
        return 'swift';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'cpp':
      case 'cc':
      case 'cxx':
      case 'c++':
        return 'cpp';
      case 'c':
        return 'c';
      case 'h':
      case 'hpp':
        return 'cpp';
      case 'cs':
        return 'csharp';
      case 'json':
        return 'json';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'xml':
        return 'xml';
      case 'html':
      case 'htm':
        return 'html';
      case 'css':
        return 'css';
      case 'scss':
      case 'sass':
        return 'scss';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'sh':
      case 'bash':
      case 'zsh':
        return 'bash';
      case 'sql':
        return 'sql';
      case 'rb':
        return 'ruby';
      case 'php':
        return 'php';
      case 'vue':
        return 'vue';
      case 'svelte':
        return 'svelte';
      case 'graphql':
      case 'gql':
        return 'graphql';
      case 'dockerfile':
        return 'dockerfile';
      default:
        return 'plaintext';
    }
  }

  static IconData getIcon(String path, bool isDirectory) {
    if (isDirectory) return PhosphorIconsRegular.folder;

    final ext = path.split('.').last.toLowerCase();
    final name = path.split('/').last.toLowerCase();

    // Special files
    if (name == 'dockerfile') return PhosphorIconsRegular.fileCode;
    if (name == '.gitignore') return PhosphorIconsRegular.gitBranch;
    if (name == 'readme.md') return PhosphorIconsRegular.fileDoc;

    switch (ext) {
      case 'dart':
        return PhosphorIconsRegular.fileCode;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'tsx':
        return PhosphorIconsRegular.fileJs;
      case 'json':
        return PhosphorIconsRegular.fileCode;
      case 'md':
      case 'markdown':
        return PhosphorIconsRegular.fileDoc;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
      case 'webp':
      case 'ico':
        return PhosphorIconsRegular.fileImage;
      case 'pdf':
        return PhosphorIconsRegular.filePdf;
      case 'zip':
      case 'tar':
      case 'gz':
      case 'rar':
      case '7z':
        return PhosphorIconsRegular.fileZip;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return PhosphorIconsRegular.fileVideo;
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'flac':
        return PhosphorIconsRegular.fileAudio;
      case 'html':
      case 'htm':
        return PhosphorIconsRegular.fileHtml;
      case 'css':
      case 'scss':
      case 'sass':
        return PhosphorIconsRegular.fileCss;
      case 'py':
      case 'java':
      case 'kt':
      case 'swift':
      case 'go':
      case 'rs':
      case 'cpp':
      case 'c':
      case 'cs':
      case 'php':
      case 'rb':
        return PhosphorIconsRegular.fileCode;
      case 'txt':
      case 'log':
        return PhosphorIconsRegular.fileText;
      default:
        return PhosphorIconsRegular.file;
    }
  }

  static Color getColor(String path, bool isDirectory) {
    if (isDirectory) return AppColors.primary;

    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      case 'dart':
        return const Color(0xFF0175C2);
      case 'js':
      case 'jsx':
        return const Color(0xFFF7DF1E);
      case 'ts':
      case 'tsx':
        return const Color(0xFF3178C6);
      case 'py':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      case 'kt':
      case 'kts':
        return const Color(0xFF7F52FF);
      case 'swift':
        return const Color(0xFFFA7343);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'rs':
        return const Color(0xFFCE422B);
      case 'json':
        return const Color(0xFF30D158);
      case 'md':
      case 'markdown':
        return const Color(0xFFBF40BF);
      case 'html':
      case 'htm':
        return const Color(0xFFE34C26);
      case 'css':
      case 'scss':
      case 'sass':
        return const Color(0xFF1572B6);
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
      case 'webp':
        return const Color(0xFFFF69B4);
      case 'pdf':
        return const Color(0xFFFF453A);
      case 'zip':
      case 'tar':
      case 'gz':
      case 'rar':
        return const Color(0xFFFFCC00);
      case 'mp4':
      case 'mov':
      case 'avi':
        return const Color(0xFFFF9500);
      case 'mp3':
      case 'wav':
      case 'ogg':
        return const Color(0xFF5E5CE6);
      default:
        return AppColors.textSecondary;
    }
  }

  static String getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      case 'txt':
        return 'text/plain';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
