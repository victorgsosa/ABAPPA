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


CLASS lcl_cds_metamodel_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_entity_metamodel FOR TESTING
      RAISING
        zcx_metamodel.
ENDCLASS.

CLASS lcl_cds_metamodel_test IMPLEMENTATION.

  METHOD test_entity_metamodel.

    DATA(metamodel) = NEW zcl_cds_metamodel( ).
    DATA(entity) = metamodel->zif_metamodel~entity( CAST #( cl_abap_objectdescr=>describe_by_name( 'lcl_ddl_object_names' ) ) ).
    cl_abap_unit_assert=>assert_bound( msg = 'Entity must be bound' act = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Entity must have 3 attributes' act = lines( entity->zif_managed_type~get_attributes( ) ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
        msg = 'Name cds_ddl must be a string'
        act = entity->zif_managed_type~get_attribute( 'CDS_DDL' )->get_abap_type( )->get_relative_name( )
        exp = 'DDLNAME'
    ).
  ENDMETHOD.

ENDCLASS.
