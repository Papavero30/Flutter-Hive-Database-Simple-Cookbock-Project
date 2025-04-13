import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_cook_book/models/recipe.dart';
import 'dart:math';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _isEditing = true;
      _titleController.text = widget.recipe!.title;
      
      // Load ingredients
      for (var ingredient in widget.recipe!.ingredients) {
        final controller = TextEditingController(text: ingredient);
        _ingredientControllers.add(controller);
      }
      
      // Load steps
      for (var step in widget.recipe!.steps) {
        final controller = TextEditingController(text: step);
        _stepControllers.add(controller);
      }
    }
    
    // Add an empty ingredient field if none exist
    if (_ingredientControllers.isEmpty) {
      _ingredientControllers.add(TextEditingController());
    }
    
    // Add an empty step field if none exist
    if (_stepControllers.isEmpty) {
      _stepControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Resep' : 'Tambah Resep Baru'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Resep',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tolong masukkan judul resep';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Ingredients section
            const Text(
              'Bahan Bahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildIngredientFields(),
            OutlinedButton.icon(
              onPressed: _addIngredientField,
              icon: const Icon(Icons.add),
              label: const Text('Tambahkan Bahan'),
            ),
            const SizedBox(height: 20),
            
            // Steps section
            const Text(
              'Langkah Langkah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildStepFields(),
            OutlinedButton.icon(
              onPressed: _addStepField,
              icon: const Icon(Icons.add),
              label: const Text('Tambahkan Langkah'),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(_isEditing ? 'Update Resep' : 'Simpan Resep'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientFields() {
    return List.generate(_ingredientControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ingredientControllers[index],
                decoration: InputDecoration(
                  labelText: 'Bahan ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tolong masukkan bahan';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (_ingredientControllers.length > 1) {
                  setState(() {
                    _ingredientControllers.removeAt(index);
                  });
                }
              },
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildStepFields() {
    return List.generate(_stepControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _stepControllers[index],
                decoration: const InputDecoration(
                  labelText: 'Langkah Langkah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tolong masukkan langkah langkah';
                  }
                  return null;
                },
                maxLines: 3,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (_stepControllers.length > 1) {
                  setState(() {
                    _stepControllers.removeAt(index);
                  });
                }
              },
            ),
          ],
        ),
      );
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipeBox = Hive.box<Recipe>('recipes');
      
      // Collect ingredients and steps
      final ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final steps = _stepControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      if (_isEditing) {
        // Update existing recipe
        widget.recipe!.title = _titleController.text;
        widget.recipe!.ingredients = ingredients;
        widget.recipe!.steps = steps;
        widget.recipe!.save();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui')),
        );
      } else {
        // Create new recipe
        final newRecipe = Recipe(
          id: 'recipe_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
          title: _titleController.text,
          ingredients: ingredients,
          steps: steps,
        );
        
        recipeBox.add(newRecipe);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil disimpan')),
        );
      }
      
      Navigator.pop(context);
    }
  }
}
