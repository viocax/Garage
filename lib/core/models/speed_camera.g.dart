// GENERATED CODE - DO NOT MODIFY BY HAND
// MARK: Isar 暫時不使用 - 此檔案為自動生成檔案，目前不使用
// 如需重新啟用 Isar，請取消 speed_camera.dart 中的註解並執行:
// dart run build_runner build --delete-conflicting-outputs

// part of 'speed_camera.dart'; // MARK: 已在 speed_camera.dart 中註解，此行也需註解

/*
// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSpeedCameraCollection on Isar {
  IsarCollection<SpeedCamera> get speedCameras => this.collection();
}

const SpeedCameraSchema = CollectionSchema(
  name: r'SpeedCamera',
  id: 4836117737013547596,
  properties: {
    r'code': PropertySchema(
      id: 0,
      name: r'code',
      type: IsarType.string,
    ),
    r'direction': PropertySchema(
      id: 1,
      name: r'direction',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'latitude': PropertySchema(
      id: 3,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 4,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'mileage': PropertySchema(
      id: 5,
      name: r'mileage',
      type: IsarType.double,
    ),
    r'remarks': PropertySchema(
      id: 6,
      name: r'remarks',
      type: IsarType.string,
    ),
    r'roadNumber': PropertySchema(
      id: 7,
      name: r'roadNumber',
      type: IsarType.string,
    ),
    r'speedLimit': PropertySchema(
      id: 8,
      name: r'speedLimit',
      type: IsarType.long,
    ),
    r'xCoordinate': PropertySchema(
      id: 9,
      name: r'xCoordinate',
      type: IsarType.double,
    ),
    r'yCoordinate': PropertySchema(
      id: 10,
      name: r'yCoordinate',
      type: IsarType.double,
    )
  },
  estimateSize: _speedCameraEstimateSize,
  serialize: _speedCameraSerialize,
  deserialize: _speedCameraDeserialize,
  deserializeProp: _speedCameraDeserializeProp,
  idName: r'id',
  indexes: {
    r'code': IndexSchema(
      id: 329780482934683790,
      name: r'code',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'code',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'roadNumber': IndexSchema(
      id: 2382359692837176630,
      name: r'roadNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'roadNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'direction': IndexSchema(
      id: -4378097054569869819,
      name: r'direction',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'direction',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'speedLimit': IndexSchema(
      id: 6583239172154926303,
      name: r'speedLimit',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'speedLimit',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'longitude': IndexSchema(
      id: -7076447437327017580,
      name: r'longitude',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'longitude',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'latitude': IndexSchema(
      id: 2839588665230214757,
      name: r'latitude',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'latitude',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'remarks': IndexSchema(
      id: -6946846383927629910,
      name: r'remarks',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'remarks',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _speedCameraGetId,
  getLinks: _speedCameraGetLinks,
  attach: _speedCameraAttach,
  version: '3.1.0+1',
);

int _speedCameraEstimateSize(
  SpeedCamera object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.code.length * 3;
  bytesCount += 3 + object.direction.length * 3;
  {
    final value = object.remarks;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.roadNumber.length * 3;
  return bytesCount;
}

void _speedCameraSerialize(
  SpeedCamera object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.code);
  writer.writeString(offsets[1], object.direction);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeDouble(offsets[3], object.latitude);
  writer.writeDouble(offsets[4], object.longitude);
  writer.writeDouble(offsets[5], object.mileage);
  writer.writeString(offsets[6], object.remarks);
  writer.writeString(offsets[7], object.roadNumber);
  writer.writeLong(offsets[8], object.speedLimit);
  writer.writeDouble(offsets[9], object.xCoordinate);
  writer.writeDouble(offsets[10], object.yCoordinate);
}

SpeedCamera _speedCameraDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SpeedCamera();
  object.code = reader.readString(offsets[0]);
  object.direction = reader.readString(offsets[1]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[2]);
  object.latitude = reader.readDouble(offsets[3]);
  object.longitude = reader.readDouble(offsets[4]);
  object.mileage = reader.readDouble(offsets[5]);
  object.remarks = reader.readStringOrNull(offsets[6]);
  object.roadNumber = reader.readString(offsets[7]);
  object.speedLimit = reader.readLong(offsets[8]);
  object.xCoordinate = reader.readDouble(offsets[9]);
  object.yCoordinate = reader.readDouble(offsets[10]);
  return object;
}

P _speedCameraDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _speedCameraGetId(SpeedCamera object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _speedCameraGetLinks(SpeedCamera object) {
  return [];
}

void _speedCameraAttach(
    IsarCollection<dynamic> col, Id id, SpeedCamera object) {
  object.id = id;
}

extension SpeedCameraQueryWhereSort
    on QueryBuilder<SpeedCamera, SpeedCamera, QWhere> {
  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhere> anySpeedLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'speedLimit'),
      );
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhere> anyLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'longitude'),
      );
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhere> anyLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'latitude'),
      );
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhere> anyRemarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'remarks'),
      );
    });
  }
}

extension SpeedCameraQueryWhere
    on QueryBuilder<SpeedCamera, SpeedCamera, QWhereClause> {
  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> idBetween(
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

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> codeEqualTo(
      String code) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'code',
        value: [code],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> codeNotEqualTo(
      String code) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [],
              upper: [code],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [code],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [code],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [],
              upper: [code],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> roadNumberEqualTo(
      String roadNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'roadNumber',
        value: [roadNumber],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause>
      roadNumberNotEqualTo(String roadNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roadNumber',
              lower: [],
              upper: [roadNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roadNumber',
              lower: [roadNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roadNumber',
              lower: [roadNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roadNumber',
              lower: [],
              upper: [roadNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> directionEqualTo(
      String direction) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'direction',
        value: [direction],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> directionNotEqualTo(
      String direction) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'direction',
              lower: [],
              upper: [direction],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'direction',
              lower: [direction],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'direction',
              lower: [direction],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'direction',
              lower: [],
              upper: [direction],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> speedLimitEqualTo(
      int speedLimit) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'speedLimit',
        value: [speedLimit],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause>
      speedLimitNotEqualTo(int speedLimit) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'speedLimit',
              lower: [],
              upper: [speedLimit],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'speedLimit',
              lower: [speedLimit],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'speedLimit',
              lower: [speedLimit],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'speedLimit',
              lower: [],
              upper: [speedLimit],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause>
      speedLimitGreaterThan(
    int speedLimit, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'speedLimit',
        lower: [speedLimit],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> speedLimitLessThan(
    int speedLimit, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'speedLimit',
        lower: [],
        upper: [speedLimit],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> speedLimitBetween(
    int lowerSpeedLimit,
    int upperSpeedLimit, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'speedLimit',
        lower: [lowerSpeedLimit],
        includeLower: includeLower,
        upper: [upperSpeedLimit],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> longitudeEqualTo(
      double longitude) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'longitude',
        value: [longitude],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> longitudeNotEqualTo(
      double longitude) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'longitude',
              lower: [],
              upper: [longitude],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'longitude',
              lower: [longitude],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'longitude',
              lower: [longitude],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'longitude',
              lower: [],
              upper: [longitude],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause>
      longitudeGreaterThan(
    double longitude, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'longitude',
        lower: [longitude],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> longitudeLessThan(
    double longitude, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'longitude',
        lower: [],
        upper: [longitude],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> longitudeBetween(
    double lowerLongitude,
    double upperLongitude, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'longitude',
        lower: [lowerLongitude],
        includeLower: includeLower,
        upper: [upperLongitude],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> latitudeEqualTo(
      double latitude) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'latitude',
        value: [latitude],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> latitudeNotEqualTo(
      double latitude) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latitude',
              lower: [],
              upper: [latitude],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latitude',
              lower: [latitude],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latitude',
              lower: [latitude],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'latitude',
              lower: [],
              upper: [latitude],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> latitudeGreaterThan(
    double latitude, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latitude',
        lower: [latitude],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> latitudeLessThan(
    double latitude, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latitude',
        lower: [],
        upper: [latitude],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> latitudeBetween(
    double lowerLatitude,
    double upperLatitude, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'latitude',
        lower: [lowerLatitude],
        includeLower: includeLower,
        upper: [upperLatitude],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remarks',
        value: [null],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remarks',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksEqualTo(
      String? remarks) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remarks',
        value: [remarks],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksNotEqualTo(
      String? remarks) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remarks',
              lower: [],
              upper: [remarks],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remarks',
              lower: [remarks],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remarks',
              lower: [remarks],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remarks',
              lower: [],
              upper: [remarks],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksGreaterThan(
    String? remarks, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remarks',
        lower: [remarks],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksLessThan(
    String? remarks, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remarks',
        lower: [],
        upper: [remarks],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksBetween(
    String? lowerRemarks,
    String? upperRemarks, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remarks',
        lower: [lowerRemarks],
        includeLower: includeLower,
        upper: [upperRemarks],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksStartsWith(
      String RemarksPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remarks',
        lower: [RemarksPrefix],
        upper: ['$RemarksPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause> remarksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remarks',
        value: [''],
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterWhereClause>
      remarksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'remarks',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'remarks',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'remarks',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'remarks',
              upper: [''],
            ));
      }
    });
  }
}

extension SpeedCameraQueryFilter
    on QueryBuilder<SpeedCamera, SpeedCamera, QFilterCondition> {
  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'code',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'code',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'direction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> mileageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      mileageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> mileageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> mileageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mileage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remarks',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remarks',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition> remarksMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remarks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remarks',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      remarksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remarks',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roadNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roadNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roadNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roadNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      roadNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roadNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      speedLimitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      speedLimitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      speedLimitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      speedLimitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      xCoordinateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      xCoordinateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      xCoordinateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      xCoordinateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xCoordinate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      yCoordinateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      yCoordinateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'yCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      yCoordinateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'yCoordinate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterFilterCondition>
      yCoordinateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'yCoordinate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SpeedCameraQueryObject
    on QueryBuilder<SpeedCamera, SpeedCamera, QFilterCondition> {}

extension SpeedCameraQueryLinks
    on QueryBuilder<SpeedCamera, SpeedCamera, QFilterCondition> {}

extension SpeedCameraQuerySortBy
    on QueryBuilder<SpeedCamera, SpeedCamera, QSortBy> {
  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByRemarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByRemarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByRoadNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roadNumber', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByRoadNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roadNumber', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortBySpeedLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedLimit', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortBySpeedLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedLimit', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByXCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xCoordinate', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByXCoordinateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xCoordinate', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByYCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yCoordinate', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> sortByYCoordinateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yCoordinate', Sort.desc);
    });
  }
}

extension SpeedCameraQuerySortThenBy
    on QueryBuilder<SpeedCamera, SpeedCamera, QSortThenBy> {
  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByRemarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByRemarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByRoadNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roadNumber', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByRoadNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roadNumber', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenBySpeedLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedLimit', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenBySpeedLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedLimit', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByXCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xCoordinate', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByXCoordinateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xCoordinate', Sort.desc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByYCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yCoordinate', Sort.asc);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QAfterSortBy> thenByYCoordinateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yCoordinate', Sort.desc);
    });
  }
}

extension SpeedCameraQueryWhereDistinct
    on QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> {
  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'code', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByDirection(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mileage');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByRemarks(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remarks', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByRoadNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roadNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctBySpeedLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedLimit');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByXCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xCoordinate');
    });
  }

  QueryBuilder<SpeedCamera, SpeedCamera, QDistinct> distinctByYCoordinate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yCoordinate');
    });
  }
}

extension SpeedCameraQueryProperty
    on QueryBuilder<SpeedCamera, SpeedCamera, QQueryProperty> {
  QueryBuilder<SpeedCamera, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SpeedCamera, String, QQueryOperations> codeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'code');
    });
  }

  QueryBuilder<SpeedCamera, String, QQueryOperations> directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<SpeedCamera, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<SpeedCamera, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<SpeedCamera, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<SpeedCamera, double, QQueryOperations> mileageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mileage');
    });
  }

  QueryBuilder<SpeedCamera, String?, QQueryOperations> remarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remarks');
    });
  }

  QueryBuilder<SpeedCamera, String, QQueryOperations> roadNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roadNumber');
    });
  }

  QueryBuilder<SpeedCamera, int, QQueryOperations> speedLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedLimit');
    });
  }

  QueryBuilder<SpeedCamera, double, QQueryOperations> xCoordinateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xCoordinate');
    });
  }

  QueryBuilder<SpeedCamera, double, QQueryOperations> yCoordinateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yCoordinate');
    });
  }
}
*/
