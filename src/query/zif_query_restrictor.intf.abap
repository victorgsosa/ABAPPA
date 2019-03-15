INTERFACE zif_query_restrictor
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_query_restrictor WITH DEFAULT KEY.

  METHODS restrict
    RETURNING VALUE(r_restriction) TYPE string
    RAISING
              zcx_query_auth.

ENDINTERFACE.
