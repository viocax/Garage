// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVehicleRecordCollection on Isar {
  IsarCollection<VehicleRecord> get vehicleRecords => this.collection();
}

const VehicleRecordSchema = CollectionSchema(
  name: r'VehicleRecord',
  id: -3548028493443854613,
  properties: {
    r'cost': PropertySchema(id: 0, name: r'cost', type: IsarType.double),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'formattedCost': PropertySchema(
      id: 2,
      name: r'formattedCost',
      type: IsarType.string,
    ),
    r'formattedKm': PropertySchema(
      id: 3,
      name: r'formattedKm',
      type: IsarType.string,
    ),
    r'km': PropertySchema(id: 4, name: r'km', type: IsarType.long),
    r'notes': PropertySchema(id: 5, name: r'notes', type: IsarType.string),
    r'recordId': PropertySchema(
      id: 6,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 7, name: r'title', type: IsarType.string),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.string,
      enumMap: _VehicleRecordtypeEnumValueMap,
    ),
  },

  estimateSize: _vehicleRecordEstimateSize,
  serialize: _vehicleRecordSerialize,
  deserialize: _vehicleRecordDeserialize,
  deserializeProp: _vehicleRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'recordId': IndexSchema(
      id: 907839981883940929,
      name: r'recordId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'km': IndexSchema(
      id: 8072772002229800939,
      name: r'km',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'km',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _vehicleRecordGetId,
  getLinks: _vehicleRecordGetLinks,
  attach: _vehicleRecordAttach,
  version: '3.3.0',
);

int _vehicleRecordEstimateSize(
  VehicleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.formattedCost.length * 3;
  bytesCount += 3 + object.formattedKm.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recordId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _vehicleRecordSerialize(
  VehicleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.formattedCost);
  writer.writeString(offsets[3], object.formattedKm);
  writer.writeLong(offsets[4], object.km);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.recordId);
  writer.writeString(offsets[7], object.title);
  writer.writeString(offsets[8], object.type.name);
}

VehicleRecord _vehicleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VehicleRecord();
  object.cost = reader.readDouble(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.km = reader.readLong(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.recordId = reader.readString(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.type =
      _VehicleRecordtypeValueEnumMap[reader.readStringOrNull(offsets[8])] ??
      RecordType.fuel;
  return object;
}

P _vehicleRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_VehicleRecordtypeValueEnumMap[reader.readStringOrNull(offset)] ??
              RecordType.fuel)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VehicleRecordtypeEnumValueMap = {
  r'fuel': r'fuel',
  r'maintenance': r'maintenance',
  r'modification': r'modification',
  r'other': r'other',
};
const _VehicleRecordtypeValueEnumMap = {
  r'fuel': RecordType.fuel,
  r'maintenance': RecordType.maintenance,
  r'modification': RecordType.modification,
  r'other': RecordType.other,
};

Id _vehicleRecordGetId(VehicleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vehicleRecordGetLinks(VehicleRecord object) {
  return [];
}

void _vehicleRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  VehicleRecord object,
) {
  object.id = id;
}

extension VehicleRecordByIndex on IsarCollection<VehicleRecord> {
  Future<VehicleRecord?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  VehicleRecord? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<VehicleRecord?>> getAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<VehicleRecord?> getAllByRecordIdSync(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'recordId', values);
  }

  Future<int> deleteAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'recordId', values);
  }

  int deleteAllByRecordIdSync(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'recordId', values);
  }

  Future<Id> putByRecordId(VehicleRecord object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(VehicleRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<VehicleRecord> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(
    List<VehicleRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension VehicleRecordQueryWhereSort
    on QueryBuilder<VehicleRecord, VehicleRecord, QWhere> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhere> anyKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IndexWhereClause.any(indexName: r'km'));
    });
  }
}

extension VehicleRecordQueryWhere
    on QueryBuilder<VehicleRecord, VehicleRecord, QWhereClause> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> recordIdEqualTo(
    String recordId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'recordId', value: [recordId]),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause>
  recordIdNotEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordId',
                lower: [],
                upper: [recordId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordId',
                lower: [recordId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordId',
                lower: [recordId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordId',
                lower: [],
                upper: [recordId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> dateEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> dateNotEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> kmEqualTo(
    int km,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'km', value: [km]),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> kmNotEqualTo(
    int km,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'km',
                lower: [],
                upper: [km],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'km',
                lower: [km],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'km',
                lower: [km],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'km',
                lower: [],
                upper: [km],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> kmGreaterThan(
    int km, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'km',
          lower: [km],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> kmLessThan(
    int km, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'km',
          lower: [],
          upper: [km],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> kmBetween(
    int lowerKm,
    int upperKm, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'km',
          lower: [lowerKm],
          includeLower: includeLower,
          upper: [upperKm],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension VehicleRecordQueryFilter
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> costEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  costGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  costLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> costBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'formattedCost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'formattedCost',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'formattedCost',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'formattedCost', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedCostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'formattedCost', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'formattedKm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'formattedKm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'formattedKm',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'formattedKm', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  formattedKmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'formattedKm', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> kmEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'km', value: value),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  kmGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'km',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> kmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'km',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> kmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'km',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recordId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'recordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'recordId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recordId', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'recordId', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> typeEqualTo(
    RecordType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeGreaterThan(
    RecordType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeLessThan(
    RecordType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> typeBetween(
    RecordType lower,
    RecordType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension VehicleRecordQueryObject
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {}

extension VehicleRecordQueryLinks
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {}

extension VehicleRecordQuerySortBy
    on QueryBuilder<VehicleRecord, VehicleRecord, QSortBy> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  sortByFormattedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  sortByFormattedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByFormattedKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedKm', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  sortByFormattedKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedKm', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'km', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'km', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension VehicleRecordQuerySortThenBy
    on QueryBuilder<VehicleRecord, VehicleRecord, QSortThenBy> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  thenByFormattedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  thenByFormattedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByFormattedKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedKm', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  thenByFormattedKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedKm', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'km', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'km', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension VehicleRecordQueryWhereDistinct
    on QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> {
  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cost');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct>
  distinctByFormattedCost({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'formattedCost',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByFormattedKm({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedKm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'km');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByRecordId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension VehicleRecordQueryProperty
    on QueryBuilder<VehicleRecord, VehicleRecord, QQueryProperty> {
  QueryBuilder<VehicleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VehicleRecord, double, QQueryOperations> costProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cost');
    });
  }

  QueryBuilder<VehicleRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations>
  formattedCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedCost');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> formattedKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedKm');
    });
  }

  QueryBuilder<VehicleRecord, int, QQueryOperations> kmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'km');
    });
  }

  QueryBuilder<VehicleRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<VehicleRecord, RecordType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
