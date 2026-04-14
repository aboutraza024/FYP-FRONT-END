// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedAyahCollection on Isar {
  IsarCollection<CachedAyah> get cachedAyahs => this.collection();
}

const CachedAyahSchema = CollectionSchema(
  name: r'CachedAyah',
  id: 8272485337435606045,
  properties: {
    r'arabicText': PropertySchema(
      id: 0,
      name: r'arabicText',
      type: IsarType.string,
    ),
    r'ayahNumber': PropertySchema(
      id: 1,
      name: r'ayahNumber',
      type: IsarType.long,
    ),
    r'englishText': PropertySchema(
      id: 2,
      name: r'englishText',
      type: IsarType.string,
    ),
    r'juzNumber': PropertySchema(
      id: 3,
      name: r'juzNumber',
      type: IsarType.long,
    ),
    r'numberInSurah': PropertySchema(
      id: 4,
      name: r'numberInSurah',
      type: IsarType.long,
    ),
    r'pageNumber': PropertySchema(
      id: 5,
      name: r'pageNumber',
      type: IsarType.long,
    ),
    r'surahNumber': PropertySchema(
      id: 6,
      name: r'surahNumber',
      type: IsarType.long,
    ),
    r'urduText': PropertySchema(
      id: 7,
      name: r'urduText',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedAyahEstimateSize,
  serialize: _cachedAyahSerialize,
  deserialize: _cachedAyahDeserialize,
  deserializeProp: _cachedAyahDeserializeProp,
  idName: r'id',
  indexes: {
    r'surahNumber': IndexSchema(
      id: 9024003441292455669,
      name: r'surahNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'surahNumber',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'ayahNumber': IndexSchema(
      id: -8135434729161833584,
      name: r'ayahNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ayahNumber',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'pageNumber': IndexSchema(
      id: -702571354938573130,
      name: r'pageNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pageNumber',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedAyahGetId,
  getLinks: _cachedAyahGetLinks,
  attach: _cachedAyahAttach,
  version: '3.1.0+1',
);

int _cachedAyahEstimateSize(
  CachedAyah object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.arabicText.length * 3;
  bytesCount += 3 + object.englishText.length * 3;
  bytesCount += 3 + object.urduText.length * 3;
  return bytesCount;
}

void _cachedAyahSerialize(
  CachedAyah object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.arabicText);
  writer.writeLong(offsets[1], object.ayahNumber);
  writer.writeString(offsets[2], object.englishText);
  writer.writeLong(offsets[3], object.juzNumber);
  writer.writeLong(offsets[4], object.numberInSurah);
  writer.writeLong(offsets[5], object.pageNumber);
  writer.writeLong(offsets[6], object.surahNumber);
  writer.writeString(offsets[7], object.urduText);
}

CachedAyah _cachedAyahDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedAyah();
  object.arabicText = reader.readString(offsets[0]);
  object.ayahNumber = reader.readLong(offsets[1]);
  object.englishText = reader.readString(offsets[2]);
  object.id = id;
  object.juzNumber = reader.readLong(offsets[3]);
  object.numberInSurah = reader.readLong(offsets[4]);
  object.pageNumber = reader.readLong(offsets[5]);
  object.surahNumber = reader.readLong(offsets[6]);
  object.urduText = reader.readString(offsets[7]);
  return object;
}

P _cachedAyahDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedAyahGetId(CachedAyah object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedAyahGetLinks(CachedAyah object) {
  return [];
}

void _cachedAyahAttach(IsarCollection<dynamic> col, Id id, CachedAyah object) {
  object.id = id;
}

extension CachedAyahQueryWhereSort
    on QueryBuilder<CachedAyah, CachedAyah, QWhere> {
  QueryBuilder<CachedAyah, CachedAyah, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhere> anySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'surahNumber'),
      );
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhere> anyAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ayahNumber'),
      );
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhere> anyPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pageNumber'),
      );
    });
  }
}

extension CachedAyahQueryWhere
    on QueryBuilder<CachedAyah, CachedAyah, QWhereClause> {
  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> idBetween(
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> surahNumberEqualTo(
      int surahNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'surahNumber',
        value: [surahNumber],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> surahNumberNotEqualTo(
      int surahNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahNumber',
              lower: [],
              upper: [surahNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahNumber',
              lower: [surahNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahNumber',
              lower: [surahNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahNumber',
              lower: [],
              upper: [surahNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause>
      surahNumberGreaterThan(
    int surahNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahNumber',
        lower: [surahNumber],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> surahNumberLessThan(
    int surahNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahNumber',
        lower: [],
        upper: [surahNumber],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> surahNumberBetween(
    int lowerSurahNumber,
    int upperSurahNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahNumber',
        lower: [lowerSurahNumber],
        includeLower: includeLower,
        upper: [upperSurahNumber],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> ayahNumberEqualTo(
      int ayahNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ayahNumber',
        value: [ayahNumber],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> ayahNumberNotEqualTo(
      int ayahNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ayahNumber',
              lower: [],
              upper: [ayahNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ayahNumber',
              lower: [ayahNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ayahNumber',
              lower: [ayahNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ayahNumber',
              lower: [],
              upper: [ayahNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> ayahNumberGreaterThan(
    int ayahNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ayahNumber',
        lower: [ayahNumber],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> ayahNumberLessThan(
    int ayahNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ayahNumber',
        lower: [],
        upper: [ayahNumber],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> ayahNumberBetween(
    int lowerAyahNumber,
    int upperAyahNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ayahNumber',
        lower: [lowerAyahNumber],
        includeLower: includeLower,
        upper: [upperAyahNumber],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> pageNumberEqualTo(
      int pageNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pageNumber',
        value: [pageNumber],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> pageNumberNotEqualTo(
      int pageNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageNumber',
              lower: [],
              upper: [pageNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageNumber',
              lower: [pageNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageNumber',
              lower: [pageNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageNumber',
              lower: [],
              upper: [pageNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> pageNumberGreaterThan(
    int pageNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pageNumber',
        lower: [pageNumber],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> pageNumberLessThan(
    int pageNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pageNumber',
        lower: [],
        upper: [pageNumber],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterWhereClause> pageNumberBetween(
    int lowerPageNumber,
    int upperPageNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pageNumber',
        lower: [lowerPageNumber],
        includeLower: includeLower,
        upper: [upperPageNumber],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedAyahQueryFilter
    on QueryBuilder<CachedAyah, CachedAyah, QFilterCondition> {
  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> arabicTextEqualTo(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      arabicTextGreaterThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      arabicTextLessThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> arabicTextBetween(
    String lower,
    String upper, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      arabicTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'arabicText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> arabicTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'arabicText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      arabicTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arabicText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      arabicTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'arabicText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> ayahNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      ayahNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      ayahNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> ayahNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayahNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextEqualTo(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextGreaterThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextLessThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextBetween(
    String lower,
    String upper, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'englishText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      englishTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> juzNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'juzNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      juzNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'juzNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> juzNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'juzNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> juzNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'juzNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      numberInSurahEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numberInSurah',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      numberInSurahGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numberInSurah',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      numberInSurahLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numberInSurah',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      numberInSurahBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numberInSurah',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> pageNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      pageNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      pageNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> pageNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      surahNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      surahNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      surahNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      surahNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surahNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextEqualTo(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      urduTextGreaterThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextLessThan(
    String value, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextBetween(
    String lower,
    String upper, {
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextEndsWith(
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

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urduText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition> urduTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urduText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      urduTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urduText',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterFilterCondition>
      urduTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urduText',
        value: '',
      ));
    });
  }
}

extension CachedAyahQueryObject
    on QueryBuilder<CachedAyah, CachedAyah, QFilterCondition> {}

extension CachedAyahQueryLinks
    on QueryBuilder<CachedAyah, CachedAyah, QFilterCondition> {}

extension CachedAyahQuerySortBy
    on QueryBuilder<CachedAyah, CachedAyah, QSortBy> {
  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByArabicText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByArabicTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByAyahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByJuzNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'juzNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByJuzNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'juzNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByNumberInSurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberInSurah', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByNumberInSurahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberInSurah', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByUrduText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> sortByUrduTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.desc);
    });
  }
}

extension CachedAyahQuerySortThenBy
    on QueryBuilder<CachedAyah, CachedAyah, QSortThenBy> {
  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByArabicText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByArabicTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arabicText', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByAyahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByJuzNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'juzNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByJuzNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'juzNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByNumberInSurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberInSurah', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByNumberInSurahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberInSurah', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByUrduText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.asc);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QAfterSortBy> thenByUrduTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urduText', Sort.desc);
    });
  }
}

extension CachedAyahQueryWhereDistinct
    on QueryBuilder<CachedAyah, CachedAyah, QDistinct> {
  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByArabicText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arabicText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayahNumber');
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByEnglishText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'englishText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByJuzNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'juzNumber');
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByNumberInSurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberInSurah');
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageNumber');
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surahNumber');
    });
  }

  QueryBuilder<CachedAyah, CachedAyah, QDistinct> distinctByUrduText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urduText', caseSensitive: caseSensitive);
    });
  }
}

extension CachedAyahQueryProperty
    on QueryBuilder<CachedAyah, CachedAyah, QQueryProperty> {
  QueryBuilder<CachedAyah, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedAyah, String, QQueryOperations> arabicTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arabicText');
    });
  }

  QueryBuilder<CachedAyah, int, QQueryOperations> ayahNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayahNumber');
    });
  }

  QueryBuilder<CachedAyah, String, QQueryOperations> englishTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'englishText');
    });
  }

  QueryBuilder<CachedAyah, int, QQueryOperations> juzNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'juzNumber');
    });
  }

  QueryBuilder<CachedAyah, int, QQueryOperations> numberInSurahProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberInSurah');
    });
  }

  QueryBuilder<CachedAyah, int, QQueryOperations> pageNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageNumber');
    });
  }

  QueryBuilder<CachedAyah, int, QQueryOperations> surahNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surahNumber');
    });
  }

  QueryBuilder<CachedAyah, String, QQueryOperations> urduTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urduText');
    });
  }
}
