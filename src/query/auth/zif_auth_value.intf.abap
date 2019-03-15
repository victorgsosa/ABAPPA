INTERFACE zif_auth_value
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_auth_value WITH DEFAULT KEY.
  METHODS get_field
    RETURNING VALUE(r_field) TYPE xufield.
  METHODS get_von
    RETURNING VALUE(r_vor) TYPE xuval.
  METHODS get_bis
    RETURNING VALUE(r_bis) TYPE xuval..
ENDINTERFACE.
