INTERFACE zif_method
  PUBLIC .
  INTERFACES zif_member.
  METHODS invoke
    IMPORTING
      i_parent_object     TYPE REF TO object
    CHANGING
      c_parameters TYPE abap_parmbind_tab.
ENDINTERFACE.
