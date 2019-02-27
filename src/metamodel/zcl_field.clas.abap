CLASS zcl_field DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_member
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces zif_field.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_field IMPLEMENTATION.
  METHOD zif_field~get.
    data(name) = me->zif_member~get_name( ).
    ASSIGN i_parent_object->(name) to FIELD-SYMBOL(<fs_value>).
    e_value = <fs_value>.
  ENDMETHOD.


  METHOD zif_field~set.
   data(name) = me->zif_member~get_name( ).
    ASSIGN c_parent_object->(name) to FIELD-SYMBOL(<fs_value>).
    <fs_value> = i_value.
  ENDMETHOD.

ENDCLASS.
