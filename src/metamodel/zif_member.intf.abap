INTERFACE zif_member
  PUBLIC .
  METHODS get_parent_class
    RETURNING VALUE(r_parent_class) TYPE REF TO cl_abap_objectdescr.
  METHODS get_name
    RETURNING VALUE(r_name) TYPE string.
ENDINTERFACE.
