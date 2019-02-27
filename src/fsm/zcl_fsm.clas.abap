CLASS zcl_fsm DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_fsm.
    METHODS constructor
      IMPORTING
        i_current TYPE REF TO zif_state.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA current TYPE REF TO zif_state.
ENDCLASS.



CLASS zcl_fsm IMPLEMENTATION.

  METHOD constructor.

    me->current = i_current.

  ENDMETHOD.
  METHOD zif_fsm~can_stop.
    r_stop = me->current->is_final( ).
  ENDMETHOD.

  METHOD zif_fsm~switch_state.
    r_fsm = NEW zcl_fsm( me->current->transit( i_c ) ).
  ENDMETHOD.

  METHOD zif_fsm~current_state.
    r_state = me->current.
  ENDMETHOD.

ENDCLASS.
