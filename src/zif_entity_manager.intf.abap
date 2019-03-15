INTERFACE zif_entity_manager
  PUBLIC .
  METHODS get_metamodel
    RETURNING VALUE(r_metamodel) TYPE REF TO zif_metamodel.
  METHODS get_datasource
    RETURNING VALUE(r_datasource) TYPE REF TO zif_datasource.
  METHODS create_query
    IMPORTING
              i_query          TYPE string
              i_selections     TYPE zif_query=>selection_tab OPTIONAL
              i_authorizations TYPE zif_query_auth=>tab OPTIONAL
    RETURNING VALUE(r_query)   TYPE REF TO zif_query
    RAISING
              zcx_query.
ENDINTERFACE.
