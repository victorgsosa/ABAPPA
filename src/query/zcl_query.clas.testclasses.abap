*"* use this source file for your ABAP unit test classes
CLASS lcl_query_named_parameter DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_query PARTIALLY IMPLEMENTED.
  PRIVATE SECTION.
    DATA string1 TYPE string VALUE 's1'.
    DATA string2 TYPE string VALUE 's2'.
    DATA int TYPE i VALUE 1.
ENDCLASS.

CLASS lcl_query_named_parameter IMPLEMENTATION.


  METHOD zif_query~get_parameter_value.
    CASE i_name.
      WHEN 'string'.
        GET REFERENCE OF string1 INTO r_value.
      WHEN 'other_string'.
        GET REFERENCE OF string2 INTO r_value.
      WHEN 'int'.
        GET REFERENCE OF int INTO r_value.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_query.
    ENDCASE.
  ENDMETHOD.


ENDCLASS.


CLASS lcl_query_position_parameter DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_query PARTIALLY IMPLEMENTED.
  PRIVATE SECTION.
    DATA string1 TYPE string VALUE 's1'.
    DATA string2 TYPE string VALUE 's2'.
    DATA int TYPE i VALUE 1.
ENDCLASS.

CLASS lcl_query_position_parameter IMPLEMENTATION.


  METHOD zif_query~get_parameter_value.
    CASE i_position.
      WHEN 1.
        GET REFERENCE OF string1 INTO r_value.
      WHEN 2.
        GET REFERENCE OF string2 INTO r_value.
      WHEN 3.
        GET REFERENCE OF int INTO r_value.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_query.
    ENDCASE.
  ENDMETHOD.


ENDCLASS.


CLASS lcl_where_fsm_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_fsm_with_names FOR TESTING.
    METHODS test_fsm_with_positions FOR TESTING.
    METHODS test_fsm_with_unmarked FOR TESTING.
    METHODS test_fsm_bad_parameters FOR TESTING.
ENDCLASS.

CLASS lcl_where_fsm_test IMPLEMENTATION.

  METHOD test_fsm_with_names.
    DATA fsm TYPE REF TO zif_fsm.
    fsm = lcl_where_fsm=>create( i_query = NEW lcl_query_named_parameter( ) ).
    DATA(where) = 'string = :string and other_string = :other_string and int = :int'.
    SPLIT where AT space INTO TABLE DATA(tokens).
    fsm = REDUCE #(
        INIT new_fsm = fsm
        FOR token IN tokens
        NEXT new_fsm = new_fsm->switch_state( token )
    ).
    cl_abap_unit_assert=>assert_equals(
      act = CAST lcl_where_fsm( fsm )->get_result( )
      exp = 'string = ''s1'' and other_string = ''s2'' and int = ''1'''
      msg = 'String must be parsed'
    ).
  ENDMETHOD.

  METHOD test_fsm_with_positions.
    DATA fsm TYPE REF TO zif_fsm.
    fsm = lcl_where_fsm=>create( i_query = NEW lcl_query_position_parameter( ) ).
    DATA(where) = 'string = ?1 and other_string = ?2 and int = ?3'.
    SPLIT where AT space INTO TABLE DATA(tokens).
    fsm = REDUCE #(
        INIT new_fsm = fsm
        FOR token IN tokens
        NEXT new_fsm = new_fsm->switch_state( token )
    ).
    cl_abap_unit_assert=>assert_equals(
      act = CAST lcl_where_fsm( fsm )->get_result( )
      exp = 'string = ''s1'' and other_string = ''s2'' and int = ''1'''
      msg = 'String must be parsed'
    ).
  ENDMETHOD.

  METHOD test_fsm_with_unmarked.
    DATA fsm TYPE REF TO zif_fsm.
    fsm = lcl_where_fsm=>create( i_query = NEW lcl_query_position_parameter( ) ).
    DATA(where) = 'string = ? and other_string = ? and int = ?'.
    SPLIT where AT space INTO TABLE DATA(tokens).
    fsm = REDUCE #(
        INIT new_fsm = fsm
        FOR token IN tokens
        NEXT new_fsm = new_fsm->switch_state( token )
    ).
    cl_abap_unit_assert=>assert_equals(
      act = CAST lcl_where_fsm( fsm )->get_result( )
      exp = 'string = ''s1'' and other_string = ''s2'' and int = ''1'''
      msg = 'String must be parsed'
    ).
  ENDMETHOD.

  METHOD test_fsm_bad_parameters.
    DATA fsm TYPE REF TO zif_fsm.
    fsm = lcl_where_fsm=>create( i_query = NEW lcl_query_position_parameter( ) ).
    DATA(where) = 'string = ?1 and other_string = ? and int = ?'.
    SPLIT where AT space INTO TABLE DATA(tokens).
    TRY.
        fsm = REDUCE #(
            INIT new_fsm = fsm
            FOR token IN tokens
            NEXT new_fsm = new_fsm->switch_state( token )
        ).
      CATCH zcx_fsm.
        DATA(raised) = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( act = raised msg = 'An exception must be raised').
  ENDMETHOD.

ENDCLASS.


CLASS lcl_test_object DEFINITION FOR TESTING.
ENDCLASS.


CLASS lcl_mutator DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_mutator.
    DATA mutated_values TYPE STANDARD TABLE OF REF TO data.
ENDCLASS.

CLASS lcl_mutator IMPLEMENTATION.

  METHOD zif_mutator~set_value.
    DATA r TYPE REF TO data.
    GET REFERENCE OF i_value INTO r.
    APPEND r TO mutated_values.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_attribute DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_attribute PARTIALLY IMPLEMENTED.
    METHODS: set_mutator IMPORTING i_mutator TYPE REF TO zif_mutator,
      set_name IMPORTING i_name TYPE string.
  PRIVATE SECTION.
    DATA mutator TYPE REF TO zif_mutator.
    DATA name TYPE string.
ENDCLASS.

CLASS lcl_attribute IMPLEMENTATION.

  METHOD zif_attribute~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD zif_attribute~mutator.
    r_mutator = me->mutator.
  ENDMETHOD.

  METHOD set_mutator.
    me->mutator = i_mutator.
  ENDMETHOD.

  METHOD set_name.
    me->name = i_name.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_entity DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_entity PARTIALLY IMPLEMENTED.
    TYPES: BEGIN OF result_set,
             attribute1 TYPE string,
             attribute2 TYPE string,
             attribute3 TYPE string,
           END OF result_set.
    TYPES result_set_tab TYPE STANDARD TABLE OF result_set WITH DEFAULT KEY.
    METHODS: set_attributes IMPORTING i_attributes TYPE zif_attribute=>tab.
  PRIVATE SECTION.
    DATA attributes TYPE zif_attribute=>tab.
ENDCLASS.

CLASS lcl_entity IMPLEMENTATION.

  METHOD zif_managed_type~get_attributes.
    r_attributes = me->attributes.
  ENDMETHOD.

  METHOD set_attributes.
    me->attributes = i_attributes.
  ENDMETHOD.


  METHOD zif_managed_type~get_table_type.
    DATA table TYPE result_set.
    r_table_type ?= cl_abap_typedescr=>describe_by_data( table ).
  ENDMETHOD.

  METHOD zif_type~get_abap_type.
    DATA(object) = NEW lcl_test_object( ).
    r_type ?= cl_abap_objectdescr=>describe_by_object_ref( object ).
  ENDMETHOD.


ENDCLASS.

CLASS lcl_metamodel DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_metamodel PARTIALLY IMPLEMENTED.
    METHODS: set_entity IMPORTING i_entity TYPE REF TO zif_entity.
  PRIVATE SECTION.
    DATA entity TYPE REF TO zif_entity.
ENDCLASS.

CLASS lcl_metamodel IMPLEMENTATION.

  METHOD zif_metamodel~entity.
    r_entity = me->entity.
  ENDMETHOD.

  METHOD set_entity.
    me->entity = i_entity.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_entity_manager DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_entity_manager PARTIALLY IMPLEMENTED.
    METHODS: set_datasource IMPORTING i_datasource TYPE REF TO zif_datasource,
      set_metamodel IMPORTING i_metamodel TYPE REF TO zif_metamodel.
    CLASS-METHODS: create_query
      IMPORTING
                i_entity_manager TYPE REF TO zif_entity_manager
                i_entity         TYPE REF TO zif_entity
                i_parameters     TYPE zif_query=>parameters
                i_where_string   TYPE string
      RETURNING VALUE(r_query)   TYPE REF TO zcl_query.
  PRIVATE SECTION.
    DATA datasource TYPE REF TO zif_datasource.
    DATA metamodel TYPE REF TO zif_metamodel.
ENDCLASS.

CLASS lcl_entity_manager IMPLEMENTATION.

  METHOD zif_entity_manager~get_datasource.
    r_datasource = me->datasource.
  ENDMETHOD.

  METHOD zif_entity_manager~get_metamodel.
    r_metamodel = me->metamodel.
  ENDMETHOD.

  METHOD set_datasource.
    me->datasource = i_datasource.
  ENDMETHOD.

  METHOD set_metamodel.
    me->metamodel = i_metamodel.
  ENDMETHOD.

  METHOD create_query.
    r_query = NEW zcl_query(
        i_entity_manager = i_entity_manager
        i_entity = i_entity
        i_parameters = i_parameters
        i_where_string = i_where_string
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_datasource DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_datasource PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_datasource IMPLEMENTATION.


ENDCLASS.

CLASS lcl_multiple_datasource DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_datasource PARTIALLY IMPLEMENTED.
    DATA query TYPE string.
ENDCLASS.

CLASS lcl_multiple_datasource IMPLEMENTATION.

  METHOD zif_datasource~execute_statement.
    me->query = |SELECT { i_fields } FROM { i_table } WHERE { i_where }|.
    e_result_set = VALUE lcl_entity=>result_set_tab(
        ( attribute1 = 'par11' attribute2 = 'par21' attribute3 = 'par31')
        ( attribute1 = 'par12' attribute2 = 'par22' attribute3 = 'par32')
        ( attribute1 = 'par13' attribute2 = 'par23' attribute3 = 'par33')
    ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_single_datasource DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_datasource PARTIALLY IMPLEMENTED.
    DATA query TYPE string.
ENDCLASS.

CLASS lcl_single_datasource IMPLEMENTATION.

  METHOD zif_datasource~execute_statement.
    me->query = |SELECT { i_fields } FROM { i_table } WHERE { i_where }|.
    e_result_set = VALUE lcl_entity=>result_set_tab(
        ( attribute1 = 'par11' attribute2 = 'par21' attribute3 = 'par31')
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lcl_named_parameter DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_parameter PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_named_parameter IMPLEMENTATION.

  METHOD zif_parameter~get_name.
    r_name = 'parameter'.
  ENDMETHOD.


  METHOD zif_parameter~get_kind.
    r_type = cl_abap_typedescr=>typekind_string.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_position_parameter DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    INTERFACES zif_parameter PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_position_parameter IMPLEMENTATION.

  METHOD zif_parameter~get_position.
    r_position = 1.
  ENDMETHOD.

  METHOD zif_parameter~get_kind.
    r_type = cl_abap_typedescr=>typekind_string.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_query_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_get_parameter FOR TESTING
      RAISING
        zcx_query.
    METHODS test_set_parameter_value FOR TESTING
      RAISING
        zcx_query.
    METHODS test_get_result_list FOR TESTING
      RAISING
        zcx_query.
    METHODS test_single_result FOR TESTING
              RAISING
                zcx_query.
  PRIVATE SECTION.
    DATA query TYPE REF TO zcl_query.
    DATA em TYPE REF TO lcl_entity_manager.
    DATA metamodel TYPE REF TO lcl_metamodel.
    DATA entity TYPE REF TO lcl_entity.
    DATA attributes TYPE zif_attribute=>tab.
    DATA mutator TYPE REF TO lcl_mutator.
    DATA datasource TYPE REF TO lcl_datasource.
    METHODS setup.
ENDCLASS.

CLASS lcl_query_test IMPLEMENTATION.

  METHOD setup.
    mutator = NEW lcl_mutator( ).
    DATA(attribute1) = NEW lcl_attribute( ).
    attribute1->set_name( 'attribute1' ).
    attribute1->set_mutator( mutator ).
    DATA(attribute2) = NEW lcl_attribute( ).
    attribute2->set_name( 'attribute2' ).
    attribute2->set_mutator( mutator ).
    DATA(attribute3) = NEW lcl_attribute( ).
    attribute3->set_name( 'attribute3' ).
    attribute3->set_mutator( mutator ).
    attributes = VALUE zif_attribute=>tab( ( attribute1 ) ( attribute2 ) ( attribute3 )  ).
    entity = NEW lcl_entity( ).
    entity->set_attributes( attributes ).
    metamodel = NEW lcl_metamodel( ).
    metamodel->set_entity( entity ).
    datasource = NEW lcl_datasource( ).
    em = NEW lcl_entity_manager( ).
    em->set_metamodel( metamodel ).
    em->set_datasource( datasource ).
    DATA(parameters) = VALUE zif_query=>parameters( ( position = 1 parameter = NEW lcl_position_parameter( ) ) ).
    query = lcl_entity_manager=>create_query(
        i_entity_manager = em
        i_entity  = entity
        i_where_string = 'parameter1 = ?'
        i_parameters = parameters
    ).
  ENDMETHOD.

  METHOD test_get_parameter.
    DATA(parameter) = query->zif_query~get_parameter( i_position = 1 ).
    cl_abap_unit_assert=>assert_bound( act = parameter msg = 'parameter must exists' ).
  ENDMETHOD.

  METHOD test_get_result_list.
    DATA value TYPE string VALUE 'value'.
    data(multiple_datasource) = NEW lcl_multiple_datasource( ).
    em->set_datasource( multiple_datasource  ).
    DATA(query_multiple_results) = lcl_entity_manager=>create_query(
        i_entity_manager = em
        i_entity = entity
        i_where_string = 'parameter1 = ?'
        i_parameters = VALUE zif_query=>parameters( ( position = 1 parameter = NEW lcl_position_parameter( ) ) )
    ).
    query_multiple_results->zif_query~set_parameter( i_position = 1 i_value = value ).
    DATA(results) = query_multiple_results->zif_query~get_result_list( ).
    cl_abap_unit_assert=>assert_equals( msg = 'Must have 3 results' act = lines( results ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      msg = 'Query must have attributes and parameters'
      act = multiple_datasource->query
      exp = 'SELECT attribute1 attribute2 attribute3 FROM RESULT_SET WHERE parameter1 = ''value'''
    ).
    cl_abap_unit_assert=>assert_equals( msg = 'Nine attributes must be mutated' act = lines( mutator->mutated_values ) exp = 9 ).
  ENDMETHOD.

  METHOD test_set_parameter_value.
    DATA value TYPE string VALUE 'value'.
    query->zif_query~set_parameter( i_position = 1 i_value = value ).
    DATA(actual) = query->zif_query~get_parameter_value( i_position = 1 ).
    cl_abap_unit_assert=>assert_bound( msg = 'Value must be bound' act = actual ).
    ASSIGN actual->* TO FIELD-SYMBOL(<actual>).
    cl_abap_unit_assert=>assert_equals( msg = 'Value must be equal' exp = value act = <actual> ).
  ENDMETHOD.

  METHOD test_single_result.
    DATA value TYPE string VALUE 'value'.
    data(single_datasource) = NEW lcl_single_datasource( ).
    em->set_datasource( single_datasource  ).
    DATA(query_single_result) = lcl_entity_manager=>create_query(
        i_entity_manager = em
        i_entity = entity
        i_where_string = 'parameter1 = ?'
        i_parameters = VALUE zif_query=>parameters( ( position = 1 parameter = NEW lcl_position_parameter( ) ) )
    ).
    query_single_result->zif_query~set_parameter( i_position = 1 i_value = value ).
    DATA(result) = query_single_result->zif_query~get_single_result( ).
    cl_abap_unit_assert=>assert_bound( msg = 'Must have 1 results' act =  result ).
    cl_abap_unit_assert=>assert_equals(
      msg = 'Query must have attributes and parameters'
      act = single_datasource->query
      exp = 'SELECT attribute1 attribute2 attribute3 FROM RESULT_SET WHERE parameter1 = ''value'''
    ).
    cl_abap_unit_assert=>assert_equals( msg = 'Three attributes must be mutated' act = lines( mutator->mutated_values ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
