INTERFACE zif_query_auth
  PUBLIC .
  INTERFACES zif_query_restrictor.
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_query_auth WITH DEFAULT KEY.

  METHODS map_field
    IMPORTING i_field             TYPE string
    RETURNING VALUE(r_auth_field) TYPE string.

ENDINTERFACE.
