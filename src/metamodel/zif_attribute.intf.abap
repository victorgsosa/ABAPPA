INTERFACE zif_attribute
  PUBLIC .
  TYPES tab TYPE STANDARD TABLE OF REF TO zif_attribute WITH DEFAULT KEY.
  METHODS get_name
    RETURNING VALUE(r_name) TYPE string.
  METHODS mutator
    RETURNING VALUE(r_mutator) TYPE REF TO zif_mutator.
  METHODS accesor
    RETURNING VALUE(r_accesor) TYPE REF TO zif_accesor.
  METHODS get_parent_entity
    RETURNING VALUE(r_parent_entity) TYPE REF TO zif_entity.
  METHODS get_abap_type
    RETURNING VALUE(r_abap_type) TYPE REF TO cl_abap_typedescr.
  METHODS is_collection
    RETURNING VALUE(r_collection) TYPE abap_bool.
  METHODS is_association
    RETURNING VALUE(r_association) TYPE abap_bool.
ENDINTERFACE.
