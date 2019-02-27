CLASS zcl_abstract_member DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PROTECTED .

  PUBLIC SECTION.
    INTERFACES zif_member.

  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        i_parent_class TYPE REF TO cl_abap_objectdescr
        i_name         TYPE string.
  PRIVATE SECTION.
    DATA parent_class TYPE REF TO cl_abap_objectdescr.
    DATA name TYPE string.
ENDCLASS.



CLASS zcl_abstract_member IMPLEMENTATION.

  METHOD constructor.

    me->parent_class = i_parent_class.
    me->name = i_name.

  ENDMETHOD.
  METHOD zif_member~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD zif_member~get_parent_class.
    r_parent_class = me->parent_class.
  ENDMETHOD.

ENDCLASS.
