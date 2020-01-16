import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/actions_menu_button.dart';
import 'package:invoiceninja_flutter/ui/app/lists/list_filter.dart';
import 'package:invoiceninja_flutter/ui/app/presenters/entity_presenter.dart';

class EntityDataTableSource extends DataTableSource {
  EntityDataTableSource(
      {@required this.context,
      @required this.editingId,
      @required this.entityList,
      @required this.entityMap,
      @required this.entityPresenter,
      @required this.tableColumns,
      @required this.entityType,
      @required this.onTap});

  EntityType entityType;
  String editingId;
  BuildContext context;
  List<String> entityList;
  EntityPresenter entityPresenter;
  BuiltMap<String, BaseEntity> entityMap;
  List<String> tableColumns;

  final Function(BaseEntity entity) onTap;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => entityList.length;

  @override
  DataRow getRow(int index) {
    final state = StoreProvider.of<AppState>(context).state;
    final entity = entityMap[entityList[index]];
    entityPresenter.initialize(entity: entity, context: context);

    final listState = state.getListState(entityType);
    final uIState = state.getUIState(entityType);

    return DataRow(
      selected: (listState.selectedIds ?? <String>[]).contains(entity.id),
      onSelectChanged: listState.isInMultiselect()
          ? (value) {
              print('onSelectChanged');
              onTap(entity);
            }
          : null,
      cells: [
        if (!listState.isInMultiselect())
          DataCell(Row(
            children: <Widget>[
              Text(
                '•',
                style: TextStyle(
                    color: (state.uiState.isEditing
                            ? entity.id == editingId
                            : entity.id == uIState.selectedId)
                        ? Theme.of(context).accentColor
                        : Colors.transparent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              ActionMenuButton(
                entityActions: entity.getActions(
                    userCompany: state.userCompany, includeEdit: true),
                isSaving: false,
                entity: entity,
                onSelected: (context, action) =>
                    handleEntityAction(context, entity, action),
              ),
            ],
          )),
        ...tableColumns.map(
          (field) => DataCell(
            Text(entityPresenter.getField(field: field, context: context)),
            onTap: () => onTap(entity),
          ),
        )
      ],
    );
  }
}

class DatatableHeader extends StatelessWidget {
  const DatatableHeader({this.entityType, this.onClearPressed});

  final EntityType entityType;
  final Function() onClearPressed;

  @override
  Widget build(BuildContext context) {
    final state = StoreProvider.of<AppState>(context).state;
    final listUIState = state.getListState(entityType);

    String message = '';
    if (listUIState.filterEntityId != null) {
      final entity = state.getEntityMap(
          listUIState.filterEntityType)[listUIState.filterEntityId];
      message = ListFilterMessage.getMessage(
          context: context,
          filterEntityType: listUIState.filterEntityType,
          entity: entity);
    }

    return Row(
      children: <Widget>[
        if (listUIState.filterEntityId != null) ...[
          FlatButton(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.orangeAccent),
            ),
            onPressed: () => viewEntityById(
              context: context,
              entityId: listUIState.filterEntityId,
              entityType: listUIState.filterEntityType,
            ),
          ),
          IconButton(
            onPressed: onClearPressed,
            icon: Icon(Icons.clear),
          )
        ]
      ],
    );
  }
}