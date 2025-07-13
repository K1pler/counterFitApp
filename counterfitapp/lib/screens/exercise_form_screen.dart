import 'dart:developer';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExerciseService _exerciseService = ExerciseService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  MuscleGroup _selectedMuscleGroup = MuscleGroup.pecho;
  bool _isLoading = false;
  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final exercise = widget.exercise;
    
    _nameController = TextEditingController(text: exercise?.name ?? '');
    _descriptionController = TextEditingController(text: exercise?.description ?? '');
    
    if (exercise != null) {
      _selectedMuscleGroup = exercise.muscleGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final exercise = Exercise(
        id: widget.exercise?.id ?? _exerciseService.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        createdAt: widget.exercise?.createdAt ?? DateTime.now(),
        updatedAt: _isEditing ? DateTime.now() : null,
      );

      bool success;
      if (_isEditing) {
        success = await _exerciseService.updateExercise(exercise);
      } else {
        success = await _exerciseService.createExercise(exercise);
      }

      if (success) {
        if (mounted) {
          _showSnackBar(
            _isEditing ? 'Ejercicio actualizado' : 'Ejercicio creado',
            AppColors.successColor,
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          _showSnackBar('Error al guardar ejercicio', AppColors.errorColor);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', AppColors.errorColor);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveExercise,
              child: Text(
                'Guardar',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Grupo Muscular'),
              const SizedBox(height: 16),
              _buildMuscleGroupSelector(),
              const SizedBox(height: 32),
              
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        controller: _nameController,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'Nombre del ejercicio',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintText: 'Ej. Press de banca',
          hintStyle: TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.fitness_center,
            color: AppColors.primaryRed,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es obligatorio';
          }
          if (value.trim().length < 2) {
            return 'El nombre debe tener al menos 2 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        controller: _descriptionController,
        style: TextStyle(color: AppColors.textPrimary),
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Descripción',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintText: 'Describe cómo realizar el ejercicio...',
          hintStyle: TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Icon(
              Icons.description,
              color: AppColors.primaryRed,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'La descripción es obligatoria';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMuscleGroupSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppColors.primaryRed,
                ),
                const SizedBox(width: 12),
                Text(
                  'Selecciona el grupo muscular',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: MuscleGroup.values.length,
            itemBuilder: (context, index) {
              final group = MuscleGroup.values[index];
              final isSelected = group == _selectedMuscleGroup;
              final colorHex = MuscleGroup.getColorHex(group);
              final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMuscleGroup = group;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? color : AppColors.textHint.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          group.displayName,
                          style: TextStyle(
                            color: isSelected ? color : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExercise,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isEditing ? Icons.save : Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Actualizar Ejercicio' : 'Crear Ejercicio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 