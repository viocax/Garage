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
    r'fuelData': PropertySchema(
      id: 4,
      name: r'fuelData',
      type: IsarType.object,

      target: r'FuelData',
    ),
    r'km': PropertySchema(id: 5, name: r'km', type: IsarType.long),
    r'maintenanceData': PropertySchema(
      id: 6,
      name: r'maintenanceData',
      type: IsarType.objectList,

      target: r'MaintenanceData',
    ),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'otherData': PropertySchema(
      id: 8,
      name: r'otherData',
      type: IsarType.object,

      target: r'OtherData',
    ),
    r'recordId': PropertySchema(
      id: 9,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
    r'typeName': PropertySchema(
      id: 11,
      name: r'typeName',
      type: IsarType.string,
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
    r'typeName': IndexSchema(
      id: -5888759043734302821,
      name: r'typeName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'typeName',
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
  embeddedSchemas: {
    r'FuelData': FuelDataSchema,
    r'MaintenanceData': MaintenanceDataSchema,
    r'OtherData': OtherDataSchema,
  },

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
    final value = object.fuelData;
    if (value != null) {
      bytesCount +=
          3 +
          FuelDataSchema.estimateSize(value, allOffsets[FuelData]!, allOffsets);
    }
  }
  {
    final list = object.maintenanceData;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[MaintenanceData]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += MaintenanceDataSchema.estimateSize(
            value,
            offsets,
            allOffsets,
          );
        }
      }
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.otherData;
    if (value != null) {
      bytesCount +=
          3 +
          OtherDataSchema.estimateSize(
            value,
            allOffsets[OtherData]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.recordId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.typeName.length * 3;
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
  writer.writeObject<FuelData>(
    offsets[4],
    allOffsets,
    FuelDataSchema.serialize,
    object.fuelData,
  );
  writer.writeLong(offsets[5], object.km);
  writer.writeObjectList<MaintenanceData>(
    offsets[6],
    allOffsets,
    MaintenanceDataSchema.serialize,
    object.maintenanceData,
  );
  writer.writeString(offsets[7], object.notes);
  writer.writeObject<OtherData>(
    offsets[8],
    allOffsets,
    OtherDataSchema.serialize,
    object.otherData,
  );
  writer.writeString(offsets[9], object.recordId);
  writer.writeString(offsets[10], object.title);
  writer.writeString(offsets[11], object.typeName);
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
  object.fuelData = reader.readObjectOrNull<FuelData>(
    offsets[4],
    FuelDataSchema.deserialize,
    allOffsets,
  );
  object.id = id;
  object.km = reader.readLong(offsets[5]);
  object.maintenanceData = reader.readObjectList<MaintenanceData>(
    offsets[6],
    MaintenanceDataSchema.deserialize,
    allOffsets,
    MaintenanceData(),
  );
  object.notes = reader.readStringOrNull(offsets[7]);
  object.otherData = reader.readObjectOrNull<OtherData>(
    offsets[8],
    OtherDataSchema.deserialize,
    allOffsets,
  );
  object.recordId = reader.readString(offsets[9]);
  object.title = reader.readString(offsets[10]);
  object.typeName = reader.readString(offsets[11]);
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
      return (reader.readObjectOrNull<FuelData>(
            offset,
            FuelDataSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readObjectList<MaintenanceData>(
            offset,
            MaintenanceDataSchema.deserialize,
            allOffsets,
            MaintenanceData(),
          ))
          as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readObjectOrNull<OtherData>(
            offset,
            OtherDataSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> typeNameEqualTo(
    String typeName,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'typeName', value: [typeName]),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause>
  typeNameNotEqualTo(String typeName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeName',
                lower: [],
                upper: [typeName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeName',
                lower: [typeName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeName',
                lower: [typeName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'typeName',
                lower: [],
                upper: [typeName],
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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  fuelDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fuelData'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  fuelDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fuelData'),
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
  maintenanceDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maintenanceData'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maintenanceData'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'maintenanceData', length, true, length, true);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'maintenanceData', 0, true, 0, true);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'maintenanceData', 0, false, 999999, true);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'maintenanceData', 0, true, length, include);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'maintenanceData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'maintenanceData',
        lower,
        includeLower,
        upper,
        includeUpper,
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
  otherDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'otherData'),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  otherDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'otherData'),
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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'typeName',
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
  typeNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'typeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'typeName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'typeName', value: ''),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  typeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'typeName', value: ''),
      );
    });
  }
}

extension VehicleRecordQueryObject
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> fuelData(
    FilterQuery<FuelData> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'fuelData');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
  maintenanceDataElement(FilterQuery<MaintenanceData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'maintenanceData');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> otherData(
    FilterQuery<OtherData> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'otherData');
    });
  }
}

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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeName', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  sortByTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeName', Sort.desc);
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

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeName', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
  thenByTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeName', Sort.desc);
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

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByTypeName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeName', caseSensitive: caseSensitive);
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

  QueryBuilder<VehicleRecord, FuelData?, QQueryOperations> fuelDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelData');
    });
  }

  QueryBuilder<VehicleRecord, int, QQueryOperations> kmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'km');
    });
  }

  QueryBuilder<VehicleRecord, List<MaintenanceData>?, QQueryOperations>
  maintenanceDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maintenanceData');
    });
  }

  QueryBuilder<VehicleRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<VehicleRecord, OtherData?, QQueryOperations>
  otherDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'otherData');
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

  QueryBuilder<VehicleRecord, String, QQueryOperations> typeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeName');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FuelDataSchema = Schema(
  name: r'FuelData',
  id: 4739064174969176637,
  properties: {
    r'calculatedCost': PropertySchema(
      id: 0,
      name: r'calculatedCost',
      type: IsarType.double,
    ),
    r'formattedSummary': PropertySchema(
      id: 1,
      name: r'formattedSummary',
      type: IsarType.string,
    ),
    r'fuelAmount': PropertySchema(
      id: 2,
      name: r'fuelAmount',
      type: IsarType.double,
    ),
    r'fuelType': PropertySchema(
      id: 3,
      name: r'fuelType',
      type: IsarType.string,
      enumMap: _FuelDatafuelTypeEnumValueMap,
    ),
    r'pricePerLiter': PropertySchema(
      id: 4,
      name: r'pricePerLiter',
      type: IsarType.double,
    ),
    r'remainingFuel': PropertySchema(
      id: 5,
      name: r'remainingFuel',
      type: IsarType.long,
    ),
  },

  estimateSize: _fuelDataEstimateSize,
  serialize: _fuelDataSerialize,
  deserialize: _fuelDataDeserialize,
  deserializeProp: _fuelDataDeserializeProp,
);

int _fuelDataEstimateSize(
  FuelData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.formattedSummary.length * 3;
  bytesCount += 3 + object.fuelType.name.length * 3;
  return bytesCount;
}

void _fuelDataSerialize(
  FuelData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.calculatedCost);
  writer.writeString(offsets[1], object.formattedSummary);
  writer.writeDouble(offsets[2], object.fuelAmount);
  writer.writeString(offsets[3], object.fuelType.name);
  writer.writeDouble(offsets[4], object.pricePerLiter);
  writer.writeLong(offsets[5], object.remainingFuel);
}

FuelData _fuelDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FuelData(
    fuelAmount: reader.readDoubleOrNull(offsets[2]) ?? 0,
    fuelType:
        _FuelDatafuelTypeValueEnumMap[reader.readStringOrNull(offsets[3])] ??
        FuelType.octane95,
    pricePerLiter: reader.readDoubleOrNull(offsets[4]) ?? 0,
    remainingFuel: reader.readLongOrNull(offsets[5]) ?? 90,
  );
  return object;
}

P _fuelDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 3:
      return (_FuelDatafuelTypeValueEnumMap[reader.readStringOrNull(offset)] ??
              FuelType.octane95)
          as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 90) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FuelDatafuelTypeEnumValueMap = {
  r'octane92': r'octane92',
  r'octane95': r'octane95',
  r'octane98': r'octane98',
};
const _FuelDatafuelTypeValueEnumMap = {
  r'octane92': FuelType.octane92,
  r'octane95': FuelType.octane95,
  r'octane98': FuelType.octane98,
};

extension FuelDataQueryFilter
    on QueryBuilder<FuelData, FuelData, QFilterCondition> {
  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> calculatedCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'calculatedCost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  calculatedCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calculatedCost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  calculatedCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calculatedCost',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> calculatedCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calculatedCost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'formattedSummary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'formattedSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'formattedSummary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'formattedSummary', value: ''),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  formattedSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'formattedSummary', value: ''),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fuelAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fuelAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fuelAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fuelAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeEqualTo(
    FuelType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeGreaterThan(
    FuelType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeLessThan(
    FuelType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeBetween(
    FuelType lower,
    FuelType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fuelType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fuelType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fuelType', value: ''),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> fuelTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fuelType', value: ''),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> pricePerLiterEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pricePerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  pricePerLiterGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pricePerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> pricePerLiterLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pricePerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> pricePerLiterBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pricePerLiter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> remainingFuelEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remainingFuel', value: value),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition>
  remainingFuelGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remainingFuel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> remainingFuelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remainingFuel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FuelData, FuelData, QAfterFilterCondition> remainingFuelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remainingFuel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FuelDataQueryObject
    on QueryBuilder<FuelData, FuelData, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MaintenanceDataSchema = Schema(
  name: r'MaintenanceData',
  id: -1816869155871174686,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'item': PropertySchema(id: 1, name: r'item', type: IsarType.string),
    r'nextMaintenanceKm': PropertySchema(
      id: 2,
      name: r'nextMaintenanceKm',
      type: IsarType.long,
    ),
    r'note': PropertySchema(id: 3, name: r'note', type: IsarType.string),
  },

  estimateSize: _maintenanceDataEstimateSize,
  serialize: _maintenanceDataSerialize,
  deserialize: _maintenanceDataDeserialize,
  deserializeProp: _maintenanceDataDeserializeProp,
);

int _maintenanceDataEstimateSize(
  MaintenanceData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.item.length * 3;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _maintenanceDataSerialize(
  MaintenanceData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.item);
  writer.writeLong(offsets[2], object.nextMaintenanceKm);
  writer.writeString(offsets[3], object.note);
}

MaintenanceData _maintenanceDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceData(
    amount: reader.readDoubleOrNull(offsets[0]) ?? 0,
    item: reader.readStringOrNull(offsets[1]) ?? '',
    nextMaintenanceKm: reader.readLongOrNull(offsets[2]),
    note: reader.readStringOrNull(offsets[3]) ?? '',
  );
  return object;
}

P _maintenanceDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MaintenanceDataQueryFilter
    on QueryBuilder<MaintenanceData, MaintenanceData, QFilterCondition> {
  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'item',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'item',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'item',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'item', value: ''),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  itemIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'item', value: ''),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nextMaintenanceKm'),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nextMaintenanceKm'),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextMaintenanceKm', value: value),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextMaintenanceKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextMaintenanceKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  nextMaintenanceKmBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextMaintenanceKm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<MaintenanceData, MaintenanceData, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }
}

extension MaintenanceDataQueryObject
    on QueryBuilder<MaintenanceData, MaintenanceData, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const OtherDataSchema = Schema(
  name: r'OtherData',
  id: 5851794133580080387,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'note': PropertySchema(id: 1, name: r'note', type: IsarType.string),
  },

  estimateSize: _otherDataEstimateSize,
  serialize: _otherDataSerialize,
  deserialize: _otherDataDeserialize,
  deserializeProp: _otherDataDeserializeProp,
);

int _otherDataEstimateSize(
  OtherData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _otherDataSerialize(
  OtherData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.note);
}

OtherData _otherDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OtherData(
    amount: reader.readDoubleOrNull(offsets[0]) ?? 0,
    note: reader.readStringOrNull(offsets[1]) ?? '',
  );
  return object;
}

P _otherDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension OtherDataQueryFilter
    on QueryBuilder<OtherData, OtherData, QFilterCondition> {
  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<OtherData, OtherData, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }
}

extension OtherDataQueryObject
    on QueryBuilder<OtherData, OtherData, QFilterCondition> {}
