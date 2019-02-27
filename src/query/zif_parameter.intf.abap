INTERFACE zif_parameter
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_parameter WITH DEFAULT KEY.
  METHODS get_name
    RETURNING VALUE(r_name) TYPE string.
  METHODS get_kind
    RETURNING VALUE(r_type) TYPE abap_typekind.
  METHODS get_position
    RETURNING VALUE(r_position) TYPE i.
ENDINTERFACE.
