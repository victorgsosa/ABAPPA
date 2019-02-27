INTERFACE zif_transition
  PUBLIC .
  TYPES transitions TYPE STANDARD TABLE OF REF TO zif_transition WITH DEFAULT KEY.
  METHODS is_possible
    IMPORTING
              i_c               TYPE string
    RETURNING VALUE(r_possible) TYPE abap_bool.
  METHODS state
    RETURNING VALUE(r_state) TYPE REF TO zif_state.
ENDINTERFACE.
