// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_shortage.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMerchantShortageCollection on Isar {
  IsarCollection<MerchantShortage> get merchantShortages => this.collection();
}

const MerchantShortageSchema = CollectionSchema(
  name: r'MerchantShortage',
  id: 5687390462636456960,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'firestoreId': PropertySchema(
      id: 1,
      name: r'firestoreId',
      type: IsarType.string,
    ),
    r'isResolved': PropertySchema(
      id: 2,
      name: r'isResolved',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'merchantId': PropertySchema(
      id: 4,
      name: r'merchantId',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'productName': PropertySchema(
      id: 6,
      name: r'productName',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 7,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _merchantShortageEstimateSize,
  serialize: _merchantShortageSerialize,
  deserialize: _merchantShortageDeserialize,
  deserializeProp: _merchantShortageDeserializeProp,
  idName: r'id',
  indexes: {
    r'merchantId': IndexSchema(
      id: 6127827311702803456,
      name: r'merchantId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'merchantId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isResolved': IndexSchema(
      id: 2669446589477246464,
      name: r'isResolved',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isResolved',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302400,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'firestoreId': IndexSchema(
      id: 1863077355534728960,
      name: r'firestoreId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firestoreId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _merchantShortageGetId,
  getLinks: _merchantShortageGetLinks,
  attach: _merchantShortageAttach,
  version: '3.1.0+1',
);

int _merchantShortageEstimateSize(
  MerchantShortage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.firestoreId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productName.length * 3;
  return bytesCount;
}

void _merchantShortageSerialize(
  MerchantShortage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.firestoreId);
  writer.writeBool(offsets[2], object.isResolved);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeLong(offsets[4], object.merchantId);
  writer.writeString(offsets[5], object.note);
  writer.writeString(offsets[6], object.productName);
  writer.writeDouble(offsets[7], object.quantity);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

MerchantShortage _merchantShortageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MerchantShortage(
    isResolved: reader.readBoolOrNull(offsets[2]) ?? false,
    merchantId: reader.readLongOrNull(offsets[4]),
    note: reader.readStringOrNull(offsets[5]),
    productName: reader.readString(offsets[6]),
    quantity: reader.readDoubleOrNull(offsets[7]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.firestoreId = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[3]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _merchantShortageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _merchantShortageGetId(MerchantShortage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _merchantShortageGetLinks(MerchantShortage object) {
  return [];
}

void _merchantShortageAttach(
    IsarCollection<dynamic> col, Id id, MerchantShortage object) {
  object.id = id;
}

extension MerchantShortageQueryWhereSort
    on QueryBuilder<MerchantShortage, MerchantShortage, QWhere> {
  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhere>
      anyMerchantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'merchantId'),
      );
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhere>
      anyIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isResolved'),
      );
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension MerchantShortageQueryWhere
    on QueryBuilder<MerchantShortage, MerchantShortage, QWhereClause> {
  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause> idBetween(
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

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'merchantId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'merchantId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdEqualTo(int? merchantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'merchantId',
        value: [merchantId],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdNotEqualTo(int? merchantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantId',
              lower: [],
              upper: [merchantId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantId',
              lower: [merchantId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantId',
              lower: [merchantId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantId',
              lower: [],
              upper: [merchantId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdGreaterThan(
    int? merchantId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'merchantId',
        lower: [merchantId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdLessThan(
    int? merchantId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'merchantId',
        lower: [],
        upper: [merchantId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      merchantIdBetween(
    int? lowerMerchantId,
    int? upperMerchantId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'merchantId',
        lower: [lowerMerchantId],
        includeLower: includeLower,
        upper: [upperMerchantId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      isResolvedEqualTo(bool isResolved) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isResolved',
        value: [isResolved],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      isResolvedNotEqualTo(bool isResolved) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [],
              upper: [isResolved],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [isResolved],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [isResolved],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [],
              upper: [isResolved],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      firestoreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      firestoreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firestoreId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      firestoreIdEqualTo(String? firestoreId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [firestoreId],
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterWhereClause>
      firestoreIdNotEqualTo(String? firestoreId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MerchantShortageQueryFilter
    on QueryBuilder<MerchantShortage, MerchantShortage, QFilterCondition> {
  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firestoreId',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firestoreId',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firestoreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firestoreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      firestoreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
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

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      isResolvedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isResolved',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantId',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantId',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      merchantIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      quantityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MerchantShortageQueryObject
    on QueryBuilder<MerchantShortage, MerchantShortage, QFilterCondition> {}

extension MerchantShortageQueryLinks
    on QueryBuilder<MerchantShortage, MerchantShortage, QFilterCondition> {}

extension MerchantShortageQuerySortBy
    on QueryBuilder<MerchantShortage, MerchantShortage, QSortBy> {
  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByMerchantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantId', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByMerchantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantId', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MerchantShortageQuerySortThenBy
    on QueryBuilder<MerchantShortage, MerchantShortage, QSortThenBy> {
  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByMerchantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantId', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByMerchantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantId', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MerchantShortageQueryWhereDistinct
    on QueryBuilder<MerchantShortage, MerchantShortage, QDistinct> {
  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByFirestoreId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firestoreId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isResolved');
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByMerchantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantId');
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<MerchantShortage, MerchantShortage, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MerchantShortageQueryProperty
    on QueryBuilder<MerchantShortage, MerchantShortage, QQueryProperty> {
  QueryBuilder<MerchantShortage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MerchantShortage, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MerchantShortage, String?, QQueryOperations>
      firestoreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firestoreId');
    });
  }

  QueryBuilder<MerchantShortage, bool, QQueryOperations> isResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isResolved');
    });
  }

  QueryBuilder<MerchantShortage, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MerchantShortage, int?, QQueryOperations> merchantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantId');
    });
  }

  QueryBuilder<MerchantShortage, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<MerchantShortage, String, QQueryOperations>
      productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<MerchantShortage, double?, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<MerchantShortage, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
