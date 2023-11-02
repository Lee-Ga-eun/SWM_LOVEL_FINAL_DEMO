// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      titleKo: json['titleKo'] as String,
      content: json['content'] as String,
      contentKo: json['contentKo'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleKo': instance.titleKo,
      'content': instance.content,
      'contentKo': instance.contentKo,
      'createdAt': instance.createdAt,
    };
