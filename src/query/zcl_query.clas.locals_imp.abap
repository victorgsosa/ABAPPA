*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

INTERFACE zif_state_with_parameter.
  METHODS get_parameter
    IMPORTING
              i_c            TYPE string
    RETURNING VALUE(r_token) TYPE string
    RAISING   zcx_query.
ENDINTERFACE.

CLASS lcl_abstract_where_state DEFINITION INHERITING FROM zcl_state ABSTRACT.
  PUBLIC SECTION.
    INTERFACES zif_state_with_parameter ALL METHODS ABSTRACT.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
  PRIVATE SECTION.
    DATA parameter_state TYPE abap_bool.
ENDCLASS.

CLASS lcl_abstract_where_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).


  ENDMETHOD.


ENDCLASS.

CLASS lcl_word_state DEFINITION INHERITING FROM lcl_abstract_where_state.
  PUBLIC SECTION.
    METHODS: zif_state_with_parameter~get_parameter REDEFINITION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
ENDCLASS.

CLASS lcl_word_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

  ENDMETHOD.

  METHOD zif_state_with_parameter~get_parameter.
    r_token = i_c.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_named_parameter_state DEFINITION INHERITING FROM lcl_abstract_where_state.
  PUBLIC SECTION.
    METHODS: zif_state_with_parameter~get_parameter REDEFINITION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL
        i_query TYPE REF TO zif_query.
  PRIVATE SECTION.
    DATA query TYPE REF TO zif_query.
ENDCLASS.

CLASS lcl_named_parameter_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

    me->query = i_query.

  ENDMETHOD.


  METHOD zif_state_with_parameter~get_parameter.
    CLEAR r_token.
    DATA(name) = i_c+1.
    DATA(value) = me->query->get_parameter_value( i_name = name ).
    ASSIGN value->* TO FIELD-SYMBOL(<value>).
    r_token = cl_abap_dyn_prg=>quote( condense( CONV string( <value> ) ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_position_parameter_state DEFINITION INHERITING FROM lcl_abstract_where_state.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL
        i_query TYPE REF TO zif_query.
    METHODS: zif_state_with_parameter~get_parameter REDEFINITION.
  PRIVATE SECTION.
    DATA query TYPE REF TO zif_query.
ENDCLASS.

CLASS lcl_position_parameter_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

    me->query = i_query.

  ENDMETHOD.

  METHOD zif_state_with_parameter~get_parameter.
    CLEAR r_token.
    DATA(position) = CONV i( i_c+1 ).
    DATA(value) = me->query->get_parameter_value( i_position = position ).
    ASSIGN value->* TO FIELD-SYMBOL(<value>).
    r_token = cl_abap_dyn_prg=>quote( condense( CONV string( <value> ) ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_pos_unmarked_param_state DEFINITION INHERITING FROM lcl_abstract_where_state.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_final    TYPE abap_bool OPTIONAL
        i_query    TYPE REF TO zif_query
        i_position TYPE i DEFAULT 1.
    METHODS: zif_state_with_parameter~get_parameter REDEFINITION.
  PRIVATE SECTION.
    DATA query TYPE REF TO zif_query.
    DATA position TYPE i.
ENDCLASS.

CLASS lcl_pos_unmarked_param_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

    me->query = i_query.
    me->position = i_position.

  ENDMETHOD.

  METHOD zif_state_with_parameter~get_parameter.
    CLEAR r_token.
    DATA(value) = me->query->get_parameter_value( i_position = me->position ).
    ASSIGN value->* TO FIELD-SYMBOL(<value>).
    r_token = cl_abap_dyn_prg=>quote( condense( CONV string( <value> ) ) ).
    me->position = me->position + 1.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_where_fsm DEFINITION INHERITING FROM zcl_fsm.
  PUBLIC SECTION.

    METHODS zif_fsm~switch_state REDEFINITION.
    METHODS constructor
      IMPORTING
        i_current TYPE REF TO zif_state
        i_result  TYPE string DEFAULT ''.
    METHODS: get_result RETURNING VALUE(r_result) TYPE string.
    CLASS-METHODS: create
      IMPORTING i_query      TYPE REF TO zif_query
      RETURNING VALUE(r_fsm) TYPE REF TO lcl_where_fsm.

  PRIVATE SECTION.
    DATA result TYPE string.
ENDCLASS.

CLASS lcl_where_fsm IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_current = i_current ).

    me->result = i_result.

  ENDMETHOD.


  METHOD zif_fsm~switch_state.
    DATA(new_state) = me->zif_fsm~current_state( )->transit( i_c ).

    TRY.
        DATA(token) = CAST  zif_state_with_parameter( new_state )->get_parameter( i_c ).
        IF me->result IS NOT INITIAL.
          DATA(new_result) = |{ me->result } { token }|.
        ELSE.
          new_result = token.
        ENDIF.
      CATCH zcx_query INTO DATA(exception).
        RAISE EXCEPTION TYPE zcx_fsm
          EXPORTING
            previous = exception.
      CATCH cx_sy_move_cast_error.
        new_result = me->result.
    ENDTRY.
    r_fsm = NEW lcl_where_fsm( i_current = new_state  i_result = new_result ).
  ENDMETHOD.

  METHOD get_result.
    r_result = me->result.
  ENDMETHOD.



  METHOD create.
    DATA(no_parameters) = NEW  lcl_word_state( i_final = abap_true ).
    DATA(with_named_word) = NEW lcl_word_state( i_final = abap_true ).
    DATA(with_position_word) = NEW lcl_word_state( i_final = abap_true ).
    DATA(with_unmarked_word) = NEW lcl_word_state( i_final = abap_true ).
    DATA(named_parameter) = NEW lcl_named_parameter_state( i_final = abap_true i_query = i_query ).
    DATA(position_parameter) = NEW lcl_position_parameter_state( i_final = abap_true i_query = i_query ).
    DATA(unmarked_parameter) = NEW lcl_pos_unmarked_param_state( i_final = abap_true i_query = i_query ).
    no_parameters->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = no_parameters ) ).
    no_parameters->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    no_parameters->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    no_parameters->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    with_named_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_named_word ) ).
    with_named_word->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    named_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_named_word ) ).
    named_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    with_position_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_position_word ) ).
    with_position_word->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    position_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_position_word ) ).
    position_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    with_unmarked_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_unmarked_word ) ).
    with_unmarked_word->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    unmarked_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = with_unmarked_word ) ).
    unmarked_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    r_fsm = NEW lcl_where_fsm( i_current = no_parameters ).
  ENDMETHOD.

ENDCLASS.
