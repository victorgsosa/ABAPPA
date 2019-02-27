CLASS zcl_abstract_entity_manager DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PROTECTED .

  PUBLIC SECTION.
    INTERFACES zif_entity_manager
      ABSTRACT METHODS
      create_query.
    METHODS constructor
      IMPORTING
        i_datasource TYPE REF TO zif_datasource
        i_metamodel TYPE REF TO zif_metamodel.
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA datasource TYPE REF TO zif_datasource.
    DATA metamodel TYPE REF TO zif_metamodel.
ENDCLASS.



CLASS zcl_abstract_entity_manager IMPLEMENTATION.

  METHOD constructor.

    me->datasource = i_datasource.
    me->metamodel = i_metamodel.

  ENDMETHOD.

  METHOD zif_entity_manager~get_datasource.
    r_datasource = me->datasource.
  ENDMETHOD.

  METHOD zif_entity_manager~get_metamodel.
    r_metamodel = me->metamodel.
  ENDMETHOD.

ENDCLASS.
