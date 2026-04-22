import '../entities/media_file.dart';
class NmapFilter {
  final bool photosOnly; final bool videosOnly; final bool allMedia;
  final String? dateFilter; final int? yearFilter; final String? sizeFilter; final String? outputFormat;
  const NmapFilter({this.photosOnly = false, this.videosOnly = false, this.allMedia = false, this.dateFilter, this.yearFilter, this.sizeFilter, this.outputFormat});
  String get targetLabel {
    if (allMedia) return 'All Media'; if (photosOnly && videosOnly) return 'Photos & Videos';
    if (photosOnly) return 'Photos'; if (videosOnly) return 'Videos'; return 'All Media';
  }
}
abstract class MediaRepository {
  Stream<MediaFile> scanStream(NmapFilter filter);
  Future<List<MediaFile>> getMediaUI(NmapFilter filter, {int limit = 50, int offset = 0});
  Future<Map<String, dynamic>> getMediaStats();
}
