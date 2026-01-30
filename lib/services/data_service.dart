import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_card.dart';
import '../models/exercise_category.dart';
import '../models/carousel_image.dart';
import '../models/relaxation_activity.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _categoriesRef => _firestore.collection('categories');
  CollectionReference get _exercisesRef => _firestore.collection('exercises');
  CollectionReference get _carouselRef =>
      _firestore.collection('carousel_images');
  CollectionReference get _relaxationRef =>
      _firestore.collection('relaxation_activities');

  // ==================== STREAM GETTERS ====================

  /// Get exercise categories ordered by 'order'
  Stream<List<ExerciseCategory>> getExerciseCategories() {
    return _categoriesRef.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExerciseCategory.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get all exercise cards
  Stream<List<ExerciseCard>> getExerciseCards() {
    return _exercisesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExerciseCard.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get carousel images ordered by 'order'
  Stream<List<CarouselImage>> getCarouselImages() {
    return _carouselRef.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CarouselImage.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get relaxation activities ordered by 'order'
  Stream<List<RelaxationActivity>> getRelaxationActivities() {
    return _relaxationRef.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RelaxationActivity.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // ==================== CRUD OPERATIONS ====================

  // --- Categories ---
  Future<void> addCategory(ExerciseCategory category) {
    return _categoriesRef.doc(category.id).set(category.toJson());
  }

  Future<void> updateCategory(ExerciseCategory category) {
    return _categoriesRef.doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    // Also delete associated exercises? Ideally yes, but keeping it simple for now.
    await _categoriesRef.doc(id).delete();
  }

  // --- Exercise Cards ---
  Future<void> addExerciseCard(ExerciseCard card) {
    return _exercisesRef.doc(card.id).set(card.toJson());
  }

  Future<void> updateExerciseCard(ExerciseCard card) {
    return _exercisesRef.doc(card.id).update(card.toJson());
  }

  Future<void> deleteExerciseCard(String id) {
    return _exercisesRef.doc(id).delete();
  }

  // --- Carousel Images ---
  Future<void> addCarouselImage(CarouselImage image) {
    return _carouselRef.doc(image.id).set(image.toJson());
  }

  Future<void> updateCarouselImage(CarouselImage image) {
    return _carouselRef.doc(image.id).update(image.toJson());
  }

  Future<void> deleteCarouselImage(String id) {
    return _carouselRef.doc(id).delete();
  }

  // --- Relaxation Activities ---
  Future<void> addRelaxationActivity(RelaxationActivity activity) {
    return _relaxationRef.doc(activity.id).set(activity.toJson());
  }

  Future<void> updateRelaxationActivity(RelaxationActivity activity) {
    return _relaxationRef.doc(activity.id).update(activity.toJson());
  }

  Future<void> deleteRelaxationActivity(String id) {
    return _relaxationRef.doc(id).delete();
  }

  // ==================== INITIAL DATA (For Seeding) ====================
  // Keeping this here so we can upload it to Firestore once

  static final listCategories = [
    ExerciseCategory(
      id: "tanon",
      name: "ท่านอน",
      nameEn: "Lying Down",
      description: "บริหารร่างกายในท่านอน เหมาะสำหรับผู้เริ่มต้น",
      icon: "assets/icons/lying.png",
      order: 1,
    ),
    ExerciseCategory(
      id: "tanang",
      name: "ท่านั่ง",
      nameEn: "Sitting",
      description: "บริหารร่างกายบนเก้าอี้ ปลอดภัยและทำได้ทุกที่",
      icon: "assets/icons/sitting.png",
      order: 2,
    ),
    ExerciseCategory(
      id: "tayorn",
      name: "ท่ายืน",
      nameEn: "Standing",
      description: "บริหารร่างกายในท่ายืน เพิ่มการทรงตัวและความแข็งแรง",
      icon: "assets/icons/standing.png",
      order: 3,
    ),
  ];

  static final listExerciseCards = [
    // --- ท่านอน (Lying) ---
    ExerciseCard(
      id: "card_lying_1",
      title: "ท่านอนหงายชันเข่า",
      subtitle: "บริหารกล้ามเนื้อท้องและสะโพก",
      categoryId: "tanon",
      thumbnailPath: "assets/images/lying_1.png",
      youtubeId: "dvhNOKRrOjk",
    ),
    ExerciseCard(
      id: "card_lying_2",
      title: "ท่านอนตะแคงยกขา",
      subtitle: "บริหารสะโพกด้านข้าง",
      categoryId: "tanon",
      thumbnailPath: "assets/images/lying_2.png",
      youtubeId: "example_id",
    ),

    // --- ท่านั่ง (Sitting) ---
    ExerciseCard(
      id: "card_sitting_1",
      title: "ท่านั่งยกเข่า",
      subtitle: "บริหารต้นขาด้านหน้า",
      categoryId: "tanang",
      thumbnailPath: "assets/images/sitting_1.png",
      youtubeId: "example_id_2",
    ),
    ExerciseCard(
      id: "card_sitting_2",
      title: "ท่านั่งเหยียดขา",
      subtitle: "ยืดกล้ามเนื้อขาด้านหลัง",
      categoryId: "tanang",
      thumbnailPath: "assets/images/sitting_2.png",
      youtubeId: "example_id_3",
    ),

    // --- ท่ายืน (Standing) ---
    ExerciseCard(
      id: "card_standing_1",
      title: "ท่ายืนเขย่งปลายเท้า",
      subtitle: "บริหารน่องและการทรงตัว",
      categoryId: "tayorn",
      thumbnailPath: "assets/images/standing_1.png",
      youtubeId: "example_id_4",
    ),
    ExerciseCard(
      id: "card_standing_2",
      title: "ท่ายืนย่อเข่า",
      subtitle: "บริหารต้นขาและสะโพก",
      categoryId: "tayorn",
      thumbnailPath: "assets/images/standing_2.png",
      youtubeId: "example_id_5",
    ),
    // --- Relaxation : Aches (ปวดเมื่อย) ---
    ExerciseCard(
      id: "card_aches_1",
      title: "กระชับหุ่น ลดปวดเมื่อย เพิ่มความทนทาน-แข็งแรง",
      subtitle: "หมอชวนฟิต [DeDoctor]",
      categoryId: "aches",
      youtubeId: "01mWzG7_zs8",
    ),
    ExerciseCard(
      id: "card_aches_2",
      title: "อยากแข็งแรง ไม่ปวด ไม่เมื่อย ต้องฝึกยืดกล้ามเนื้อ",
      subtitle: "หมอชวนฟิต [DeDoctor]",
      categoryId: "aches",
      youtubeId: "3vOTTj_X3kQ",
    ),
    ExerciseCard(
      id: "card_aches_3",
      title: "สูตรลัด ยืดเหยียดกล้ามเนื้อ ง่ายและเร็วสุดๆ",
      subtitle: "หมอชวนฟิต [DeDoctor]",
      categoryId: "aches",
      youtubeId: "U95pRrASFJU",
    ),
    ExerciseCard(
      id: "card_aches_4",
      title: "ครบทุกท่า แก้ปวดตึงกล้ามเนื้อ คอ บ่า ไหล่",
      subtitle: "หมอชวนฟิต [DeDoctor]",
      categoryId: "aches",
      youtubeId: "7KAMEVgkkRM",
    ),
    ExerciseCard(
      id: "card_aches_5",
      title: "ท่าบริหารแก้หลังเสื่อม หลังเคลื่อน ทำบนเตียง",
      subtitle: "หมอชวนฟิต [DeDoctor]",
      categoryId: "aches",
      youtubeId: "XGzFkRyQx_Y",
    ),

    // --- Relaxation : Tai Chi (รำไทชิ) ---
    ExerciseCard(
      id: "card_taichi_1",
      title: "ไทชิชี่กง 18 ท่า ชุดที่ 1",
      subtitle: "Tai Chi by Guru Mon",
      categoryId: "taichi",
      youtubeId: "vyOrQTt4b_U",
    ),
    ExerciseCard(
      id: "card_taichi_2",
      title: "30mins Gentle Tai Chi Exercise for Seniors",
      subtitle: "Taichi Workout",
      categoryId: "taichi",
      youtubeId: "MxAfZ_N_HH4",
    ),
    ExerciseCard(
      id: "card_taichi_3",
      title: "ไทชิชี่กง 18 ท่า ชุดที่ 2",
      subtitle: "Tai Chi by Guru Mon",
      categoryId: "taichi",
      youtubeId: "_L-TwxTws4A",
    ),

    // --- Relaxation : Yoga (โยคะ) ---
    ExerciseCard(
      id: "card_yoga_1",
      title: "โยคะผู้สูงวัย ดูแลร่างกายให้อ่อนเยาว์",
      subtitle: "Pordipor Yoga",
      categoryId: "yoga",
      youtubeId: "NKWvA-dSR_0",
    ),
    ExerciseCard(
      id: "card_yoga_2",
      title: "15ท่า ยืดเหยียดสำหรับผู้สูงอายุ",
      subtitle: "WELLNESS WE CARE",
      categoryId: "yoga",
      youtubeId: "BX8mpK6RpYo",
    ),
    ExerciseCard(
      id: "card_yoga_3",
      title: "ท่าโยคะเพิ่มความแข็งแรงแกนกลางลำตัว",
      subtitle: "Thai PBS",
      categoryId: "yoga",
      youtubeId: "nI57iYcIQJU",
    ),
    ExerciseCard(
      id: "card_yoga_4",
      title: "25 นาที | โยคะกับเก้าอี้เบาๆ บำบัดอาการปวดเข่า",
      subtitle: "SookSabai Yoga",
      categoryId: "yoga",
      youtubeId: "AiJGaZ-9ee0",
    ),

    // --- Relaxation : Stretching (ยืดเหยียด) ---
    ExerciseCard(
      id: "card_stretching_1",
      title: "ฝึกยืดเหยียด เบื้องต้นสำหรับผู้สูงอายุ",
      subtitle: "Thai PBS",
      categoryId: "stretching",
      youtubeId: "z1gS-f3_z_Y",
    ),
    ExerciseCard(
      id: "card_stretching_2",
      title: "ยืดเหยียด ผ่อนคลายร่างกายและจิตใจ",
      subtitle: "Good Life",
      categoryId: "stretching",
      youtubeId: "z1gS-f3_z_Y",
    ),
    ExerciseCard(
      id: "card_stretching_3",
      title: "ประโยชน์ของ ยืดเหยียด ต่อผู้สูงวัย",
      subtitle: "Health Article",
      categoryId: "stretching",
      youtubeId: "z1gS-f3_z_Y",
    ),
  ];

  static final listCarouselImages = [
    CarouselImage(
      id: "carousel_1",
      imagePath: "assets/images/elderly_exercise_1.jpg",
      order: 1,
    ),
    CarouselImage(
      id: "carousel_2",
      imagePath: "assets/images/elderly_exercise_2.jpg",
      order: 2,
    ),
    CarouselImage(
      id: "carousel_3",
      imagePath: "assets/images/elderly_exercise_3.jpg",
      order: 3,
    ),
  ];

  static final listRelaxationActivities = [
    RelaxationActivity(
      id: "aches",
      name: "ปวดเมื่อย",
      nameEn: "Aches and Pains",
      description: "บริหารร่างกายเพื่อลดอาการปวดเมื่อย",
      icon: "assets/icons/aches.png",
      order: 1,
    ),
    RelaxationActivity(
      id: "taichi",
      name: "รำไทชิ",
      nameEn: "Tai Chi",
      description: "ศิลปะการเคลื่อนไหวเพื่อสุขภาพ",
      icon: "assets/icons/taichi.png",
      order: 1,
    ),
    RelaxationActivity(
      id: "yoga",
      name: "โยคะ",
      nameEn: "Yoga",
      description: "ฝึกสมาธิและความยืดหยุ่น",
      icon: "assets/icons/yoga.png",
      order: 2,
    ),
    RelaxationActivity(
      id: "stretching",
      name: "ยืดเหยียด",
      nameEn: "Stretching",
      description: "คลายกล้ามเนื้อหลังออกกำลังกาย",
      icon: "assets/icons/stretching.png",
      order: 3,
    ),
  ];
}
