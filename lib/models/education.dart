import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';

/// Model data untuk entri riwayat pendidikan (Education) dari backend DRF.
@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  const Education({
    this.id,
    required this.school,
    required this.degree,
    required this.startYear,
    this.endYear = '',
    required this.description,
    this.logo = '',
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  @JsonKey(includeToJson: false)
  final int? id;

  final String school;
  final String degree;
  final String startYear;
  final String endYear;
  final String description;
  final String logo;

  @JsonKey(includeToJson: false)
  final int starCount;

  @JsonKey(includeToJson: false)
  final bool isStarred;

  @JsonKey(includeToJson: false)
  final String starredByNames;

  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
