import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/media/domain/entities/media_file.dart';
import '../../../../features/media/data/repositories/media_repository_impl.dart';
import '../../../../features/media/domain/repositories/media_repository.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});
  @override State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final MediaRepository _mediaRepo = MediaRepositoryImpl();
  List<MediaFile> _mediaFiles = [];
  bool _isLoading = true;

  @override void initState() { super.initState(); _loadMedia(); }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    try {
      final filter = const NmapFilter(allMedia: true);
      final files = await _mediaRepo.getMediaUI(filter, limit: 100);
      setState(() { _mediaFiles = files; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Media', style: AppTypography.uiHeading), backgroundColor: AppColors.surface, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: Column(
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: AppColors.surfaceElev, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${_mediaFiles.length} items', style: AppTypography.systemLabel), Text('Filter: All', style: AppTypography.systemLabel.copyWith(color: AppColors.cyan))])),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.cyan)) : _mediaFiles.isEmpty ? Center(child: Text('No media found matching filter', style: AppTypography.terminalText.copyWith(color: AppColors.textSecondary))) : GridView.builder(padding: const EdgeInsets.all(8), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: _mediaFiles.length, itemBuilder: (context, index) { final media = _mediaFiles[index]; return Container(decoration: BoxDecoration(color: AppColors.surfaceElev, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: Center(child: Icon(media.type == MediaType.photo ? Icons.image : Icons.videocam, color: AppColors.textDim))); }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.pushNamed(context, '/terminal'), backgroundColor: AppColors.surfaceElev, icon: const Icon(Icons.terminal, color: AppColors.cyan), label: Text('Open in Terminal', style: AppTypography.systemLabel.copyWith(color: AppColors.cyan))),
    );
  }
}
