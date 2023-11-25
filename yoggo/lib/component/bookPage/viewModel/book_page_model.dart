import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_page_model.g.dart';

@JsonSerializable()
class BookPageModel extends Equatable {
  final int contentVoiceId;
  final int pageNum;
  final String text;
  final String imageUrl;
  final int position;
  final String audioUrl;
  final String imageLocalPath;
  final String audioLocalPath;
  String textKr;

  BookPageModel({
    required this.contentVoiceId,
    required this.pageNum,
    required this.text,
    required this.textKr,
    required this.imageUrl,
    required this.position,
    required this.audioUrl,
    required this.imageLocalPath,
    required this.audioLocalPath,
  });

  factory BookPageModel.fromJson(Map<String, dynamic> json) =>
      _$BookPageModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookPageModelToJson(this);

  @override
  List<Object?> get props => [
        contentVoiceId,
        pageNum,
        text,
        textKr,
        imageUrl,
        position,
        audioUrl,
        imageLocalPath,
        audioLocalPath
      ];
}
 // 위와 같이 모든 코드를 작성하고 flutter pub run build_runner build --delete-conflicting-outputs를 해야 g.dart파일이 만들어진다