import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exercise_card.dart';
import '../models/exercise_category.dart';
import '../models/carousel_image.dart';
import '../models/relaxation_activity.dart';
import '../services/data_service.dart';

class AppDataProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  // Stream Subscriptions
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _exercisesSubscription;
  StreamSubscription? _carouselSubscription;
  StreamSubscription? _relaxationSubscription;

  // Private lists
  List<ExerciseCategory> _categories = [];
  List<ExerciseCard> _exerciseCards = [];
  List<CarouselImage> _carouselImages = [];
  List<RelaxationActivity> _relaxationActivities = [];

  // Getters
  List<ExerciseCategory> get categories => _categories;
  List<ExerciseCard> get exerciseCards => _exerciseCards;
  List<CarouselImage> get carouselImages => _carouselImages;
  List<RelaxationActivity> get relaxationActivities => _relaxationActivities;

  // Initialize data
  AppDataProvider() {
    loadData();
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _exercisesSubscription?.cancel();
    _carouselSubscription?.cancel();
    _relaxationSubscription?.cancel();
    super.dispose();
  }

  // Load all data from DataService (Listen to Streams)
  void loadData() {
    // Categories
    _categoriesSubscription = _dataService.getExerciseCategories().listen((data) {
      _categories = data;
      notifyListeners();
    });

    // Exercise Cards
    _exercisesSubscription = _dataService.getExerciseCards().listen((data) {
      _exerciseCards = data;
      notifyListeners();
    });

    // Carousel Images
    _carouselSubscription = _dataService.getCarouselImages().listen((data) {
      _carouselImages = data;
      notifyListeners();
    });

    // Relaxation Activities
    _relaxationSubscription = _dataService.getRelaxationActivities().listen((data) {
      _relaxationActivities = data;
      notifyListeners();
    });
  }

  // ========== EXERCISE CATEGORIES ==========
  Future<void> addCategory(ExerciseCategory category) async {
    await _dataService.addCategory(category);
  }

  Future<void> updateCategory(ExerciseCategory category) async {
    await _dataService.updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await _dataService.deleteCategory(id);
  }

  ExerciseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== EXERCISE CARDS ==========
  List<ExerciseCard> getCardsByCategory(String categoryId) {
    return _exerciseCards
        .where((card) => card.categoryId == categoryId)
        .toList();
  }

  Future<void> addExerciseCard(ExerciseCard card) async {
    await _dataService.addExerciseCard(card);
  }

  Future<void> updateExerciseCard(ExerciseCard card) async {
    await _dataService.updateExerciseCard(card);
  }

  Future<void> deleteExerciseCard(String id) async {
    await _dataService.deleteExerciseCard(id);
  }

  ExerciseCard? getExerciseCardById(String id) {
    try {
      return _exerciseCards.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== CAROUSEL IMAGES ==========
  List<CarouselImage> getActiveCarouselImages() {
    return _carouselImages.where((img) => img.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> addCarouselImage(CarouselImage image) async {
    await _dataService.addCarouselImage(image);
  }

  Future<void> updateCarouselImage(CarouselImage image) async {
    await _dataService.updateCarouselImage(image);
  }

  Future<void> deleteCarouselImage(String id) async {
    await _dataService.deleteCarouselImage(id);
  }

  // ========== RELAXATION ACTIVITIES ==========
  Future<void> addRelaxationActivity(RelaxationActivity activity) async {
    await _dataService.addRelaxationActivity(activity);
  }

  Future<void> updateRelaxationActivity(RelaxationActivity activity) async {
    await _dataService.updateRelaxationActivity(activity);
  }

  Future<void> deleteRelaxationActivity(String id) async {
    await _dataService.deleteRelaxationActivity(id);
  }

  RelaxationActivity? getRelaxationById(String id) {
    try {
      return _relaxationActivities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== SEED DATA ==========
  Future<void> seedData() async {
    // 1. Categories
    for (var cat in DataService.listCategories) {
      await _dataService.addCategory(cat);
    }
    // 2. Exercise Cards
    for (var card in DataService.listExerciseCards) {
      await _dataService.addExerciseCard(card);
    }
    // 3. Carousel Images
    for (var img in DataService.listCarouselImages) {
      await _dataService.addCarouselImage(img);
    }
    // 4. Relaxation Activities
    for (var relax in DataService.listRelaxationActivities) {
      await _dataService.addRelaxationActivity(relax);
    }
  }
}
