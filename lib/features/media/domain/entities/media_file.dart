enum MediaType { photo, video }
class MediaFile {
  final String id; final String name; final String path; final int sizeBytes;
  final DateTime createdAt; final DateTime modifiedAt; final MediaType type;
  final int? width; final int? height; final Duration? duration;
  const MediaFile({required this.id, required this.name, required this.path, required this.sizeBytes, required this.createdAt, required this.modifiedAt, required this.type, this.width, this.height, this.duration});
}
