CLASS zcl_cds_em_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_entity_manager_factory.
    METHODS constructor
      IMPORTING
        i_datasource TYPE REF TO zif_datasource
        i_metamodel TYPE REF TO zif_metamodel.

  PROTECTED SECTION.
  PRIVATE SECTION.
    data datasource type ref to zif_datasource.
    data metamodel type ref to zif_metamodel.
ENDCLASS.



CLASS zcl_cds_em_factory IMPLEMENTATION.

  METHOD constructor.

    me->datasource = i_datasource.
    me->metamodel = i_metamodel.

  ENDMETHOD.


  METHOD zif_entity_manager_factory~create_entity_manager.
    r_entity_manager = new zcl_cds_entity_manager(
        i_datasource = me->zif_entity_manager_factory~get_datasource( )
        i_metamodel = me->zif_entity_manager_factory~get_metamodel( )
    ).
  ENDMETHOD.

  METHOD zif_entity_manager_factory~get_datasource.
    r_datasource = me->datasource.
  ENDMETHOD.

  METHOD zif_entity_manager_factory~get_metamodel.
    r_metamodel = me->metamodel.
  ENDMETHOD.

ENDCLASS.
