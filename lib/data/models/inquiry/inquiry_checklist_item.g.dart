// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_checklist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InquiryChecklistItem _$InquiryChecklistItemFromJson(
  Map<String, dynamic> json,
) => InquiryChecklistItem(
  user: json['user'] == null ? const [] : _usersFromJson(json['user']),
  dueDate: json['dueDate'] as String?,
  priority: json['priority'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$InquiryChecklistItemToJson(
  InquiryChecklistItem instance,
) => <String, dynamic>{
  'user': _usersToJson(instance.user),
  'dueDate': instance.dueDate,
  'priority': instance.priority,
  'category': instance.category,
};
