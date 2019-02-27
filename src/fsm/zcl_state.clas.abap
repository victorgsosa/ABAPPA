CLASS zcl_state DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_state.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool  DEFAULT abap_false.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA final TYPE abap_bool.
    DATA transitions TYPE zif_transition=>transitions.
ENDCLASS.



CLASS zcl_state IMPLEMENTATION.

  METHOD constructor.

    me->final = i_final.

  ENDMETHOD.
  METHOD zif_state~is_final.
    r_final = me->final.
  ENDMETHOD.

  METHOD zif_state~transit.
    LOOP AT me->transitions INTO DATA(t).
      IF t->is_possible( i_c ).
        r_state = t->state( ).
        RETURN.
      ENDIF.
    ENDLOOP.
    RAISE EXCEPTION TYPE zcx_fsm.
  ENDMETHOD.

  METHOD zif_state~with.
    APPEND i_transition TO me->transitions.
    r_state = me.
  ENDMETHOD.

ENDCLASS.
