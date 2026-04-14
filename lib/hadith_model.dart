import 'package:isar/isar.dart';

part 'hadith_model.g.dart';

@collection
class CachedChapter {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String bookSlug;
  
  late String chapterNumber;
  String? chapterEnglish;
  String? chapterUrdu;
  String? chapterArabic;
}

@collection
class CachedHadith {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('chapterNumber')])
  late String bookSlug;
  
  late String chapterNumber;
  
  String? hadithNumber;
  String? englishText;
  String? urduText;
  String? arabicText;
  String? status; // Sahih, Da'if, etc.
}