// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookPageModel _$BookPageModelFromJson(Map<String, dynamic> json) =>
    BookPageModel(
      contentVoiceId: json['contentVoiceId'] as int,
      pageNum: json['pageNum'] as int,
      text: json['text'] as String,
      textKr: json['textKr'] as String,
      imageUrl: json['imageUrl'] as String,
      position: json['position'] as int,
      audioUrl: json['audioUrl'] as String,
      imageLocalPath: json['imageLocalPath'] as String,
      audioLocalPath: json['audioLocalPath'] as String,
    );

Map<String, dynamic> _$BookPageModelToJson(BookPageModel instance) =>
    <String, dynamic>{
      'contentVoiceId': instance.contentVoiceId,
      'pageNum': instance.pageNum,
      'text': instance.text,
      'textKr': instance.textKr,
      'imageUrl': instance.imageUrl,
      'position': instance.position,
      'audioUrl': instance.audioUrl,
      'imageLocalPath': instance.imageLocalPath,
      'audioLocalPath': instance.audioLocalPath,
    };
