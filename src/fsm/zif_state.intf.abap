INTERFACE zif_state
  PUBLIC .
  TYPES states TYPE STANDARD TABLE OF REF TO zif_state WITH DEFAULT KEY.
  METHODS with
    IMPORTING
              i_transition   TYPE REF TO zif_transition
    RETURNING VALUE(r_state) TYPE REF TO zif_state.
  METHODS transit
    IMPORTING
              i_c            TYPE string
    RETURNING VALUE(r_state) TYPE REF TO zif_state.
  METHODS is_final
    RETURNING VALUE(r_final) TYPE abap_bool.
ENDINTERFACE.
