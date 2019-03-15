INTERFACE zif_query_auth
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_query_auth WITH DEFAULT KEY.

  methods get_object
    RETURNING VALUE(r_object) type xuobject.

  METHODS get_auth_retriever
    RETURNING VALUE(r_auth_retriever) TYPE REF TO zif_auth_retriever.

  methods get_activity
    RETURNING VALUE(r_activity) type activ_auth.

  METHODS map_field
    IMPORTING i_field               TYPE string
    RETURNING VALUE(r_auth_field) TYPE string.
  METHODS restrict
    IMPORTING
              i_user               TYPE sy-uname DEFAULT sy-uname
    RETURNING VALUE(r_restriction) TYPE string
    RAISING
      zcx_query_auth..
ENDINTERFACE.
