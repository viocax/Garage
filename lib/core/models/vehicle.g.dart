// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVehicleCollection on Isar {
  IsarCollection<Vehicle> get vehicles => this.collection();
}

const VehicleSchema = CollectionSchema(
  name: r'Vehicle',
  id: -21624847921258799,
  properties: {
    r'carName': PropertySchema(id: 0, name: r'carName', type: IsarType.string),
    r'currentKm': PropertySchema(
      id: 1,
      name: r'currentKm',
      type: IsarType.long,
    ),
    r'kmToNextMaintenance': PropertySchema(
      id: 2,
      name: r'kmToNextMaintenance',
      type: IsarType.long,
    ),
    r'maintenanceHealth': PropertySchema(
      id: 3,
      name: r'maintenanceHealth',
      type: IsarType.double,
    ),
    r'maintenanceIntervalKm': PropertySchema(
      id: 4,
      name: r'maintenanceIntervalKm',
      type: IsarType.long,
    ),
    r'order': PropertySchema(id: 5, name: r'order', type: IsarType.long),
    r'spentThisMonth': PropertySchema(
      id: 6,
      name: r'spentThisMonth',
      type: IsarType.string,
    ),
    r'totalSpent': PropertySchema(
      id: 7,
      name: r'totalSpent',
      type: IsarType.string,
    ),
    r'vehicleId': PropertySchema(
      id: 8,
      name: r'vehicleId',
      type: IsarType.string,
    ),
  },

  estimateSize: _vehicleEstimateSize,
  serialize: _vehicleSerialize,
  deserialize: _vehicleDeserialize,
  deserializeProp: _vehicleDeserializeProp,
  idName: r'id',
  indexes: {
    r'vehicleId': IndexSchema(
      id: 2011968157433523416,
      name: r'vehicleId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vehicleId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {
    r'records': LinkSchema(
      id: -8761819284901550202,
      name: r'records',
      target: r'VehicleRecord',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _vehicleGetId,
  getLinks: _vehicleGetLinks,
  attach: _vehicleAttach,
  version: '3.3.0',
);

int _vehicleEstimateSize(
  Vehicle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.carName.length * 3;
  bytesCount += 3 + object.spentThisMonth.length * 3;
  bytesCount += 3 + object.totalSpent.length * 3;
  bytesCount += 3 + object.vehicleId.length * 3;
  return bytesCount;
}

void _vehicleSerialize(
  Vehicle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.carName);
  writer.writeLong(offsets[1], object.currentKm);
  writer.writeLong(offsets[2], object.kmToNextMaintenance);
  writer.writeDouble(offsets[3], object.maintenanceHealth);
  writer.writeLong(offsets[4], object.maintenanceIntervalKm);
  writer.writeLong(offsets[5], object.order);
  writer.writeString(offsets[6], object.spentThisMonth);
  writer.writeString(offsets[7], object.totalSpent);
  writer.writeString(offsets[8], object.vehicleId);
}

Vehicle _vehicleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Vehicle();
  object.carName = reader.readString(offsets[0]);
  object.currentKm = reader.readLong(offsets[1]);
  object.id = id;
  object.kmToNextMaintenance = reader.readLong(offsets[2]);
  object.maintenanceIntervalKm = reader.readLong(offsets[4]);
  object.order = reader.readLong(offsets[5]);
  object.vehicleId = reader.readString(offsets[8]);
  return object;
}

P _vehicleDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vehicleGetId(Vehicle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vehicleGetLinks(Vehicle object) {
  return [object.records];
}

void _vehicleAttach(IsarCollection<dynamic> col, Id id, Vehicle object) {
  object.id = id;
  object.records.attach(
    col,
    col.isar.collection<VehicleRecord>(),
    r'records',
    id,
  );
}

extension VehicleByIndex on IsarCollection<Vehicle> {
  Future<Vehicle?> getByVehicleId(String vehicleId) {
    return getByIndex(r'vehicleId', [vehicleId]);
  }

  Vehicle? getByVehicleIdSync(String vehicleId) {
    return getByIndexSync(r'vehicleId', [vehicleId]);
  }

  Future<bool> deleteByVehicleId(String vehicleId) {
    return deleteByIndex(r'vehicleId', [vehicleId]);
  }

  bool deleteByVehicleIdSync(String vehicleId) {
    return deleteByIndexSync(r'vehicleId', [vehicleId]);
  }

  Future<List<Vehicle?>> getAllByVehicleId(List<String> vehicleIdValues) {
    final values = vehicleIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'vehicleId', values);
  }

  List<Vehicle?> getAllByVehicleIdSync(List<String> vehicleIdValues) {
    final values = vehicleIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'vehicleId', values);
  }

  Future<int> deleteAllByVehicleId(List<String> vehicleIdValues) {
    final values = vehicleIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'vehicleId', values);
  }

  int deleteAllByVehicleIdSync(List<String> vehicleIdValues) {
    final values = vehicleIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'vehicleId', values);
  }

  Future<Id> putByVehicleId(Vehicle object) {
    return putByIndex(r'vehicleId', object);
  }

  Id putByVehicleIdSync(Vehicle object, {bool saveLinks = true}) {
    return putByIndexSync(r'vehicleId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVehicleId(List<Vehicle> objects) {
    return putAllByIndex(r'vehicleId', objects);
  }

  List<Id> putAllByVehicleIdSync(
    List<Vehicle> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'vehicleId', objects, saveLinks: saveLinks);
  }
}

extension VehicleQueryWhereSort on QueryBuilder<Vehicle, Vehicle, QWhere> {
  QueryBuilder<Vehicle, Vehicle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VehicleQueryWhere on QueryBuilder<Vehicle, Vehicle, QWhereClause> {
  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> idBetween(
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

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> vehicleIdEqualTo(
    String vehicleId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'vehicleId', value: [vehicleId]),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterWhereClause> vehicleIdNotEqualTo(
    String vehicleId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vehicleId',
                lower: [],
                upper: [vehicleId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vehicleId',
                lower: [vehicleId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vehicleId',
                lower: [vehicleId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'vehicleId',
                lower: [],
                upper: [vehicleId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension VehicleQueryFilter
    on QueryBuilder<Vehicle, Vehicle, QFilterCondition> {
  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'carName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'carName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'carName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'carName', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> carNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'carName', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> currentKmEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentKm', value: value),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> currentKmGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> currentKmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> currentKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentKm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  kmToNextMaintenanceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kmToNextMaintenance', value: value),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  kmToNextMaintenanceGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kmToNextMaintenance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  kmToNextMaintenanceLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kmToNextMaintenance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  kmToNextMaintenanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kmToNextMaintenance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceHealthEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maintenanceHealth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceHealthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maintenanceHealth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceHealthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maintenanceHealth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceHealthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maintenanceHealth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceIntervalKmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maintenanceIntervalKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceIntervalKmGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maintenanceIntervalKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceIntervalKmLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maintenanceIntervalKm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  maintenanceIntervalKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maintenanceIntervalKm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> orderEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  spentThisMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spentThisMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  spentThisMonthStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'spentThisMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> spentThisMonthMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'spentThisMonth',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  spentThisMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spentThisMonth', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  spentThisMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'spentThisMonth', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalSpent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'totalSpent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'totalSpent',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalSpent', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> totalSpentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'totalSpent', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vehicleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vehicleId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vehicleId', value: ''),
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vehicleId', value: ''),
      );
    });
  }
}

extension VehicleQueryObject
    on QueryBuilder<Vehicle, Vehicle, QFilterCondition> {}

extension VehicleQueryLinks
    on QueryBuilder<Vehicle, Vehicle, QFilterCondition> {
  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> records(
    FilterQuery<VehicleRecord> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'records');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> recordsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'records', length, true, length, true);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> recordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'records', 0, true, 0, true);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> recordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'records', 0, false, 999999, true);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> recordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'records', 0, true, length, include);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition>
  recordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'records', length, include, 999999, true);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterFilterCondition> recordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'records',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension VehicleQuerySortBy on QueryBuilder<Vehicle, Vehicle, QSortBy> {
  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByCarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carName', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByCarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carName', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByCurrentKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentKm', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByCurrentKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentKm', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByKmToNextMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kmToNextMaintenance', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByKmToNextMaintenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kmToNextMaintenance', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByMaintenanceHealth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceHealth', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByMaintenanceHealthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceHealth', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByMaintenanceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceIntervalKm', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy>
  sortByMaintenanceIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceIntervalKm', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortBySpentThisMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spentThisMonth', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortBySpentThisMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spentThisMonth', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByTotalSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSpent', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByTotalSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSpent', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension VehicleQuerySortThenBy
    on QueryBuilder<Vehicle, Vehicle, QSortThenBy> {
  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByCarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carName', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByCarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carName', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByCurrentKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentKm', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByCurrentKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentKm', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByKmToNextMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kmToNextMaintenance', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByKmToNextMaintenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kmToNextMaintenance', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByMaintenanceHealth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceHealth', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByMaintenanceHealthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceHealth', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByMaintenanceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceIntervalKm', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy>
  thenByMaintenanceIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceIntervalKm', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenBySpentThisMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spentThisMonth', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenBySpentThisMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spentThisMonth', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByTotalSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSpent', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByTotalSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSpent', Sort.desc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QAfterSortBy> thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension VehicleQueryWhereDistinct
    on QueryBuilder<Vehicle, Vehicle, QDistinct> {
  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByCarName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByCurrentKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentKm');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByKmToNextMaintenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kmToNextMaintenance');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByMaintenanceHealth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maintenanceHealth');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByMaintenanceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maintenanceIntervalKm');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctBySpentThisMonth({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'spentThisMonth',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByTotalSpent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSpent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Vehicle, Vehicle, QDistinct> distinctByVehicleId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }
}

extension VehicleQueryProperty
    on QueryBuilder<Vehicle, Vehicle, QQueryProperty> {
  QueryBuilder<Vehicle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Vehicle, String, QQueryOperations> carNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carName');
    });
  }

  QueryBuilder<Vehicle, int, QQueryOperations> currentKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentKm');
    });
  }

  QueryBuilder<Vehicle, int, QQueryOperations> kmToNextMaintenanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kmToNextMaintenance');
    });
  }

  QueryBuilder<Vehicle, double, QQueryOperations> maintenanceHealthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maintenanceHealth');
    });
  }

  QueryBuilder<Vehicle, int, QQueryOperations> maintenanceIntervalKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maintenanceIntervalKm');
    });
  }

  QueryBuilder<Vehicle, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<Vehicle, String, QQueryOperations> spentThisMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spentThisMonth');
    });
  }

  QueryBuilder<Vehicle, String, QQueryOperations> totalSpentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSpent');
    });
  }

  QueryBuilder<Vehicle, String, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }
}
