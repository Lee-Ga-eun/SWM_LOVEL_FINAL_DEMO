// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeScreenBookModel _$HomeScreenBookModelFromJson(Map<String, dynamic> json) =>
    HomeScreenBookModel(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbUrl: json['thumbUrl'] as String,
      summary: json['summary'] as String,
      createdAt: json['createdAt'] as String,
      last: json['last'] as int,
      age: json['age'] as int,
      visible: json['visible'] as bool,
      isNew: json['new'] as bool,
      badge: json['badge'] as String?,
      sequence: json['sequence'] as int?,
      lock: json['lock'] as bool,
    );

Map<String, dynamic> _$HomeScreenBookModelToJson(
        HomeScreenBookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'thumbUrl': instance.thumbUrl,
      'summary': instance.summary,
      'createdAt': instance.createdAt,
      'last': instance.last,
      'age': instance.age,
      'visible': instance.visible,
      'new': instance.isNew,
      'badge': instance.badge,
      'sequence': instance.sequence,
      'lock': instance.lock,
    };
