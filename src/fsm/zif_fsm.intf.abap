INTERFACE zif_fsm
  PUBLIC .
  METHODS switch_state
    IMPORTING
              i_c          TYPE string
    RETURNING VALUE(r_fsm) TYPE REF TO zif_fsm.
  METHODS can_stop
    RETURNING VALUE(r_stop) TYPE abap_bool.

  METHODS current_state
    RETURNING VALUE(r_state) TYPE REF TO zif_state.
ENDINTERFACE.
