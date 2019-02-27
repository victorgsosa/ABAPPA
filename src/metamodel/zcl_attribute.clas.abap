CLASS zcl_attribute DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_attribute.
    METHODS constructor
      IMPORTING
        i_name          TYPE string
        i_abap_type     TYPE REF TO cl_abap_typedescr
        i_parent_entity TYPE REF TO zif_entity
        i_accesor       TYPE REF TO zif_accesor
        i_mutator       TYPE REF TO zif_mutator.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA name TYPE string.
    DATA abap_type TYPE REF TO cl_abap_typedescr.
    DATA parent_entity TYPE REF TO zif_entity.
    DATA accesor TYPE REF TO zif_accesor.
    DATA mutator TYPE REF TO zif_mutator.

ENDCLASS.



CLASS zcl_attribute IMPLEMENTATION.

  METHOD constructor.

    me->name = i_name.
    me->abap_type = i_abap_type.
    me->parent_entity = i_parent_entity.
    me->accesor = i_accesor.
    me->mutator = i_mutator.

  ENDMETHOD.
  METHOD zif_attribute~accesor.
    r_accesor = me->accesor.
  ENDMETHOD.

  METHOD zif_attribute~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD zif_attribute~mutator.
    r_mutator = me->mutator.
  ENDMETHOD.

  METHOD zif_attribute~get_parent_entity.
    r_parent_entity = me->parent_entity.
  ENDMETHOD.

  METHOD zif_attribute~get_abap_type.
    r_abap_type = me->abap_type.
  ENDMETHOD.

ENDCLASS.
