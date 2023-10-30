// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_intro_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookIntroModel _$BookIntroModelFromJson(Map<String, dynamic> json) =>
    BookIntroModel(
      contentId: json['contentId'] as int,
      title: json['title'] as String,
      thumbUrl: json['thumbUrl'] as String,
      summary: json['summary'] as String,
      last: json['last'] as int,
      voice: json['voice'] as List<dynamic>,
      font: json['font'] as String,
      lock: json['lock'] as bool,
      price: json['price'] as int,
    );

Map<String, dynamic> _$BookIntroModelToJson(BookIntroModel instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'title': instance.title,
      'thumbUrl': instance.thumbUrl,
      'summary': instance.summary,
      'last': instance.last,
      'voice': instance.voice,
      'font': instance.font,
      'lock': instance.lock,
      'price': instance.price,
    };
