CLASS zcl_auth_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_auth_value.
    METHODS constructor
      IMPORTING
        i_field TYPE xufield
        i_von   TYPE xuval
        i_bis   TYPE xuval OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA field TYPE xufield.
    DATA von TYPE xuval.
    DATA bis TYPE xuval.
ENDCLASS.



CLASS zcl_auth_value IMPLEMENTATION.

  METHOD constructor.

    me->field = i_field.
    me->von = i_von.
    me->bis = i_bis.

  ENDMETHOD.
  METHOD zif_auth_value~get_field.
    r_field = me->field.
  ENDMETHOD.

  METHOD zif_auth_value~get_von.
    r_vor = me->von.
  ENDMETHOD.

  METHOD zif_auth_value~get_bis.
    r_bis = me->bis.
  ENDMETHOD.

ENDCLASS.
