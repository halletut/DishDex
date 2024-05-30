class Dish {
  Dish(
      {required this.dishName,
      required this.ingredients,
      required this.directions,
      required this.user,
      required this.menu});

  final String dishName;
  final String user;
  final String directions;
  final bool menu;
  List<String> ingredients;

  Map<String, Object?> toMap() {
    return {
      'dishName': dishName,
      'directions': directions,
      'ingredients': ingredients,
      'user': user,
      'menu': menu,
    };
  }
}
