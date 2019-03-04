CLASS zcl_cds_metamodel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_metamodel.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF buffer_structure,
             class  TYPE REF TO cl_abap_classdescr,
             entity TYPE REF TO zif_entity,
           END OF buffer_structure.
    TYPES buffer_tab TYPE HASHED TABLE OF buffer_structure WITH UNIQUE KEY class.
    DATA buffer TYPE buffer_tab.
    METHODS build_entity
      IMPORTING
        i_class         TYPE REF TO cl_abap_classdescr
      RETURNING
        VALUE(r_result) TYPE REF TO zif_entity
      RAISING
        zcx_metamodel.
    METHODS view_name
      IMPORTING
        i_class            TYPE REF TO cl_abap_classdescr
      RETURNING
        VALUE(r_view_name) TYPE string
      RAISING
        cx_sy_regex.
    METHODS build_attribute_for_entity
      IMPORTING
        i_entity           TYPE REF TO zif_entity
        i_class            TYPE REF TO cl_abap_classdescr
        i_type             type ref to cl_abap_typedescr
        i_component        TYPE abap_compdescr
      RETURNING
        VALUE(r_attribute) TYPE REF TO zif_attribute
      RAISING
        zcx_metamodel.
ENDCLASS.



CLASS zcl_cds_metamodel IMPLEMENTATION.
  METHOD zif_metamodel~entity.
    IF NOT line_exists( me->buffer[ KEY primary_key COMPONENTS class = i_class ] ).
      DATA(entity) = build_entity( i_class ).
      INSERT VALUE buffer_structure( class = i_class entity = entity ) INTO TABLE me->buffer.
    ENDIF.
    r_entity = me->buffer[ KEY primary_key COMPONENTS class = i_class ]-entity.

  ENDMETHOD.


  METHOD build_entity.
    DATA view_type TYPE REF TO cl_abap_structdescr.
    DATA(view_name) = view_name( i_class ).

    cl_dd_ddl_utilities=>is_cds_view(
        EXPORTING
            name = CONV #( view_name )
        IMPORTING
            is_cds_view = DATA(is_cds_view)
    ).
    IF is_cds_view <> abap_true.
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.

    view_type ?= cl_abap_structdescr=>describe_by_name( view_name ).
    DATA(entity) = NEW zcl_entity( i_abap_type = i_class i_table_type = view_type ).
    LOOP AT view_type->components INTO DATA(component).
      TRY.
          DATA(attribute) = build_attribute_for_entity(
                i_entity    = entity
                i_class     = i_class
                i_type = view_type->get_component_type( component-name )
                i_component = component ).
          entity->add_attribute( attribute ).
        CATCH zcx_metamodel.
      ENDTRY.

    ENDLOOP.
    r_result = entity.

  ENDMETHOD.


  METHOD view_name.

    DATA(class_name) = i_class->get_relative_name( ).
    DATA(customer) = cl_abap_matcher=>matches( pattern = '[LZY]CL.+' text = class_name ).
    r_view_name  = COND string(
   WHEN customer = abap_true THEN class_name+4
   ELSE class_name+3
).

  ENDMETHOD.


  METHOD build_attribute_for_entity.

    DATA(accesor) = zcl_metadata_utils=>accesor_for( i_class = i_class i_name = CONV #( i_component-name ) ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for( i_class = i_class i_name = CONV #( i_component-name ) ).
    r_attribute  = NEW zcl_attribute(
     i_name = CONV #( i_component-name )
     i_abap_type = i_type
     i_parent_entity = i_entity
     i_mutator = mutator
     i_accesor = accesor
    ).

  ENDMETHOD.

ENDCLASS.
