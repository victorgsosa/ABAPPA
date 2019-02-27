CLASS zcl_parameter DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.
    INTERFACES zif_parameter.
    CLASS-METHODS create
      IMPORTING
        i_kind          TYPE ABAP_TYPEKIND
        i_name          TYPE string OPTIONAL
        i_position      TYPE i OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO zcl_parameter
      RAISING
        zcx_query.
    METHODS: set_name IMPORTING i_name TYPE string,
      set_position IMPORTING i_position TYPE i,
      set_kind IMPORTING i_type TYPE ABAP_TYPEKIND.



  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        i_kind     TYPE ABAP_TYPEKIND
        i_name     TYPE string OPTIONAL
        i_position TYPE i OPTIONAL.
  PRIVATE SECTION.
    DATA name TYPE string.
    DATA position TYPE i.
    DATA kind TYPE abap_typekind.
ENDCLASS.



CLASS zcl_parameter IMPLEMENTATION.

  METHOD create.
    IF i_name IS NOT INITIAL AND i_position IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    CREATE OBJECT r_result
      EXPORTING
        i_kind     = i_kind
        i_name     = i_name
        i_position = i_position.


  ENDMETHOD.

  METHOD constructor.

    me->kind = i_kind.
    me->name = i_name.
    me->position = i_position.

  ENDMETHOD.


  METHOD zif_parameter~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD set_name.
    me->name = i_name.
  ENDMETHOD.

  METHOD zif_parameter~get_position.
    r_position = me->position.
  ENDMETHOD.

  METHOD set_position.
    me->position = i_position.
  ENDMETHOD.

  METHOD zif_parameter~get_kind.
    r_type = me->kind.
  ENDMETHOD.

  METHOD set_kind.
    me->kind = i_type.
  ENDMETHOD.

ENDCLASS.
