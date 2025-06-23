// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtodo_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubtodoModelCollection on Isar {
  IsarCollection<SubtodoModel> get subtodoModels => this.collection();
}

const SubtodoModelSchema = CollectionSchema(
  name: r'SubtodoModel',
  id: -5568627757034907144,
  properties: {
    r'isCompleted': PropertySchema(
      id: 0,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'title': PropertySchema(
      id: 1,
      name: r'title',
      type: IsarType.string,
    ),
    r'todoId': PropertySchema(
      id: 2,
      name: r'todoId',
      type: IsarType.long,
    )
  },
  estimateSize: _subtodoModelEstimateSize,
  serialize: _subtodoModelSerialize,
  deserialize: _subtodoModelDeserialize,
  deserializeProp: _subtodoModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'todo': LinkSchema(
      id: 5513410885040043135,
      name: r'todo',
      target: r'TodoModel',
      single: false,
      linkName: r'subtodos',
    )
  },
  embeddedSchemas: {},
  getId: _subtodoModelGetId,
  getLinks: _subtodoModelGetLinks,
  attach: _subtodoModelAttach,
  version: '3.1.0+1',
);

int _subtodoModelEstimateSize(
  SubtodoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _subtodoModelSerialize(
  SubtodoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isCompleted);
  writer.writeString(offsets[1], object.title);
  writer.writeLong(offsets[2], object.todoId);
}

SubtodoModel _subtodoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubtodoModel();
  object.id = id;
  object.isCompleted = reader.readBool(offsets[0]);
  object.title = reader.readString(offsets[1]);
  object.todoId = reader.readLong(offsets[2]);
  return object;
}

P _subtodoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subtodoModelGetId(SubtodoModel object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _subtodoModelGetLinks(SubtodoModel object) {
  return [object.todo];
}

void _subtodoModelAttach(
    IsarCollection<dynamic> col, Id id, SubtodoModel object) {
  object.id = id;
  object.todo.attach(col, col.isar.collection<TodoModel>(), r'todo', id);
}

extension SubtodoModelQueryWhereSort
    on QueryBuilder<SubtodoModel, SubtodoModel, QWhere> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubtodoModelQueryWhere
    on QueryBuilder<SubtodoModel, SubtodoModel, QWhereClause> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterWhereClause> idBetween(
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
}

extension SubtodoModelQueryFilter
    on QueryBuilder<SubtodoModel, SubtodoModel, QFilterCondition> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> idGreaterThan(
    Id? value, {
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

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> idLessThan(
    Id? value, {
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

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
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

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> todoIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'todoId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'todoId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'todoId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> todoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'todoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubtodoModelQueryObject
    on QueryBuilder<SubtodoModel, SubtodoModel, QFilterCondition> {}

extension SubtodoModelQueryLinks
    on QueryBuilder<SubtodoModel, SubtodoModel, QFilterCondition> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition> todo(
      FilterQuery<TodoModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'todo');
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todo', length, true, length, true);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todo', 0, true, 0, true);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todo', 0, false, 999999, true);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todo', 0, true, length, include);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todo', length, include, 999999, true);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterFilterCondition>
      todoLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'todo', lower, includeLower, upper, includeUpper);
    });
  }
}

extension SubtodoModelQuerySortBy
    on QueryBuilder<SubtodoModel, SubtodoModel, QSortBy> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> sortByTodoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoId', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> sortByTodoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoId', Sort.desc);
    });
  }
}

extension SubtodoModelQuerySortThenBy
    on QueryBuilder<SubtodoModel, SubtodoModel, QSortThenBy> {
  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByTodoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoId', Sort.asc);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QAfterSortBy> thenByTodoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoId', Sort.desc);
    });
  }
}

extension SubtodoModelQueryWhereDistinct
    on QueryBuilder<SubtodoModel, SubtodoModel, QDistinct> {
  QueryBuilder<SubtodoModel, SubtodoModel, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubtodoModel, SubtodoModel, QDistinct> distinctByTodoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'todoId');
    });
  }
}

extension SubtodoModelQueryProperty
    on QueryBuilder<SubtodoModel, SubtodoModel, QQueryProperty> {
  QueryBuilder<SubtodoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubtodoModel, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<SubtodoModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SubtodoModel, int, QQueryOperations> todoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todoId');
    });
  }
}
