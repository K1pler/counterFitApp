import 'dart:developer';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import 'exercise_form_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> with TickerProviderStateMixin {
  final ExerciseService _exerciseService = ExerciseService();
  late TabController _tabController;
  
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  String _searchQuery = '';
  bool _isLoading = true;
  MuscleGroup? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: MuscleGroup.values.length + 1, vsync: this);
    _loadExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _exercises = await _exerciseService.getAllExercises();
      if (_exercises.isEmpty) {
        await _exerciseService.createDefaultExercises();
        _exercises = await _exerciseService.getAllExercises();
      }
      _filterExercises();
    } catch (e) {
      log('Error al cargar ejercicios: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterExercises() {
    _filteredExercises = _exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesMuscleGroup = _selectedMuscleGroup == null || 
          exercise.muscleGroup == _selectedMuscleGroup;

      return matchesSearch && matchesMuscleGroup;
    }).toList();
  }

  void _onTabChanged(int index) {
    setState(() {
      if (index == 0) {
        _selectedMuscleGroup = null;
      } else {
        _selectedMuscleGroup = MuscleGroup.values[index - 1];
      }
      _filterExercises();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterExercises();
    });
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final confirmed = await _showDeleteConfirmation(exercise);
    if (confirmed) {
      final success = await _exerciseService.deleteExercise(exercise.id);
      if (success) {
        _showSnackBar('Ejercicio eliminado', AppColors.successColor);
        await _loadExercises();
      } else {
        _showSnackBar('Error al eliminar ejercicio', AppColors.errorColor);
      }
    }
  }

  Future<bool> _showDeleteConfirmation(Exercise exercise) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(
          'Eliminar Ejercicio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${exercise.name}"?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: _buildExercisesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseFormScreen(),
            ),
          );
          if (result == true) {
            await _loadExercises();
          }
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_filteredExercises.length} ejercicios encontrados',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.primaryRed,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textHint.withValues(alpha: 0.3),
          ),
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar ejercicios...',
            hintStyle: TextStyle(color: AppColors.textHint),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textHint,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: TabBar(
        controller: _tabController,
        onTap: _onTabChanged,
        isScrollable: true,
        indicatorColor: AppColors.primaryRed,
        labelColor: AppColors.primaryRed,
        unselectedLabelColor: AppColors.textHint,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: 'Todos'),
          ...MuscleGroup.values.map((group) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group.icon),
                const SizedBox(width: 8),
                Text(group.displayName),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron ejercicios'
                  : 'No hay ejercicios disponibles',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Agrega tu primer ejercicio',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final colorHex = MuscleGroup.getColorHex(exercise.muscleGroup);
    final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseFormScreen(exercise: exercise),
              ),
            );
            if (result == true) {
              await _loadExercises();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.muscleGroup.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.muscleGroup.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textHint,
                      ),
                      color: AppColors.cardColor,
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseFormScreen(exercise: exercise),
                              ),
                            );
                            if (result == true) {
                              await _loadExercises();
                            }
                            break;
                          case 'delete':
                            await _deleteExercise(exercise);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Editar',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: AppColors.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


} 