import 'dart:convert';

class Exercise {
  final String id;
  final String name;
  final String description;
  final MuscleGroup muscleGroup;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.createdAt,
    this.updatedAt,
  });

  // Crear copia con modificaciones
  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    MuscleGroup? muscleGroup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Crear desde Map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      muscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == map['muscleGroup'],
        orElse: () => MuscleGroup.pecho,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  // Convertir a JSON
  String toJson() => json.encode(toMap());

  // Crear desde JSON
  factory Exercise.fromJson(String source) => Exercise.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, muscleGroup: $muscleGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum para grupos musculares
enum MuscleGroup {
  pecho('Pecho', '💪'),
  espalda('Espalda', '🗡️'),
  piernas('Piernas', '🦵'),
  hombros('Hombros', '👐'),
  brazos('Brazos', '💪'),
  abdomen('Abdomen', '🎯'),
  cardio('Cardio', '❤️'),
  funcional('Funcional', '⚡');

  const MuscleGroup(this.displayName, this.icon);
  
  final String displayName;
  final String icon;

  // Obtener color para cada grupo muscular
  static String getColorHex(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.pecho:
        return '#DC143C'; // Rojo
      case MuscleGroup.espalda:
        return '#8B0000'; // Rojo oscuro
      case MuscleGroup.piernas:
        return '#FF6B6B'; // Rojo claro
      case MuscleGroup.hombros:
        return '#FF4757'; // Rojo vibrante
      case MuscleGroup.brazos:
        return '#C0392B'; // Rojo ladrillo
      case MuscleGroup.abdomen:
        return '#E74C3C'; // Rojo coral
      case MuscleGroup.cardio:
        return '#FF5252'; // Rojo brillante
      case MuscleGroup.funcional:
        return '#B71C1C'; // Rojo muy oscuro
    }
  }

  // Obtener descripción del grupo
  static String getDescription(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.pecho:
        return 'Ejercicios para desarrollar el pecho y pectorales';
      case MuscleGroup.espalda:
        return 'Ejercicios para fortalecer la espalda y dorsales';
      case MuscleGroup.piernas:
        return 'Ejercicios para piernas, glúteos y tren inferior';
      case MuscleGroup.hombros:
        return 'Ejercicios para deltoides y hombros';
      case MuscleGroup.brazos:
        return 'Ejercicios para bíceps, tríceps y antebrazos';
      case MuscleGroup.abdomen:
        return 'Ejercicios para core y músculos abdominales';
      case MuscleGroup.cardio:
        return 'Ejercicios cardiovasculares y de resistencia';
      case MuscleGroup.funcional:
        return 'Ejercicios funcionales y de movimiento completo';
    }
  }
} 