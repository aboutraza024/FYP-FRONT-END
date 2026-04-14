// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedChapterCollection on Isar {
  IsarCollection<CachedChapter> get cachedChapters => this.collection();
}

const CachedChapterSchema = CollectionSchema(
  name: r'CachedChapter',
  id: 7299639218604213524,
  properties: {
    r'bookSlug': PropertySchema(
      id: 0,
      name: r'bookSlug',
      type: IsarType.string,
    ),
    r'chapterArabic': PropertySchema(
      id: 1,
      name: r'chapterArabic',
      type: IsarType.string,
    ),
    r'chapterEnglish': PropertySchema(
      id: 2,
      name: r'chapterEnglish',
      type: IsarType.string,
    ),
    r'chapterNumber': PropertySchema(
      id: 3,
      name: r'chapterNumber',
      type: IsarType.string,
    ),
    r'chapterUrdu': PropertySchema(
      id: 4,
      name: r'chapterUrdu',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedChapterEstimateSize,
  serialize: _cachedChapterSerialize,
  deserialize: _cachedChapterDeserialize,
  deserializeProp: _cachedChapterDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookSlug': IndexSchema(
      id: 6796855514943900476,
      name: r'bookSlug',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookSlug',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedChapterGetId,
  getLinks: _cachedChapterGetLinks,
  attach: _cachedChapterAttach,
  version: '3.1.0+1',
);

int _cachedChapterEstimateSize(
  CachedChapter object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookSlug.length * 3;
  {
    final value = object.chapterArabic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.chapterEnglish;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.chapterNumber.length * 3;
  {
    final value = object.chapterUrdu;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cachedChapterSerialize(
  CachedChapter object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookSlug);
  writer.writeString(offsets[1], object.chapterArabic);
  writer.writeString(offsets[2], object.chapterEnglish);
  writer.writeString(offsets[3], object.chapterNumber);
  writer.writeString(offsets[4], object.chapterUrdu);
}

CachedChapter _cachedChapterDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedChapter();
  object.bookSlug = reader.readString(offsets[0]);
  object.chapterArabic = reader.readStringOrNull(offsets[1]);
  object.chapterEnglish = reader.readStringOrNull(offsets[2]);
  object.chapterNumber = reader.readString(offsets[3]);
  object.chapterUrdu = reader.readStringOrNull(offsets[4]);
  object.id = id;
  return object;
}

P _cachedChapterDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedChapterGetId(CachedChapter object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedChapterGetLinks(CachedChapter object) {
  return [];
}

void _cachedChapterAttach(
    IsarCollection<dynamic> col, Id id, CachedChapter object) {
  object.id = id;
}

extension CachedChapterQueryWhereSort
    on QueryBuilder<CachedChapter, CachedChapter, QWhere> {
  QueryBuilder<CachedChapter, CachedChapter, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedChapterQueryWhere
    on QueryBuilder<CachedChapter, CachedChapter, QWhereClause> {
  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause> bookSlugEqualTo(
      String bookSlug) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookSlug',
        value: [bookSlug],
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterWhereClause>
      bookSlugNotEqualTo(String bookSlug) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug',
              lower: [],
              upper: [bookSlug],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug',
              lower: [bookSlug],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug',
              lower: [bookSlug],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug',
              lower: [],
              upper: [bookSlug],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedChapterQueryFilter
    on QueryBuilder<CachedChapter, CachedChapter, QFilterCondition> {
  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookSlug',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookSlug',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      bookSlugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterArabic',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterArabic',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterArabic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterArabic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterArabicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterEnglish',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterEnglish',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterEnglish',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterEnglish',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterEnglishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterUrdu',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterUrdu',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterUrdu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterUrdu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterUrdu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterUrdu',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      chapterUrduIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterUrdu',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedChapterQueryObject
    on QueryBuilder<CachedChapter, CachedChapter, QFilterCondition> {}

extension CachedChapterQueryLinks
    on QueryBuilder<CachedChapter, CachedChapter, QFilterCondition> {}

extension CachedChapterQuerySortBy
    on QueryBuilder<CachedChapter, CachedChapter, QSortBy> {
  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> sortByBookSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByBookSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterArabic', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterArabic', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterEnglish', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterEnglish', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> sortByChapterUrdu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterUrdu', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      sortByChapterUrduDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterUrdu', Sort.desc);
    });
  }
}

extension CachedChapterQuerySortThenBy
    on QueryBuilder<CachedChapter, CachedChapter, QSortThenBy> {
  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> thenByBookSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByBookSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterArabic', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterArabic', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterEnglish', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterEnglish', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> thenByChapterUrdu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterUrdu', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy>
      thenByChapterUrduDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterUrdu', Sort.desc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension CachedChapterQueryWhereDistinct
    on QueryBuilder<CachedChapter, CachedChapter, QDistinct> {
  QueryBuilder<CachedChapter, CachedChapter, QDistinct> distinctByBookSlug(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookSlug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QDistinct> distinctByChapterArabic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterArabic',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QDistinct>
      distinctByChapterEnglish({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterEnglish',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QDistinct> distinctByChapterNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedChapter, CachedChapter, QDistinct> distinctByChapterUrdu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterUrdu', caseSensitive: caseSensitive);
    });
  }
}

extension CachedChapterQueryProperty
    on QueryBuilder<CachedChapter, CachedChapter, QQueryProperty> {
  QueryBuilder<CachedChapter, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedChapter, String, QQueryOperations> bookSlugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookSlug');
    });
  }

  QueryBuilder<CachedChapter, String?, QQueryOperations>
      chapterArabicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterArabic');
    });
  }

  QueryBuilder<CachedChapter, String?, QQueryOperations>
      chapterEnglishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterEnglish');
    });
  }

  QueryBuilder<CachedChapter, String, QQueryOperations>
      chapterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterNumber');
    });
  }

  QueryBuilder<CachedChapter, String?, QQueryOperations> chapterUrduProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterUrdu');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedHadithCollection on Isar {
  IsarCollection<CachedHadith> get cachedHadiths => this.collection();
}

const CachedHadithSchema = CollectionSchema(
  name: r'CachedHadith',
  id: -7031288902114701267,
  properties: {
    r'arabicText': PropertySchema(
      id: 0,
      name: r'arabicText',
      type: IsarType.string,
    ),
    r'bookSlug': PropertySchema(
      id: 1,
      name: r'bookSlug',
      type: IsarType.string,
    ),
    r'chapterNumber': PropertySchema(
      id: 2,
      name: r'chapterNumber',
      type: IsarType.string,
    ),
    r'englishText': PropertySchema(
      id: 3,
      name: r'englishText',
      type: IsarType.string,
    ),
    r'hadithNumber': PropertySchema(
      id: 4,
      name: r'hadithNumber',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'urduText': PropertySchema(
      id: 6,
      name: r'urduText',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedHadithEstimateSize,
  serialize: _cachedHadithSerialize,
  deserialize: _cachedHadithDeserialize,
  deserializeProp: _cachedHadithDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookSlug_chapterNumber': IndexSchema(
      id: -4083237570836593443,
      name: r'bookSlug_chapterNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookSlug',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'chapterNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedHadithGetId,
  getLinks: _cachedHadithGetLinks,
  attach: _cachedHadithAttach,
  version: '3.1.0+1',
);

int _cachedHadithEstimateSize(
  CachedHadith object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.arabicText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.bookSlug.length * 3;
  bytesCount += 3 + object.chapterNumber.length * 3;
  {
    final value = object.englishText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hadithNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.urduText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cachedHadithSerialize(
  CachedHadith object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.arabicText);
  writer.writeString(offsets[1], object.bookSlug);
  writer.writeString(offsets[2], object.chapterNumber);
  writer.writeString(offsets[3], object.englishText);
  writer.writeString(offsets[4], object.hadithNumber);
  writer.writeString(offsets[5], object.status);
  writer.writeString(offsets[6], object.urduText);
}

CachedHadith _cachedHadithDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedHadith();
  object.arabicText = reader.readStringOrNull(offsets[0]);
  object.bookSlug = reader.readString(offsets[1]);
  object.chapterNumber = reader.readString(offsets[2]);
  object.englishText = reader.readStringOrNull(offsets[3]);
  object.hadithNumber = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.status = reader.readStringOrNull(offsets[5]);
  object.urduText = reader.readStringOrNull(offsets[6]);
  return object;
}

P _cachedHadithDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedHadithGetId(CachedHadith object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedHadithGetLinks(CachedHadith object) {
  return [];
}

void _cachedHadithAttach(
    IsarCollection<dynamic> col, Id id, CachedHadith object) {
  object.id = id;
}

extension CachedHadithQueryWhereSort
    on QueryBuilder<CachedHadith, CachedHadith, QWhere> {
  QueryBuilder<CachedHadith, CachedHadith, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedHadithQueryWhere
    on QueryBuilder<CachedHadith, CachedHadith, QWhereClause> {
  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause>
      bookSlugEqualToAnyChapterNumber(String bookSlug) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookSlug_chapterNumber',
        value: [bookSlug],
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause>
      bookSlugNotEqualToAnyChapterNumber(String bookSlug) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [],
              upper: [bookSlug],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [],
              upper: [bookSlug],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause>
      bookSlugChapterNumberEqualTo(String bookSlug, String chapterNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookSlug_chapterNumber',
        value: [bookSlug, chapterNumber],
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterWhereClause>
      bookSlugEqualToChapterNumberNotEqualTo(
          String bookSlug, String chapterNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug],
              upper: [bookSlug, chapterNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug, chapterNumber],
              includeLower: false,
              upper: [bookSlug],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug, chapterNumber],
              includeLower: false,
              upper: [bookSlug],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookSlug_chapterNumber',
              lower: [bookSlug],
              upper: [bookSlug, chapterNumber],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedHadithQueryFilter
    on QueryBuilder<CachedHadith, CachedHadith, QFilterCondition> {
  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'arabicText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'arabicText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'arabicText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'arabicText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arabicText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      arabicTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'arabicText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookSlug',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookSlug',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      bookSlugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      chapterNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'englishText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'englishText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'englishText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'englishText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      englishTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hadithNumber',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hadithNumber',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hadithNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hadithNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hadithNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hadithNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      hadithNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hadithNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'urduText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'urduText',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urduText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urduText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urduText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterFilterCondition>
      urduTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urduText',
        value: '',
      ));
    });
  }
}

extension CachedHadithQueryObject
    on QueryBuilder<CachedHadith, CachedHadith, QFilterCondition> {}

extension CachedHadithQueryLinks
    on QueryBuilder<CachedHadith, CachedHadith, QFilterCondition> {}

extension CachedHadithQuerySortBy
    on QueryBuilder<CachedHadith, CachedHadith, QSortBy> {
  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByArabicText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      sortByArabicTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByBookSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByBookSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      sortByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      sortByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByHadithNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hadithNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      sortByHadithNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hadithNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByUrduText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> sortByUrduTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.desc);
    });
  }
}

extension CachedHadithQuerySortThenBy
    on QueryBuilder<CachedHadith, CachedHadith, QSortThenBy> {
  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByArabicText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      thenByArabicTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByBookSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByBookSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookSlug', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      thenByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      thenByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByHadithNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hadithNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy>
      thenByHadithNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hadithNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByUrduText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.asc);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QAfterSortBy> thenByUrduTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.desc);
    });
  }
}

extension CachedHadithQueryWhereDistinct
    on QueryBuilder<CachedHadith, CachedHadith, QDistinct> {
  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByArabicText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arabicText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByBookSlug(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookSlug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByChapterNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByEnglishText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'englishText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByHadithNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hadithNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedHadith, CachedHadith, QDistinct> distinctByUrduText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urduText', caseSensitive: caseSensitive);
    });
  }
}

extension CachedHadithQueryProperty
    on QueryBuilder<CachedHadith, CachedHadith, QQueryProperty> {
  QueryBuilder<CachedHadith, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedHadith, String?, QQueryOperations> arabicTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arabicText');
    });
  }

  QueryBuilder<CachedHadith, String, QQueryOperations> bookSlugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookSlug');
    });
  }

  QueryBuilder<CachedHadith, String, QQueryOperations> chapterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterNumber');
    });
  }

  QueryBuilder<CachedHadith, String?, QQueryOperations> englishTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'englishText');
    });
  }

  QueryBuilder<CachedHadith, String?, QQueryOperations> hadithNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hadithNumber');
    });
  }

  QueryBuilder<CachedHadith, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CachedHadith, String?, QQueryOperations> urduTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urduText');
    });
  }
}
