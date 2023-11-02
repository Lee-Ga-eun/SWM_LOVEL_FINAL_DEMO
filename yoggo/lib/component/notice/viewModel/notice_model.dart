import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notice_model.g.dart';

@JsonSerializable()
class NoticeModel extends Equatable {
  final int id;
  final String title;
  final String titleKo;
  final String content;
  final String contentKo;
  final String createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.titleKo,
    required this.content,
    required this.contentKo,
    required this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        titleKo,
        content,
        contentKo,
        createdAt,
      ];
}
