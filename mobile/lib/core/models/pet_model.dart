import 'package:json_annotation/json_annotation.dart';

part 'pet_model.g.dart';

@JsonSerializable()
class Pet {
  final String id;
  final String userId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? gender;
  final String? profileImageUrl;
  final String? microchipNumber;
  final DateTime? adoptionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weight,
    this.gender,
    this.profileImageUrl,
    this.microchipNumber,
    this.adoptionDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
  Map<String, dynamic> toJson() => _$PetToJson(this);

  Pet copyWith({
    String? id,
    String? userId,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? profileImageUrl,
    String? microchipNumber,
    DateTime? adoptionDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters
  String get age {
    if (birthDate == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(birthDate!);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months months';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingDays = difference.inDays % 365;
      final remainingMonths = remainingDays / 30;
      
      if (remainingMonths > 0) {
        return '$years years ${remainingMonths.floor()} months';
      } else {
        return '$years years';
      }
    }
  }

  int get ageInMonths {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    return (now.difference(birthDate!).inDays / 30).floor();
  }

  String get healthStatus {
    // This would be calculated based on health records
    // For now, return a default status
    if (ageInMonths < 6) return 'Excellent';
    if (ageInMonths < 12) return 'Good';
    if (ageInMonths < 84) return 'Good';
    return 'Attention needed';
  }

  String get formattedWeight {
    if (weight == null) return 'Unknown';
    return '${weight!.toStringAsFixed(1)} kg';
  }

  String get displayBreed {
    if (breed == null || breed!.isEmpty) {
      return species;
    }
    return breed!;
  }

  String get avatarText {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, species: $species, breed: $breed)';
  }
}