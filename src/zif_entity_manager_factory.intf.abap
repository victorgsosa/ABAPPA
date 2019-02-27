INTERFACE zif_entity_manager_factory
  PUBLIC .
  METHODS get_metamodel
    RETURNING VALUE(r_metamodel) TYPE REF TO zif_metamodel.
  METHODS get_datasource
    RETURNING VALUE(r_datasource) TYPE REF TO zif_datasource.
  METHODS create_entity_manager
    RETURNING VALUE(r_entity_manager) TYPE REF TO zif_entity_manager.
ENDINTERFACE.
