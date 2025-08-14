% Define the list of ingredients used in meals
ingredient(pasta).
ingredient(butter).
ingredient(sage).
ingredient(rice).
ingredient(shrimp).
ingredient(courgette).
ingredient(egg).
ingredient(pecorino).
ingredient(pork_jowl).
ingredient(beef_steak).
ingredient(breadcrumbs).
ingredient(eggplant).
ingredient(mozzarella).
ingredient(parmigiano).
ingredient(tomato_puree).
ingredient(lettuce).
ingredient(potato).
ingredient(peach).
ingredient(apricot).
ingredient(watermelon).

% Define the caloric content of each ingredient
kcal_ingredient(pasta, 180).
kcal_ingredient(butter, 220).
kcal_ingredient(sage, 0).
kcal_ingredient(rice, 160).
kcal_ingredient(shrimp, 45).
kcal_ingredient(courgette, 10).
kcal_ingredient(egg, 60).
kcal_ingredient(pecorino, 190).
kcal_ingredient(pork_jowl, 330).
kcal_ingredient(beef_steak, 120).
kcal_ingredient(breadcrumbs, 160).
kcal_ingredient(eggplant, 10).
kcal_ingredient(mozzarella, 130).
kcal_ingredient(parmigiano, 190).
kcal_ingredient(tomato_puree, 10).
kcal_ingredient(lettuce, 10).
kcal_ingredient(potato, 40).
kcal_ingredient(peach, 10).
kcal_ingredient(apricot, 10).
kcal_ingredient(watermelon, 10).

% Define which ingredients are carnivorous
ingredient_carnivore(shrimp).
ingredient_carnivore(pork_jowl).
ingredient_carnivore(beef_steak).

% Define which ingredients are vegetarian
ingredient_vegetarian(courgette).
ingredient_vegetarian(eggplant).
ingredient_vegetarian(lettuce).

% Define which ingredients cause lactose intolerance
ingredient_with_lactose_intolerance(pecorino).
ingredient_with_lactose_intolerance(mozzarella).
ingredient_with_lactose_intolerance(parmigiano).

% Define which ingredients contain gluten
ingredient_with_gluten_intolerance(pasta).
ingredient_with_gluten_intolerance(breadcrumbs).

% Define various meals with their ingredients
meal(pasta_burro_salvia, first_dish, [pasta, butter, sage]).
meal(risotto_gamberetti_zucchine, first_dish, [rice, shrimp, courgette]).
meal(carbonara, first_dish, [pasta, egg, pecorino, pork_jowl]).
meal(fiorentina, second_dish, [beef_steak]).
meal(polpette_zucchine, second_dish, [courgette, egg, breadcrumbs]).
meal(parmigiana, second_dish, [eggplant, mozzarella, parmigiano, tomato_puree]).
meal(insalata, side_dish, [lettuce]).
meal(patate_al_forno, side_dish, [potato]).
meal(macedonia, dessert, [peach, apricot, watermelon]).

% Determine if a meal is vegetarian
vegetarian_meal(Meal, Course) :-
    meal(Meal, Course, Ingredients),
    forall(member(Ingredient, Ingredients),
           (ingredient_vegetarian(Ingredient); \+ ingredient_carnivore(Ingredient))).

% Determine if a meal is carnivorous
carnivorous_meal(Meal, Course) :-
    meal(Meal, Course, Ingredients),
    % Ensure all ingredients are either carnivorous or not vegetarian
    forall(member(Ingredient, Ingredients),
           (ingredient_carnivore(Ingredient); \+ ingredient_vegetarian(Ingredient))).

% Define meals that contain both carnivorous and vegetarian ingredients
omnivore_meal(Meal, Course) :-
    meal(Meal, Course, Ingredients),
    forall(member(Ingredient, Ingredients), ingredient(Ingredient)).

% Find meals with gluten intolerance
meal_with_gluten_intolerance(Meal, Course) :-
    findall(Meal-Course,
            (meal(Meal, Course, Ingredients),
             member(Ingredient, Ingredients),
             ingredient_with_gluten_intolerance(Ingredient)),
            MealsWithGlutenIntolerance),
    list_to_set(MealsWithGlutenIntolerance, UniqueMeals),
    member(Meal-Course, UniqueMeals).

% Find meals with lactose intolerance
meal_with_lactose_intolerance(Meal, Course) :-
    findall(Meal-Course,
            (meal(Meal, Course, Ingredients),
             member(Ingredient, Ingredients),
             ingredient_with_lactose_intolerance(Ingredient)),
            MealsWithLactoseIntolerance),
    list_to_set(MealsWithLactoseIntolerance, UniqueMeals),
    member(Meal-Course, UniqueMeals).

% Calculate the total caloric content of a meal
meal_calories(Meal, Course, TotalCalories) :-
    meal(Meal, Course, Ingredients),
    findall(Calories, 
            (member(Ingredient, Ingredients), 
             kcal_ingredient(Ingredient, Kcal), 
             Calories is Kcal), 
            CaloriesList),
    sum_list(CaloriesList, TotalCalories).

% Determine calorie-conscious levels based on total calories
calorie_conscious_levels(Meal, Course, Levels) :-
    meal_calories(Meal, Course, TotalCalories),
    % Determine the highest applicable level based on total calories
    ( TotalCalories > 250 -> HighestLevel = 0;
    TotalCalories =< 250 -> HighestLevel = 1
    ),
    % Generate all levels up to the highest applicable level
    findall(Level, (between(0, HighestLevel, Level)), Levels).

% Filter meals based on guest preferences, including category, calorie level, and allergies
guest_preferences(Category, CalorieLevel, Allergies, Meal, Course) :-
    % Filtered meals by Category (carnivorous, vegetarian, omnivore)
    ( Category = carnivorous -> carnivorous_meal(Meal, Course)
    ; Category = vegetarian -> vegetarian_meal(Meal, Course)
    ; Category = omnivore -> omnivore_meal(Meal, Course)
    ),
    % Filtered meals by calorie_conscious_level
    calorie_conscious_levels(Meal, Course, Levels),
    member(CalorieLevel, Levels),
    % Filtered meals by allergies
    ( Allergies = none -> true
    ; ( Allergies = lactose -> not(meal_with_lactose_intolerance(Meal, Course))
      ; Allergies = gluten -> not(meal_with_gluten_intolerance(Meal, Course))
    )
    ).

% QUERY EXAMPLES:

% guest_preferences(omnivore, 0, none, Meal, Course).

% guest_preferences(omnivore, 0, gluten, Meal, Course).

% guest_preferences(carnivorous, 1, none, Meal, Course).

% guest_preferences(carnivorous, 0, none, Meal, Course).

% guest_preferences(carnivorous, 0, lactose, Meal, Course).

% guest_preferences(vegetarian, 1, none, Meal, Course).

% guest_preferences(vegetarian, 1, none, Meal, Course).