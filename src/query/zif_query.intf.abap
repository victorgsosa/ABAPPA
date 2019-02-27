INTERFACE zif_query
  PUBLIC .
  TYPES objects TYPE STANDARD TABLE OF REF TO object WITH DEFAULT KEY.
  TYPES: BEGIN OF parameter,
           name      TYPE string,
           position  TYPE i,
           parameter TYPE REF TO zif_parameter,
           value     TYPE REF TO data,
         END OF parameter.
  TYPES parameters TYPE SORTED TABLE OF parameter WITH UNIQUE KEY name position.
  METHODS get_entity
    RETURNING VALUE(r_entity) TYPE REF TO zif_entity.
  METHODS get_where_string
    RETURNING VALUE(r_where_string) TYPE string.
  METHODS get_parameter
    IMPORTING
              i_name             TYPE string OPTIONAL
              i_position         TYPE i OPTIONAL
    RETURNING VALUE(r_parameter) TYPE REF TO zif_parameter
    RAISING
              zcx_query.
  METHODS get_parameter_value
    IMPORTING
              i_name         TYPE string OPTIONAL
              i_position     TYPE i OPTIONAL
    RETURNING VALUE(r_value) TYPE REF TO data
    RAISING
              zcx_query.
  METHODS get_result_list
    RETURNING VALUE(r_results) TYPE zif_query=>objects
    RAISING
      zcx_query.
  METHODS get_single_result
    RETURNING VALUE(r_result) TYPE REF TO object
    RAISING
              zcx_query.
  METHODS set_parameter
    IMPORTING
      i_value     TYPE any
      i_name      TYPE string OPTIONAL
      i_position  TYPE i OPTIONAL
      i_parameter TYPE REF TO zif_parameter OPTIONAL
    RAISING
      zcx_query.
ENDINTERFACE.
