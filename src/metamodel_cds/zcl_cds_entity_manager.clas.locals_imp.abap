*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_collector DEFINITION.
  PUBLIC SECTION.
    METHODS: get_entity RETURNING VALUE(r_result) TYPE REF TO zif_entity,
      set_entity IMPORTING i_entity TYPE REF TO zif_entity,
      get_parameters RETURNING VALUE(r_result) TYPE zif_query=>parameters,
      set_parameters IMPORTING i_parameters TYPE zif_query=>parameters,
      add_parameter IMPORTING i_parameter TYPE zif_query=>parameter,
      append_to_where IMPORTING i_token TYPE string,
      get_where RETURNING VALUE(r_result) TYPE string,
      get_fields RETURNING VALUE(r_result) TYPE string,
      set_fields IMPORTING i_fields TYPE string.

  PRIVATE SECTION.
    DATA entity TYPE REF TO zif_entity.
    DATA parameters TYPE zif_query=>parameters.
    DATA where TYPE string.
    DATA fields TYPE string.
ENDCLASS.

CLASS lcl_collector IMPLEMENTATION.

  METHOD get_entity.
    r_result = me->entity.
  ENDMETHOD.

  METHOD set_entity.
    me->entity = i_entity.
  ENDMETHOD.

  METHOD get_parameters.
    r_result = me->parameters.
  ENDMETHOD.

  METHOD set_parameters.
    me->parameters = i_parameters.
  ENDMETHOD.

  METHOD add_parameter.
    IF NOT line_exists( me->parameters[ KEY primary_key COMPONENTS name = i_parameter-name position = i_parameter-position ] ).
      INSERT i_parameter INTO TABLE me->parameters.
    ENDIF.
  ENDMETHOD.

  METHOD append_to_where.
    IF me->where IS INITIAL.
      me->where = i_token.
    ELSE.
      me->where = |{ me->where } { i_token }|.
    ENDIF.
  ENDMETHOD.

  METHOD get_where.
    r_result = me->where.
  ENDMETHOD.

  METHOD get_fields.
    r_result = me->fields.
  ENDMETHOD.

  METHOD set_fields.
    me->fields = i_fields.
  ENDMETHOD.

ENDCLASS.


INTERFACE lif_collector_state.
  METHODS apply
    IMPORTING
      i_c         TYPE string
    CHANGING
      c_collector TYPE REF TO lcl_collector
    RAISING
      zcx_query.
ENDINTERFACE.

CLASS lcl_fields_state DEFINITION INHERITING FROM zcl_state.
  PUBLIC SECTION.
    INTERFACES lif_collector_state.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
ENDCLASS.

CLASS lcl_fields_state IMPLEMENTATION.

  METHOD lif_collector_state~apply.
    DATA(fields) = c_collector->get_fields( ).
    IF fields IS INITIAL.
      fields = i_c.
    ELSE.
      fields = |{ fields } { i_c }|.
    ENDIF.
    c_collector->set_fields( fields ).
  ENDMETHOD.

  METHOD constructor.

    super->constructor( i_final = i_final ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_entity_state DEFINITION INHERITING FROM zcl_state.
  PUBLIC SECTION.
    INTERFACES lif_collector_state.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL
        i_em    TYPE REF TO zif_entity_manager.
  PRIVATE SECTION.
    DATA em TYPE REF TO zif_entity_manager.
ENDCLASS.

CLASS lcl_entity_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

    me->em = i_em.

  ENDMETHOD.

  METHOD lif_collector_state~apply.
    CALL METHOD cl_abap_classdescr=>describe_by_name
      EXPORTING
        p_name         = i_c
      RECEIVING
        p_descr_ref    = DATA(entity_type)
      EXCEPTIONS
        type_not_found = 1.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    TRY.
        c_collector->set_entity(
            me->em->get_metamodel( )->entity(
                CAST cl_abap_classdescr( entity_type )
            )
        ).
      CATCH cx_root INTO DATA(exception).
        RAISE EXCEPTION TYPE zcx_query
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_abstract_parameter_state DEFINITION INHERITING FROM zcl_state ABSTRACT CREATE PROTECTED.
  PUBLIC SECTION.
    INTERFACES lif_collector_state.
  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
    METHODS get_parameter ABSTRACT
      IMPORTING
                i_c                TYPE string
                i_collector        TYPE REF TO lcl_collector
      RETURNING VALUE(r_parameter) TYPE zif_query=>parameter
      RAISING
                zcx_query .
ENDCLASS.

CLASS lcl_abstract_parameter_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

  ENDMETHOD.

  METHOD lif_collector_state~apply.
    c_collector->add_parameter( get_parameter( i_c = i_c  i_collector = c_collector ) ).
    c_collector->append_to_where( i_c ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_named_parameter_state DEFINITION INHERITING FROM lcl_abstract_parameter_state CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
  PROTECTED SECTION.

    METHODS get_parameter REDEFINITION.
  PRIVATE SECTION.
    METHODS get_attribute
      IMPORTING
                i_name             TYPE string
                i_collector        TYPE REF TO lcl_collector
      RETURNING VALUE(i_attribute) TYPE REF TO zif_attribute
      RAISING
                zcx_query.
ENDCLASS.



CLASS lcl_named_parameter_state IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

  ENDMETHOD.

  METHOD get_parameter.
    DATA(name) = i_c+1.
    DATA(attribute) = get_attribute( i_name = name i_collector = i_collector ).
    DATA(parameter) = zcl_parameter=>create( i_name = name i_kind = attribute->get_abap_type( )->type_kind ).
    r_parameter = VALUE #( name = name parameter = parameter ).
  ENDMETHOD.


  METHOD get_attribute.
    TRY.
        i_attribute = i_collector->get_entity( )->zif_managed_type~get_attribute( i_name = i_name ).
      CATCH zcx_metamodel INTO DATA(exception).
        RAISE EXCEPTION TYPE zcx_query
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_positional_parameter DEFINITION INHERITING FROM lcl_abstract_parameter_state CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_final TYPE abap_bool OPTIONAL.
  PROTECTED SECTION.
    METHODS get_parameter REDEFINITION.
ENDCLASS.

CLASS lcl_positional_parameter IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

  ENDMETHOD.

  METHOD get_parameter.
    DATA(position) = CONV i( i_c+1 ).
    DATA(parameter) = zcl_parameter=>create( i_position = position i_kind = cl_abap_typedescr=>typekind_any ).
    r_parameter = VALUE #( position = position parameter = parameter ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_unmarked_pos_parameter DEFINITION INHERITING FROM lcl_abstract_parameter_state CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_final    TYPE abap_bool OPTIONAL
        i_position TYPE i.
  PROTECTED SECTION.

    METHODS get_parameter REDEFINITION.
  PRIVATE SECTION.
    DATA position TYPE i.
ENDCLASS.

CLASS lcl_unmarked_pos_parameter IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_final = i_final ).

    me->position = i_position.

  ENDMETHOD.

  METHOD get_parameter.
    DATA(parameter) = zcl_parameter=>create( i_position = me->position i_kind = cl_abap_typedescr=>typekind_any ).
    r_parameter = VALUE #( position = me->position parameter = parameter ).
    ADD 1 TO me->position.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_where_state DEFINITION INHERITING FROM zcl_state.
  PUBLIC SECTION.
    INTERFACES lif_collector_state.
ENDCLASS.

CLASS lcl_where_state IMPLEMENTATION.

  METHOD lif_collector_state~apply.
    c_collector->append_to_where( i_c ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_query_fsm DEFINITION INHERITING FROM zcl_fsm.
  PUBLIC SECTION.

    METHODS zif_fsm~switch_state REDEFINITION.
    METHODS constructor
      IMPORTING
        i_current TYPE REF TO zif_state
        i_result  TYPE REF TO lcl_collector OPTIONAL.
    METHODS: get_result RETURNING VALUE(r_result) TYPE REF TO lcl_collector.
    CLASS-METHODS: create
      IMPORTING i_em         TYPE REF TO zif_entity_manager
      RETURNING VALUE(r_fsm) TYPE REF TO lcl_query_fsm.

  PRIVATE SECTION.
    DATA result TYPE REF TO lcl_collector.
ENDCLASS.

CLASS lcl_query_fsm IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_current = i_current ).
    me->result = COND #( WHEN i_result IS NOT INITIAL THEN  i_result ELSE NEW lcl_collector( ) ).

  ENDMETHOD.


  METHOD zif_fsm~switch_state.
    DATA(new_state) = me->zif_fsm~current_state( )->transit( i_c ).
    IF new_state IS INSTANCE OF lif_collector_state.
      TRY.
          CAST lif_collector_state( new_state )->apply( EXPORTING i_c = i_c CHANGING c_collector = me->result ).
        CATCH zcx_query INTO DATA(exception).
          RAISE EXCEPTION TYPE zcx_fsm
            EXPORTING
              previous = exception.
      ENDTRY.
    ENDIF.
    r_fsm = NEW lcl_query_fsm( i_current = new_state i_result = me->result ).
  ENDMETHOD.

  METHOD get_result.
    r_result = me->result.
  ENDMETHOD.



  METHOD create.
    DATA(initial) = NEW zcl_state( i_final = abap_false ).
    DATA(where) = NEW zcl_state( i_final = abap_false ).
    DATA(from_state) = NEW zcl_state( i_final = abap_false ).
    data(fields) = new lcl_fields_state( i_final = abap_false ).
    DATA(entity) = NEW lcl_entity_state( i_final = abap_true i_em = i_em ).
    DATA(named_parameter) = NEW lcl_named_parameter_state( i_final = abap_true ).
    DATA(position_parameter) = NEW lcl_positional_parameter( i_final = abap_true ).
    DATA(unmarked_parameter) = NEW lcl_unmarked_pos_parameter( i_final = abap_true i_position = 1 ).
    DATA(named_word) = NEW lcl_where_state( i_final = abap_false ).
    DATA(position_word) = NEW lcl_where_state( i_final = abap_false ).
    DATA(unmarked_word) = NEW lcl_where_state( i_final = abap_false ).
    initial->zif_state~with( NEW zcl_transition( i_pattern = 'SELECT' i_next = initial ) ).
    initial->zif_state~with( NEW zcl_transition( i_pattern = '^(?!SELECT$).*' i_next = fields ) ).
    fields->zif_state~with( NEW zcl_transition( i_pattern = '^(?!FROM$).*' i_next = fields ) ).
    fields->zif_state~with( NEW zcl_transition( i_pattern = 'FROM' i_next = from_state ) ).
    from_state->zif_state~with( NEW zcl_transition( i_pattern = '.*' i_next = entity ) ).
    entity->zif_state~with( NEW zcl_transition( i_pattern = '.*' i_next = where ) ).
    where->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = where ) ).
    where->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    where->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    where->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    named_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = named_word ) ).
    named_word->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    named_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = named_word ) ).
    named_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^:.+' i_next = named_parameter ) ).
    position_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = position_word ) ).
    position_word->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    position_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = position_word ) ).
    position_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^\?.{1}' i_next = position_parameter ) ).
    unmarked_word->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = unmarked_word ) ).
    unmarked_word->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    unmarked_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^(?!\?|:).*' i_next = unmarked_word ) ).
    unmarked_parameter->zif_state~with( NEW zcl_transition( i_pattern = '^\?' i_next = unmarked_parameter ) ).
    r_fsm = NEW lcl_query_fsm( i_current = initial ).
  ENDMETHOD.

ENDCLASS.
