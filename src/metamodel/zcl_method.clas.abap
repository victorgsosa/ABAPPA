CLASS zcl_method DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_member
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_method.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_method IMPLEMENTATION.

  METHOD zif_method~invoke.
    DATA(name) = me->zif_member~get_name( ).
    CALL METHOD i_parent_object->(name)
      PARAMETER-TABLE c_parameters.
  ENDMETHOD.

ENDCLASS.
