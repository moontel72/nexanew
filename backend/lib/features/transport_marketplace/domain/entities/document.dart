import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final String url;
  final DateTime uploadedAt;

  const Document({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  @override
  List<Object> get props => [id, ownerId, name, type, url, uploadedAt];
}

