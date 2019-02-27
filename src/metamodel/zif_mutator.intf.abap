INTERFACE zif_mutator
  PUBLIC .
  METHODS set_value
    IMPORTING
      i_value  TYPE any
    CHANGING
      c_parent_object TYPE REF TO object
    RAISING
      zcx_metamodel.
ENDINTERFACE.
