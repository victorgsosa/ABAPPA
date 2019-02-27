*"* use this source file for your ABAP unit test classes
CLASS lcl_attr_simple DEFINITION FOR TESTING.
  PUBLIC SECTION.
    DATA attr1 TYPE string.
ENDCLASS.

CLASS lcl_meth_simple DEFINITION FOR TESTING.
  PUBLIC SECTION.
    METHODS: get_attr1 RETURNING VALUE(r_result) TYPE string,
      set_attr1 IMPORTING i_attr1 TYPE string.
  PRIVATE SECTION.
    DATA attr1 TYPE string.
ENDCLASS.



CLASS lcl_meth_simple IMPLEMENTATION.

  METHOD get_attr1.
    r_result = me->attr1.
  ENDMETHOD.

  METHOD set_attr1.
    me->attr1 = i_attr1.
  ENDMETHOD.

ENDCLASS.


INTERFACE lif_attr1.
  METHODS set_attr1
    IMPORTING
      i_attr1 TYPE string.
  METHODS get_attr1
    RETURNING VALUE(r_attr1) TYPE string.
ENDINTERFACE.

CLASS lcl_interface DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES lif_attr1.
  PRIVATE SECTION.
    DATA attr1 TYPE string.
ENDCLASS.

CLASS lcl_interface IMPLEMENTATION.

  METHOD lif_attr1~get_attr1.
    r_attr1 = me->attr1.
  ENDMETHOD.

  METHOD lif_attr1~set_attr1.
    me->attr1 = i_attr1.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_attr_subclass DEFINITION INHERITING FROM lcl_attr_simple FOR TESTING.
ENDCLASS.

CLASS lcl_meth_subclass DEFINITION INHERITING FROM lcl_meth_simple FOR TESTING.
ENDCLASS.

CLASS lcl_metadata_utils_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PUBLIC SECTION.
    METHODS test_mutator_from_attribute FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_accessor_from_attribute FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_mutator_from_interface FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_accessor_from_interface FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_mutator_f_superclass_attr FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_accessor_f_superclass_att FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_mutator_from_method FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_accessor_from_method FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_mutator_f_superclass_meth FOR TESTING
      RAISING
        zcx_metamodel.
    METHODS test_accessor_f_superclass_met FOR TESTING
      RAISING
        zcx_metamodel.
ENDCLASS.

CLASS lcl_metadata_utils_test IMPLEMENTATION.

  METHOD test_accessor_from_attribute.
    DATA(entity) = NEW lcl_attr_simple( ).
    entity->attr1 = 'value'.
    DATA(accessor) = zcl_metadata_utils=>accesor_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Accessor must be set' act = accessor ).
    DATA actual_attribute TYPE string.
    accessor->get_value( EXPORTING i_parent_object = entity IMPORTING e_value = actual_attribute ).
    cl_abap_unit_assert=>assert_equals( msg = 'Accesor must retrieve value' act = actual_attribute exp = 'value' ).
  ENDMETHOD.

  METHOD test_accessor_from_interface.
    DATA(entity) = NEW lcl_interface( ).
    entity->lif_attr1~set_attr1( 'value' ).
    DATA(accessor) = zcl_metadata_utils=>accesor_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Accessor must be set' act = accessor ).
    DATA actual_attribute TYPE string.
    accessor->get_value( EXPORTING i_parent_object = entity IMPORTING e_value = actual_attribute ).
    cl_abap_unit_assert=>assert_equals( msg = 'Accesor must retrieve value' act = actual_attribute exp = 'value' ).
  ENDMETHOD.

  METHOD test_accessor_from_method.
    DATA(entity) = NEW lcl_meth_simple( ).
    entity->set_attr1( 'value' ).
    DATA(accessor) = zcl_metadata_utils=>accesor_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Accessor must be set' act = accessor ).
    DATA actual_attribute TYPE string.
    accessor->get_value( EXPORTING i_parent_object = entity IMPORTING e_value = actual_attribute ).
    cl_abap_unit_assert=>assert_equals( msg = 'Accesor must retrieve value' act = actual_attribute exp = 'value' ).
  ENDMETHOD.

  METHOD test_accessor_f_superclass_att.
    DATA(entity) = NEW lcl_attr_subclass( ).
    entity->attr1 = 'value'.
    DATA(accessor) = zcl_metadata_utils=>accesor_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Accessor must be set' act = accessor ).
    DATA actual_attribute TYPE string.
    accessor->get_value( EXPORTING i_parent_object = entity IMPORTING e_value = actual_attribute ).
    cl_abap_unit_assert=>assert_equals( msg = 'Accesor must retrieve value' act = actual_attribute exp = 'value' ).
  ENDMETHOD.

  METHOD test_accessor_f_superclass_met.
    DATA(entity) = NEW lcl_meth_subclass( ).
    entity->set_attr1( 'value' ).
    DATA(accessor) = zcl_metadata_utils=>accesor_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Accessor must be set' act = accessor ).
    DATA actual_attribute TYPE string.
    accessor->get_value( EXPORTING i_parent_object = entity IMPORTING e_value = actual_attribute ).
    cl_abap_unit_assert=>assert_equals( msg = 'Accesor must retrieve value' act = actual_attribute exp = 'value' ).
  ENDMETHOD.

  METHOD test_mutator_from_attribute.
    DATA entity TYPE REF TO object.
    entity = NEW lcl_attr_simple( ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Mutator must be set' act = mutator ).
    DATA actual_attribute TYPE string.
    mutator->set_value( EXPORTING i_value = 'value' CHANGING c_parent_object = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Mutator must change value' act = CAST lcl_attr_simple( entity )->attr1 exp = 'value' ).
  ENDMETHOD.

  METHOD test_mutator_from_interface.
    DATA entity TYPE REF TO object.
    entity = NEW lcl_interface( ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Mutator must be set' act = mutator ).
    DATA actual_attribute TYPE string.
    mutator->set_value( EXPORTING i_value = `value` CHANGING c_parent_object = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Mutator must change value' act = CAST lcl_interface( entity )->lif_attr1~get_attr1( ) exp = 'value' ).
  ENDMETHOD.

  METHOD test_mutator_from_method.
    DATA entity TYPE REF TO object.
    entity = NEW lcl_meth_simple( ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Mutator must be set' act = mutator ).
    DATA actual_attribute TYPE string.
    mutator->set_value( EXPORTING i_value = `value` CHANGING c_parent_object = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Mutator must change value' act = CAST lcl_meth_simple( entity )->get_attr1( ) exp = 'value' ).
  ENDMETHOD.

  METHOD test_mutator_f_superclass_attr.
    DATA entity TYPE REF TO object.
    entity = NEW lcl_attr_subclass( ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Mutator must be set' act = mutator ).
    DATA actual_attribute TYPE string.
    mutator->set_value( EXPORTING i_value = 'value' CHANGING c_parent_object = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Mutator must change value' act = CAST lcl_attr_subclass( entity )->attr1 exp = 'value' ).
  ENDMETHOD.

  METHOD test_mutator_f_superclass_meth.
    DATA entity TYPE REF TO object.
    entity = NEW lcl_meth_subclass( ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for(
        i_class = CAST #( cl_abap_classdescr=>describe_by_object_ref( entity ) )
        i_name = 'attr1'
    ).
    cl_abap_unit_assert=>assert_bound( msg = 'Mutator must be set' act = mutator ).
    DATA actual_attribute TYPE string.
    mutator->set_value( EXPORTING i_value = `value` CHANGING c_parent_object = entity ).
    cl_abap_unit_assert=>assert_equals( msg = 'Mutator must change value' act = CAST lcl_meth_subclass( entity )->get_attr1( ) exp = 'value' ).
  ENDMETHOD.

ENDCLASS.
