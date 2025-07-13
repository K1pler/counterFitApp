import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class ExerciseService {
  static const String _exercisesKey = 'exercises';
  
  // Singleton
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  // Obtener todos los ejercicios
  Future<List<Exercise>> getAllExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getStringList(_exercisesKey) ?? [];
      
      return exercisesJson
          .map((json) => Exercise.fromJson(json))
          .toList()
        ..sort((a, b) => a.muscleGroup.index.compareTo(b.muscleGroup.index));
    } catch (e) {
      log('Error al obtener ejercicios: $e');
      return [];
    }
  }

  // Obtener ejercicios por grupo muscular
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup muscleGroup) async {
    try {
      final allExercises = await getAllExercises();
      return allExercises
          .where((exercise) => exercise.muscleGroup == muscleGroup)
          .toList();
    } catch (e) {
      log('Error al obtener ejercicios por grupo: $e');
      return [];
    }
  }

  // Obtener ejercicio por ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final allExercises = await getAllExercises();
      return allExercises.firstWhere(
        (exercise) => exercise.id == id,
        orElse: () => throw Exception('Ejercicio no encontrado'),
      );
    } catch (e) {
      log('Error al obtener ejercicio por ID: $e');
      return null;
    }
  }

  // Crear ejercicio
  Future<bool> createExercise(Exercise exercise) async {
    try {
      final allExercises = await getAllExercises();
      
      // Verificar que no exista un ejercicio con el mismo ID
      if (allExercises.any((e) => e.id == exercise.id)) {
        throw Exception('Ya existe un ejercicio con este ID');
      }
      
      allExercises.add(exercise);
      return await _saveExercises(allExercises);
    } catch (e) {
      log('Error al crear ejercicio: $e');
      return false;
    }
  }

  // Actualizar ejercicio
  Future<bool> updateExercise(Exercise updatedExercise) async {
    try {
      final allExercises = await getAllExercises();
      final index = allExercises.indexWhere((e) => e.id == updatedExercise.id);
      
      if (index == -1) {
        throw Exception('Ejercicio no encontrado');
      }
      
      allExercises[index] = updatedExercise.copyWith(
        updatedAt: DateTime.now(),
      );
      
      return await _saveExercises(allExercises);
    } catch (e) {
      log('Error al actualizar ejercicio: $e');
      return false;
    }
  }

  // Eliminar ejercicio
  Future<bool> deleteExercise(String id) async {
    try {
      final allExercises = await getAllExercises();
      final initialLength = allExercises.length;
      
      allExercises.removeWhere((exercise) => exercise.id == id);
      
      if (allExercises.length == initialLength) {
        throw Exception('Ejercicio no encontrado');
      }
      
      return await _saveExercises(allExercises);
    } catch (e) {
      log('Error al eliminar ejercicio: $e');
      return false;
    }
  }

  // Buscar ejercicios por nombre
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      if (query.isEmpty) return await getAllExercises();
      
      final allExercises = await getAllExercises();
      final lowerQuery = query.toLowerCase();
      
      return allExercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(lowerQuery) ||
              exercise.description.toLowerCase().contains(lowerQuery) ||
              exercise.muscleGroup.displayName.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      log('Error al buscar ejercicios: $e');
      return [];
    }
  }

  // Obtener estadísticas
  Future<Map<String, int>> getStatistics() async {
    try {
      final allExercises = await getAllExercises();
      final stats = <String, int>{};
      
      // Contar ejercicios por grupo muscular
      for (final group in MuscleGroup.values) {
        stats[group.displayName] = allExercises
            .where((exercise) => exercise.muscleGroup == group)
            .length;
      }
      
      stats['Total'] = allExercises.length;
      return stats;
    } catch (e) {
      log('Error al obtener estadísticas: $e');
      return {};
    }
  }

  // Crear ejercicios predeterminados
  Future<bool> createDefaultExercises() async {
    try {
      final defaultExercises = [
        // Pecho
        Exercise(
          id: 'pecho_1',
          name: 'Press de Banca',
          description: 'Ejercicio básico para desarrollo del pecho',
          muscleGroup: MuscleGroup.pecho,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'pecho_2',
          name: 'Flexiones',
          description: 'Ejercicio con peso corporal para pecho',
          muscleGroup: MuscleGroup.pecho,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'pecho_3',
          name: 'Aperturas con Mancuernas',
          description: 'Ejercicio de aislamiento para pecho',
          muscleGroup: MuscleGroup.pecho,
          createdAt: DateTime.now(),
        ),
        
        // Espalda
        Exercise(
          id: 'espalda_1',
          name: 'Dominadas',
          description: 'Ejercicio para desarrollar la espalda y dorsales',
          muscleGroup: MuscleGroup.espalda,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'espalda_2',
          name: 'Remo con Barra',
          description: 'Ejercicio para fortalecer la espalda media',
          muscleGroup: MuscleGroup.espalda,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'espalda_3',
          name: 'Peso Muerto',
          description: 'Ejercicio compuesto para espalda y piernas',
          muscleGroup: MuscleGroup.espalda,
          createdAt: DateTime.now(),
        ),
        
        // Piernas
        Exercise(
          id: 'piernas_1',
          name: 'Sentadillas',
          description: 'Ejercicio fundamental para piernas y glúteos',
          muscleGroup: MuscleGroup.piernas,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'piernas_2',
          name: 'Zancadas',
          description: 'Ejercicio unilateral para piernas',
          muscleGroup: MuscleGroup.piernas,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'piernas_3',
          name: 'Prensa de Piernas',
          description: 'Ejercicio en máquina para desarrollo de piernas',
          muscleGroup: MuscleGroup.piernas,
          createdAt: DateTime.now(),
        ),
        
        // Hombros
        Exercise(
          id: 'hombros_1',
          name: 'Press Militar',
          description: 'Ejercicio para desarrollo de hombros',
          muscleGroup: MuscleGroup.hombros,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'hombros_2',
          name: 'Elevaciones Laterales',
          description: 'Ejercicio de aislamiento para deltoides medio',
          muscleGroup: MuscleGroup.hombros,
          createdAt: DateTime.now(),
        ),
        
        // Brazos
        Exercise(
          id: 'brazos_1',
          name: 'Curl de Bíceps',
          description: 'Ejercicio para desarrollo de bíceps',
          muscleGroup: MuscleGroup.brazos,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'brazos_2',
          name: 'Press Francés',
          description: 'Ejercicio para desarrollo de tríceps',
          muscleGroup: MuscleGroup.brazos,
          createdAt: DateTime.now(),
        ),
        
        // Abdomen
        Exercise(
          id: 'abdomen_1',
          name: 'Crunches',
          description: 'Ejercicio básico para abdominales',
          muscleGroup: MuscleGroup.abdomen,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'abdomen_2',
          name: 'Plancha',
          description: 'Ejercicio isométrico para core',
          muscleGroup: MuscleGroup.abdomen,
          createdAt: DateTime.now(),
        ),
        
        // Cardio
        Exercise(
          id: 'cardio_1',
          name: 'Burpees',
          description: 'Ejercicio cardiovascular de alta intensidad',
          muscleGroup: MuscleGroup.cardio,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'cardio_2',
          name: 'Mountain Climbers',
          description: 'Ejercicio cardiovascular para todo el cuerpo',
          muscleGroup: MuscleGroup.cardio,
          createdAt: DateTime.now(),
        ),
        
        // Funcional
        Exercise(
          id: 'funcional_1',
          name: 'Thrusters',
          description: 'Ejercicio funcional combinando sentadilla y press',
          muscleGroup: MuscleGroup.funcional,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'funcional_2',
          name: 'Turkish Get-Up',
          description: 'Ejercicio funcional completo con kettlebell',
          muscleGroup: MuscleGroup.funcional,
          createdAt: DateTime.now(),
        ),
      ];

      for (final exercise in defaultExercises) {
        await createExercise(exercise);
      }
      
      return true;
    } catch (e) {
      log('Error al crear ejercicios predeterminados: $e');
      return false;
    }
  }

  // Limpiar todos los ejercicios
  Future<bool> clearAllExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_exercisesKey);
      return true;
    } catch (e) {
      log('Error al limpiar ejercicios: $e');
      return false;
    }
  }

  // Método privado para guardar ejercicios
  Future<bool> _saveExercises(List<Exercise> exercises) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = exercises.map((e) => e.toJson()).toList();
      await prefs.setStringList(_exercisesKey, exercisesJson);
      return true;
    } catch (e) {
      log('Error al guardar ejercicios: $e');
      return false;
    }
  }

  // Generar ID único
  String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }
} 