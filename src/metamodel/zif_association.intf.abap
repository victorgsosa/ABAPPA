INTERFACE zif_association
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_association WITH DEFAULT KEY.
  METHODS get_entity
    RETURNING VALUE(r_entity) TYPE REF TO zif_entity.
  METHODS get_target
    RETURNING VALUE(r_target) TYPE string.
  METHODS get_name
    RETURNING VALUE(r_name) TYPE string.
  METHODS get_cardinality
    RETURNING VALUE(r_cardinality) type i.
ENDINTERFACE.
