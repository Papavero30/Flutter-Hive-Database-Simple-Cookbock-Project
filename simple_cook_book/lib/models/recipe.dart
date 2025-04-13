import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late List<String> ingredients;

  @HiveField(3)
  late List<String> steps;
  
  @HiveField(4)
  String? imagePath;
  
  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.imagePath,
  });
}
