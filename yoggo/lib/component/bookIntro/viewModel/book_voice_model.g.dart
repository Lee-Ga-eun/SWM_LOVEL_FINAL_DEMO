// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_voice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookVoiceModel _$BookVoiceModelFromJson(Map<String, dynamic> json) =>
    BookVoiceModel(
      contentVoiceId: json['contentVoiceId'] as int,
      voiceId: json['voiceId'] as int,
      voiceName: json['voiceName'] as String,
      clicked: json['clicked'] as bool? ?? false,
    );

Map<String, dynamic> _$BookVoiceModelToJson(BookVoiceModel instance) =>
    <String, dynamic>{
      'contentVoiceId': instance.contentVoiceId,
      'voiceId': instance.voiceId,
      'voiceName': instance.voiceName,
      'clicked': instance.clicked,
    };
