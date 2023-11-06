import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class HomeDummyModel extends Equatable {
  final int id;
  final String title;
  final String thumbUrl;

  HomeDummyModel({
    required this.id,
    required this.title,
    required this.thumbUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        thumbUrl,
      ];
}
