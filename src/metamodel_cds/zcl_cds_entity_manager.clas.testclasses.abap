*"* use this source file for your ABAP unit test classes
CLASS lcl_ddl_object_names DEFINITION FOR TESTING.
  PUBLIC SECTION.
    DATA cds_ddl TYPE string.
    DATA cds_entity TYPE string.
    METHODS: get_cds_db_view RETURNING VALUE(r_result) TYPE d,
      set_cds_db_view IMPORTING i_cds_db_view TYPE d.

  PRIVATE SECTION.
    DATA cds_db_view TYPE d.
ENDCLASS.

CLASS lcl_ddl_object_names IMPLEMENTATION.


  METHOD get_cds_db_view.
    r_result = me->cds_db_view.
  ENDMETHOD.

  METHOD set_cds_db_view.
    me->cds_db_view = i_cds_db_view.
  ENDMETHOD.

ENDCLASS.







CLASS lcl_attribute_cds_ddl DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_attribute PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_attribute_cds_ddl IMPLEMENTATION.


  METHOD zif_attribute~get_abap_type.
    r_abap_type = cl_abap_typedescr=>describe_by_name( 'STRING' ).
  ENDMETHOD.

  METHOD zif_attribute~get_name.
    r_name = 'CDS_DDL'.
  ENDMETHOD.


ENDCLASS.

CLASS lcl_attribute_cds_entity DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_attribute PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_attribute_cds_entity IMPLEMENTATION.


  METHOD zif_attribute~get_abap_type.
    r_abap_type = cl_abap_typedescr=>describe_by_name( 'STRING' ).
  ENDMETHOD.

  METHOD zif_attribute~get_name.
    r_name = 'CDS_DDL'.
  ENDMETHOD.


ENDCLASS.

CLASS lcl_attribute_cds_db_view DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_attribute PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_attribute_cds_db_view IMPLEMENTATION.


  METHOD zif_attribute~get_abap_type.
    r_abap_type = cl_abap_typedescr=>describe_by_name( 'STRING' ).
  ENDMETHOD.

  METHOD zif_attribute~get_name.
    r_name = 'CDS_DDL'.
  ENDMETHOD.


ENDCLASS.

CLASS lcl_entity DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_entity PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_entity IMPLEMENTATION.


  METHOD zif_managed_type~get_attribute.
    r_attribute = SWITCH #( i_name
        WHEN 'CDS_DDL' THEN NEW lcl_attribute_cds_ddl( )
        WHEN 'CDS_ENTITY' THEN NEW lcl_attribute_cds_entity( )
        WHEN 'CDS_DB_VIEW' THEN NEW lcl_attribute_cds_db_view( )
    ).
  ENDMETHOD.


  METHOD zif_type~get_abap_type.
    r_type ?= cl_abap_classdescr=>describe_by_name( 'LCL_DDL_OBJECT_NAMES' ).
  ENDMETHOD.


ENDCLASS.

CLASS lcl_metamodel DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_metamodel.
ENDCLASS.

CLASS lcl_metamodel IMPLEMENTATION.

  METHOD zif_metamodel~entity.
    CASE i_class->get_relative_name( ) .
      WHEN 'LCL_DDL_OBJECT_NAMES'.
        r_entity = NEW lcl_entity( ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_metamodel .
    ENDCASE.

  ENDMETHOD.



ENDCLASS.

CLASS lcl_datasource DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_datasource PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS lcl_datasource IMPLEMENTATION.

ENDCLASS.

CLASS lcl_entity_manager_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_query_creation FOR TESTING
      RAISING
        zcx_query.
    METHODS test_query_with_named_params FOR TESTING
      RAISING
        zcx_query.
    methods test_query_with_pos_params for testing
              RAISING
                zcx_query.
    methods test_query_with_unmark_params for testing
              RAISING
                zcx_query.
    METHODS test_query_creation_no_entity FOR TESTING.
  PRIVATE SECTION.
    DATA em TYPE REF TO zcl_cds_entity_manager.
    METHODS setup.
ENDCLASS.

CLASS lcl_entity_manager_test IMPLEMENTATION.

  METHOD test_query_creation.
    DATA(query) = me->em->zif_entity_manager~create_query( 'SELECT * FROM lcl_ddl_object_names').
    cl_abap_unit_assert=>assert_bound( msg = 'Query must be bound' act = query ).
    cl_abap_unit_assert=>assert_equals(
        msg = 'Query must map entity lcl_ddl_object_names'
        act = query->get_entity( )->zif_type~get_abap_type( )
        exp = cl_abap_classdescr=>describe_by_name( 'LCL_DDL_OBJECT_NAMES' )
    ).
  ENDMETHOD.

  METHOD test_query_creation_no_entity.
    TRY.
        DATA(query) = me->em->zif_entity_manager~create_query( 'SELECT * FROM i_dont_know').
      CATCH zcx_query.
        DATA(raised) = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( msg = 'An exception must be raised' act = raised ).
  ENDMETHOD.

  METHOD setup.
    me->em = NEW zcl_cds_entity_manager(
        i_datasource = NEW lcl_datasource( )
        i_metamodel = NEW lcl_metamodel( )
    ).
  ENDMETHOD.

  METHOD test_query_with_named_params.
    DATA(query) = me->em->zif_entity_manager~create_query( 'SELECT * FROM lcl_ddl_object_names WHERE cds_ddl = :cds_ddl AND cds_entity = :cds_entity').
    cl_abap_unit_assert=>assert_bound( msg = 'Query must be bound' act = query ).
    cl_abap_unit_assert=>assert_equals(
        msg = 'Query must map entity lcl_ddl_object_names'
        act = query->get_entity( )->zif_type~get_abap_type( )
        exp = cl_abap_classdescr=>describe_by_name( 'LCL_DDL_OBJECT_NAMES' )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_ddl parameters'
        act = query->get_parameter( i_name = 'CDS_DDL' )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_entity parameters'
        act = query->get_parameter( i_name = 'CDS_ENTITY' )
    ).
  ENDMETHOD.

  METHOD test_query_with_pos_params.
    DATA(query) = me->em->zif_entity_manager~create_query( 'SELECT * FROM lcl_ddl_object_names WHERE cds_ddl = ?1 AND cds_entity = ?2').
    cl_abap_unit_assert=>assert_bound( msg = 'Query must be bound' act = query ).
    cl_abap_unit_assert=>assert_equals(
        msg = 'Query must map entity lcl_ddl_object_names'
        act = query->get_entity( )->zif_type~get_abap_type( )
        exp = cl_abap_classdescr=>describe_by_name( 'LCL_DDL_OBJECT_NAMES' )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_ddl parameters'
        act = query->get_parameter( i_position = 1 )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_entity parameters'
        act = query->get_parameter( i_position = 2 )
    ).
  ENDMETHOD.

  METHOD test_query_with_unmark_params.
    DATA(query) = me->em->zif_entity_manager~create_query( 'SELECT * FROM lcl_ddl_object_names WHERE cds_ddl = ? AND cds_entity = ?').
    cl_abap_unit_assert=>assert_bound( msg = 'Query must be bound' act = query ).
    cl_abap_unit_assert=>assert_equals(
        msg = 'Query must map entity lcl_ddl_object_names'
        act = query->get_entity( )->zif_type~get_abap_type( )
        exp = cl_abap_classdescr=>describe_by_name( 'LCL_DDL_OBJECT_NAMES' )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_ddl parameters'
        act = query->get_parameter( i_position = 1 )
    ).
    cl_abap_unit_assert=>assert_bound(
        msg = 'Query must contain cds_entity parameters'
        act = query->get_parameter( i_position = 2 )
    )..
  ENDMETHOD.

ENDCLASS.
