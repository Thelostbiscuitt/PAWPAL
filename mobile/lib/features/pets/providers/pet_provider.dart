import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/pet_model.dart';

class PetProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load user's pets
  Future<void> loadPets() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getPets();
      
      if (response.success && response.data != null) {
        final petsData = response.data['pets'] as List;
        _pets = petsData.map((pet) => Pet.fromJson(pet)).toList();
        _setError(null);
      } else {
        _setError(response.error ?? 'Failed to load pets');
      }
    } catch (e) {
      _setError('Failed to load pets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add new pet
  Future<bool> addPet({
    required String name,
    required String species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? microchipNumber,
    DateTime? adoptionDate,
    String? notes,
    dynamic profileImage,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final petData = {
        'name': name,
        'species': species,
        'breed': breed,
        'birthDate': birthDate?.toIso8601String(),
        'weight': weight,
        'gender': gender,
        'microchipNumber': microchipNumber,
        'adoptionDate': adoptionDate?.toIso8601String(),
        'notes': notes,
      };

      final response = await _apiService.addPet(petData);
      
      if (response.success && response.data != null) {
        final newPet = Pet.fromJson(response.data['pet']);
        _pets.add(newPet);
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Failed to add pet');
        return false;
      }
    } catch (e) {
      _setError('Failed to add pet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update pet
  Future<bool> updatePet(String petId, {
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? microchipNumber,
    DateTime? adoptionDate,
    String? notes,
    dynamic profileImage,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final petData = <String, dynamic>{};
      
      if (name != null) petData['name'] = name;
      if (species != null) petData['species'] = species;
      if (breed != null) petData['breed'] = breed;
      if (birthDate != null) petData['birthDate'] = birthDate!.toIso8601String();
      if (weight != null) petData['weight'] = weight;
      if (gender != null) petData['gender'] = gender;
      if (microchipNumber != null) petData['microchipNumber'] = microchipNumber;
      if (adoptionDate != null) petData['adoptionDate'] = adoptionDate!.toIso8601String();
      if (notes != null) petData['notes'] = notes;

      final response = await _apiService.updatePet(petId, petData);
      
      if (response.success && response.data != null) {
        final updatedPet = Pet.fromJson(response.data['pet']);
        final index = _pets.indexWhere((pet) => pet.id == petId);
        if (index != -1) {
          _pets[index] = updatedPet;
        }
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Failed to update pet');
        return false;
      }
    } catch (e) {
      _setError('Failed to update pet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete pet
  Future<bool> deletePet(String petId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deletePet(petId);
      
      if (response.success) {
        _pets.removeWhere((pet) => pet.id == petId);
        _setError(null);
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete pet');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete pet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get pet by ID
  Pet? getPetById(String petId) {
    try {
      return _pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }

  // Update pet locally (without API call)
  void updatePetLocally(Pet updatedPet) {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      notifyListeners();
    }
  }

  // Get pets by species
  List<Pet> getPetsBySpecies(String species) {
    return _pets.where((pet) => pet.species.toLowerCase() == species.toLowerCase()).toList();
  }

  // Get pet statistics
  Map<String, dynamic> getPetStatistics() {
    if (_pets.isEmpty) {
      return {
        'total': 0,
        'dogs': 0,
        'cats': 0,
        'others': 0,
      };
    }

    final stats = <String, dynamic>{
      'total': _pets.length,
      'dogs': 0,
      'cats': 0,
      'others': 0,
    };

    for (final pet in _pets) {
      switch (pet.species.toLowerCase()) {
        case 'dog':
          stats['dogs']++;
          break;
        case 'cat':
          stats['cats']++;
          break;
        default:
          stats['others']++;
          break;
      }
    }

    return stats;
  }

  // Search pets
  List<Pet> searchPets(String query) {
    if (query.isEmpty) return _pets;
    
    final lowerQuery = query.toLowerCase();
    return _pets.where((pet) {
      return pet.name.toLowerCase().contains(lowerQuery) ||
          pet.breed?.toLowerCase().contains(lowerQuery) == true ||
          pet.species.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Sort pets
  void sortPets(SortOption option) {
    switch (option) {
      case SortOption.name:
        _pets.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.species:
        _pets.sort((a, b) => a.species.compareTo(b.species));
        break;
      case SortOption.age:
        _pets.sort((a, b) => a.birthDate.compareTo(b.birthDate));
        break;
      case SortOption.weight:
        _pets.sort((a, b) => (a.weight ?? 0).compareTo(b.weight ?? 0));
        break;
    }
    notifyListeners();
  }

  // Refresh pet data
  Future<void> refreshPetData() async {
    await loadPets();
  }
}

enum SortOption {
  name,
  species,
  age,
  weight,
}