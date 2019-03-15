CLASS zcl_query DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED GLOBAL FRIENDS zif_entity_manager.

  PUBLIC SECTION.
    INTERFACES zif_query.
  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        i_entity_manager TYPE REF TO zif_entity_manager
        i_entity         TYPE REF TO zif_entity
        i_parameters     TYPE zif_query=>parameters
        i_where_string   TYPE string
        i_fields         TYPE string OPTIONAL.
  PRIVATE SECTION.
    DATA entity_manager TYPE REF TO zif_entity_manager.
    DATA entity TYPE REF TO zif_entity.
    DATA parameters TYPE zif_query=>parameters.
    DATA where_string TYPE string.
    DATA fields TYPE string.
    METHODS execute_query
      RETURNING
        VALUE(r_result) TYPE zif_query=>objects
      RAISING
        zcx_query.
    METHODS build_where
      RETURNING
        VALUE(r_result) TYPE string.
    METHODS map_to_entities
      IMPORTING
        i_results       TYPE ANY TABLE
      RETURNING
        VALUE(r_result) TYPE zif_query=>objects
      RAISING
        zcx_query.
    METHODS map_to_entity
      IMPORTING
        i_result        TYPE any
      RETURNING
        VALUE(r_result) TYPE REF TO object
      RAISING
        zcx_query.
    METHODS map_attribute
      IMPORTING
        i_value     TYPE any
        i_entity    TYPE REF TO zif_entity
        i_attribute TYPE REF TO zif_attribute
      CHANGING
        c_object    TYPE REF TO object
      RAISING
        zcx_query.
    METHODS create_table_type
      RETURNING
        VALUE(r_result) TYPE REF TO cl_abap_tabledescr.
    METHODS build_entity_fields
      RETURNING
        VALUE(r_result) TYPE string.
ENDCLASS.



CLASS zcl_query IMPLEMENTATION.

  METHOD constructor.

    me->entity_manager = i_entity_manager.
    me->entity = i_entity.
    me->parameters = i_parameters.
    me->where_string = i_where_string.
    me->fields = i_fields.
  ENDMETHOD.


  METHOD zif_query~get_parameter.
    IF i_name IS NOT INITIAL AND i_position IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    IF NOT line_exists( me->parameters[ name = i_name ] ).
      IF NOT line_exists( me->parameters[ position = i_position ] ).
        RAISE EXCEPTION TYPE zcx_query.
      ELSE.
        r_parameter = me->parameters[ position = i_position ]-parameter.
      ENDIF.
    ELSE.
      r_parameter = me->parameters[ name = i_name ]-parameter.
    ENDIF.
  ENDMETHOD.


  METHOD zif_query~get_result_list.
    r_results = execute_query(  ).
  ENDMETHOD.

  METHOD zif_query~get_single_result.
    DATA(r_results) = execute_query(  ).
    IF r_results IS INITIAL.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    IF lines( r_results ) > 1.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    r_result = r_results[ 1 ].
  ENDMETHOD.

  METHOD zif_query~set_parameter.
    DATA r_value TYPE REF TO data.
    DATA(parameter) = me->zif_query~get_parameter( i_name = i_name i_position = i_position ).
    DATA(value_type) = cl_abap_typedescr=>describe_by_data( i_value ).
    IF value_type->type_kind <> parameter->get_kind( ) AND parameter->get_kind( ) <> cl_abap_typedescr=>typekind_any.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    GET REFERENCE OF i_value INTO r_value.
    IF i_name IS NOT INITIAL.
      me->parameters[ name = i_name ]-value = r_value.
    ELSE.
      me->parameters[ position = i_position ]-value = r_value.
    ENDIF.
    .
  ENDMETHOD.


  METHOD zif_query~get_where_string.
    r_where_string = me->where_string.
  ENDMETHOD.

  METHOD execute_query.
    FIELD-SYMBOLS <results> TYPE STANDARD TABLE.
    DATA r_results TYPE REF TO data.
    DATA(table_type) = create_table_type( ).
    CREATE DATA r_results TYPE HANDLE table_type.
    ASSIGN r_results->* TO <results>.
    me->entity_manager->get_datasource( )->execute_statement(
        EXPORTING
         i_table = me->entity->zif_managed_type~get_table_type( )->get_relative_name( )
         i_fields = COND #( WHEN me->fields IS NOT INITIAL THEN me->fields ELSE build_entity_fields( ) )
         i_where = build_where( )
        IMPORTING
         e_result_set = <results>
    ).
    r_result = map_to_entities( <results> ).
  ENDMETHOD.


  METHOD build_where.
    DATA fsm TYPE REF TO zif_fsm.
    fsm = lcl_where_fsm=>create( i_query = me ).
    SPLIT me->where_string AT space INTO TABLE DATA(tokens).
    fsm = REDUCE #(
        INIT new_fsm = fsm
        FOR token IN tokens
        NEXT new_fsm = new_fsm->switch_state( token )
    ).
    r_result = CAST lcl_where_fsm( fsm )->get_result( ).
  ENDMETHOD.



  METHOD map_to_entities.
    CLEAR r_result.
    LOOP AT i_results ASSIGNING FIELD-SYMBOL(<result>).
      APPEND map_to_entity( <result> ) TO r_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD map_to_entity.
    DATA(attributes) = me->entity->zif_managed_type~get_attributes( ).
    DATA(type) = entity->zif_type~get_abap_type( ).
    DATA(type_name) = type->get_relative_name( ).
    CREATE OBJECT r_result TYPE (type_name).
    LOOP AT attributes INTO DATA(attribute).
      map_attribute(
      EXPORTING
      i_value     = i_result
      i_entity    = entity
      i_attribute = attribute
      CHANGING
            c_object    = r_result ).
    ENDLOOP.
  ENDMETHOD.


  METHOD map_attribute.

    DATA(attribute_name) = i_attribute->get_name( ).
    ASSIGN COMPONENT attribute_name OF STRUCTURE i_value TO FIELD-SYMBOL(<value>).
    IF sy-subrc EQ 0.
      TRY.
          i_attribute->mutator( )->set_value( EXPORTING i_value = <value> CHANGING c_parent_object = c_object ).
        CATCH zcx_metamodel INTO DATA(exception).
          RAISE EXCEPTION TYPE zcx_query
            EXPORTING
              previous = exception.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD zif_query~get_parameter_value.
    IF i_name IS NOT INITIAL AND i_position IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_query.
    ENDIF.
    IF i_name IS NOT INITIAL AND line_exists( me->parameters[ name = i_name ] ).
      r_value = me->parameters[ name = i_name ]-value.
      RETURN.
    ELSE.
      IF line_exists( me->parameters[ position = i_position ] ).
        r_value = me->parameters[ position = i_position ]-value.
        RETURN.
      ENDIF.
    ENDIF.
    RAISE EXCEPTION TYPE zcx_query.
  ENDMETHOD.


  METHOD create_table_type.
    r_result ?= cl_abap_tabledescr=>create( p_line_type = me->entity->zif_managed_type~get_table_type( ) ).
  ENDMETHOD.

  METHOD zif_query~get_entity.
    r_entity = me->entity.
  ENDMETHOD.


  METHOD build_entity_fields.
    DATA(attribute_names) = VALUE string_table( FOR attribute IN me->entity->zif_managed_type~get_attributes( ) ( attribute->get_name( ) ) ).
    r_result = REDUCE string(
        INIT f = ``
        FOR name IN attribute_names
        NEXT f = |{ f } { name }|
    ).
    r_result = condense( r_result ).
  ENDMETHOD.

  METHOD zif_query~get_fields.
    r_fields = me->fields.
  ENDMETHOD.

ENDCLASS.
