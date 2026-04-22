import 'dart:async';
import '../../core/kernel/command_parser.dart';
import '../base/base_tool.dart';
import '../../features/media/domain/repositories/media_repository.dart';
import '../../core/utils/permission_service.dart';

extension NmapFilterExt on NmapFilter {
  static NmapFilter fromCommand(ParsedCommand cmd) {
    return NmapFilter(
      photosOnly: cmd.flags.containsKey('-p') || cmd.flags.containsKey('--photos'),
      videosOnly: cmd.flags.containsKey('-v') || cmd.flags.containsKey('--videos'),
      allMedia: cmd.flags.containsKey('-a') || cmd.flags.containsKey('--all'),
      dateFilter: cmd.flags['-d'] ?? cmd.flags['--date'],
      yearFilter: int.tryParse(cmd.flags['--year'] ?? ''),
      sizeFilter: cmd.flags['--size'],
      outputFormat: cmd.flags['--output'],
    );
  }
}

class NmapTool extends BaseTool {
  final MediaRepository mediaRepo;
  NmapTool(this.mediaRepo);

  @override String get name => 'nmap';
  @override String get version => '1.0.0';
  @override String get description => 'Media scanner — scan photos/videos by date, size, type';
  @override String get helpText => '''nmap $version - Media Scanner...'''; // shortened for brevity
  @override List<String> get supportedFlags => ['-p', '--photos', '-v', '--videos', '-a', '--all', '-d', '--date', '--year', '--size', '--output'];

  @override String? validateArgs(ParsedCommand command) {
    if (!command.flags.containsKey('-p') && !command.flags.containsKey('--photos') && !command.flags.containsKey('-v') && !command.flags.containsKey('--videos') && !command.flags.containsKey('-a') && !command.flags.containsKey('--all')) {
      return 'Error: Must specify scan target (-p, -v, or -a)';
    }
    return null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override Stream<ToolOutputLine> execute(ParsedCommand cmd) async* {
    final error = validateArgs(cmd);
    if (error != null) { yield ToolOutputLine(error, type: OutputType.error); return; }
    final hasPermission = await PermissionService.hasMediaPermission();
    if (!hasPermission) { yield const ToolOutputLine('Permission denied. Run: permission grant media', type: OutputType.error); return; }

    final filter = NmapFilterExt.fromCommand(cmd);
    yield const ToolOutputLine('Starting nmap scan...', type: OutputType.info);
    yield ToolOutputLine('Target: ${filter.targetLabel}', type: OutputType.info);

    final isDetail = filter.outputFormat == 'detail';
    int count = 0; int totalBytes = 0; final stopwatch = Stopwatch()..start();

    try {
      await for (final media in mediaRepo.scanStream(filter)) {
        count++; totalBytes += media.sizeBytes;
        if (isDetail) {
           final dateStr = '${media.createdAt.day.toString().padLeft(2, '0')}.${media.createdAt.month.toString().padLeft(2, '0')}.${media.createdAt.year}';
           yield ToolOutputLine('[${count.toString().padLeft(3, '0')}] ${media.name.padRight(15)} ${_formatBytes(media.sizeBytes).padLeft(10)}    $dateStr', type: OutputType.system);
        } else if (count % 50 == 0) {
            yield ToolOutputLine('Scanning... $count files found', type: OutputType.progress);
        }
      }
    } catch (e) { yield ToolOutputLine('Scan failed: $e', type: OutputType.error); return; }

    stopwatch.stop();
    yield const ToolOutputLine('');
    yield const ToolOutputLine('✔ Scan complete', type: OutputType.success);
    yield ToolOutputLine('  Files found:    $count', type: OutputType.system);
    yield ToolOutputLine('  Total size:     ${_formatBytes(totalBytes)}', type: OutputType.system);
  }
}
