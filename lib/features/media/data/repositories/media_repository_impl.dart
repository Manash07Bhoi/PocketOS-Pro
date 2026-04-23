import 'package:photo_manager/photo_manager.dart';
import '../../domain/entities/media_file.dart';
import '../../domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  @override Stream<MediaFile> scanStream(NmapFilter filter) async* {
    RequestType requestType = RequestType.common;
    if (filter.photosOnly && !filter.videosOnly && !filter.allMedia) {
      requestType = RequestType.image;
    } else if (filter.videosOnly && !filter.photosOnly && !filter.allMedia) {
      requestType = RequestType.video;
    }
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: requestType, onlyAll: true);
    if (albums.isEmpty) return;
    final AssetPathEntity recentAlbum = albums.first;
    final int assetCount = await recentAlbum.assetCountAsync;
    const int batchSize = 100;
    for (int i = 0; i < assetCount; i += batchSize) {
      final List<AssetEntity> assets = await recentAlbum.getAssetListPaged(page: i ~/ batchSize, size: batchSize);
      for (final asset in assets) {
        if (filter.yearFilter != null && asset.createDateTime.year != filter.yearFilter) continue;
        if (filter.dateFilter != null) {
           final parts = filter.dateFilter!.split('.');
           if (parts.length == 3) {
             final day = int.tryParse(parts[0]); final month = int.tryParse(parts[1]); final year = int.tryParse(parts[2]);
             if (day != null && month != null && year != null) {
               final dt = asset.createDateTime;
               if (dt.year != year || dt.month != month || dt.day != day) continue;
             }
           }
        }
        final file = await asset.file; if (file == null) continue;
        final sizeBytes = await file.length();
        if (filter.sizeFilter != null && filter.sizeFilter!.startsWith('>')) {
           final val = int.tryParse(filter.sizeFilter!.substring(1).replaceAll('MB', ''));
           if (val != null && sizeBytes <= val * 1024 * 1024) continue;
        }
        MediaType type = asset.type == AssetType.image ? MediaType.photo : MediaType.video;
        yield MediaFile(id: asset.id, name: asset.title ?? 'Unknown_${asset.id}', path: file.path, sizeBytes: sizeBytes, createdAt: asset.createDateTime, modifiedAt: asset.modifiedDateTime, type: type, width: asset.width, height: asset.height, duration: Duration(seconds: asset.duration));
      }
    }
  }
  @override Future<List<MediaFile>> getMediaUI(NmapFilter filter, {int limit = 50, int offset = 0}) async {
      final list = <MediaFile>[];
      await for (final m in scanStream(filter)) { list.add(m); if (list.length >= limit + offset) break; }
      return list.length > offset ? list.sublist(offset) : [];
  }
  @override Future<Map<String, dynamic>> getMediaStats() async => {};
}
