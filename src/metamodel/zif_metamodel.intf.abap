INTERFACE zif_metamodel
  PUBLIC .
  METHODS entity
    IMPORTING
              i_class         TYPE REF TO cl_abap_classdescr
    RETURNING VALUE(r_entity) TYPE REF TO zif_entity
    RAISING
      zcx_metamodel.
ENDINTERFACE.
