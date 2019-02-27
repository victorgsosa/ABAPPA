INTERFACE zif_field
  PUBLIC .
  INTERFACES zif_member.

  METHODS get
    IMPORTING
      i_parent_object TYPE REF TO object
    EXPORTING
      e_value         TYPE any.

  METHODS set
    IMPORTING
      i_value         TYPE any
    CHANGING
      c_parent_object TYPE REF TO object.
ENDINTERFACE.
