INTERFACE zif_managed_type
  PUBLIC .
  INTERFACES zif_type.
  METHODS get_attribute
    IMPORTING
              i_name             TYPE string
    RETURNING VALUE(r_attribute) TYPE REF TO zif_attribute
    RAISING
              zcx_metamodel.
  METHODS get_attributes
    RETURNING VALUE(r_attributes) TYPE zif_attribute=>tab.
  METHODS get_table_type
    RETURNING VALUE(r_table_type) TYPE REF TO cl_abap_structdescr.
  METHODS get_association
    IMPORTING i_name               TYPE string
    RETURNING VALUE(r_association) TYPE REF TO zif_association
    RAISING
      zcx_metamodel.
  METHODS get_associations
    RETURNING VALUE(r_associations) TYPE zif_association=>tab.
ENDINTERFACE.
