CLASS zcl_association DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_association.
    METHODS constructor
      IMPORTING
        i_name        TYPE string
        i_target      TYPE string
        i_entity      TYPE REF TO zif_entity
        i_cardinality TYPE i.
    METHODS: set_name IMPORTING i_name TYPE string,
      set_target IMPORTING i_target TYPE string,
      set_entity IMPORTING i_entity TYPE REF TO zif_entity,
      set_cardinality IMPORTING i_cardinality TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA name TYPE string.
    DATA target TYPE string.
    DATA entity TYPE REF TO zif_entity.
    DATA cardinality TYPE i.
ENDCLASS.



CLASS zcl_association IMPLEMENTATION.

  METHOD constructor.

    me->name = i_name.
    me->target = i_target.
    me->entity = i_entity.
    me->cardinality = i_cardinality.

  ENDMETHOD.
  METHOD zif_association~get_cardinality.
    r_cardinality = me->cardinality.
  ENDMETHOD.

  METHOD zif_association~get_entity.
    r_entity = me->entity.
  ENDMETHOD.

  METHOD zif_association~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD zif_association~get_target.
    r_target = me->target.
  ENDMETHOD.

  METHOD set_name.
    me->name = i_name.
  ENDMETHOD.

  METHOD set_target.
    me->target = i_target.
  ENDMETHOD.

  METHOD set_entity.
    me->entity = i_entity.
  ENDMETHOD.

  METHOD set_cardinality.
    me->cardinality = i_cardinality.
  ENDMETHOD.

ENDCLASS.
