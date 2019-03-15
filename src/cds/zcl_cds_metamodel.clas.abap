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
        i_type             TYPE REF TO cl_abap_typedescr
        i_name             TYPE string
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
    DATA(entity_factory) = cl_sadl_entity_factory=>get_instance( ).
    TRY.
        IF  entity_factory->entity_exists(
            EXPORTING
               iv_id  = CONV #( view_name )
               iv_type = cl_sadl_entity_factory=>co_type-cds
        ).


          view_type ?= cl_abap_structdescr=>describe_by_name( view_name ).
          DATA(entity_metadata) = cl_sadl_entity_factory=>get_instance( )->get_entity( iv_id = CONV #( view_name ) iv_type = cl_sadl_entity_factory=>co_type-cds ).
          DATA(entity) = NEW zcl_entity( i_abap_type = i_class i_table_type = view_type ).
          entity_metadata->get_elements( IMPORTING et_elements = DATA(elements) ).
          LOOP AT elements INTO DATA(element).
            TRY.
                DATA(attribute) = build_attribute_for_entity(
                      i_entity    = entity
                      i_class     = i_class
                      i_type = cl_abap_typedescr=>describe_by_name( element-data_type )
                      i_name = element-name ).
                entity->add_attribute( attribute ).
              CATCH zcx_metamodel.
            ENDTRY.

          ENDLOOP.
          r_result = entity.
        ELSE.
          RAISE EXCEPTION TYPE zcx_metamodel.
        ENDIF.
      CATCH cx_sadl_static INTO DATA(exception).
        RAISE EXCEPTION TYPE zcx_metamodel
          EXPORTING
            previous = exception.
    ENDTRY.

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

    DATA(accesor) = zcl_metadata_utils=>accesor_for( i_class = i_class i_name = i_name ).
    DATA(mutator) = zcl_metadata_utils=>mutator_for( i_class = i_class i_name = i_name ).
    r_attribute  = NEW zcl_attribute(
     i_name = i_name
     i_abap_type = i_type
     i_parent_entity = i_entity
     i_mutator = mutator
     i_accesor = accesor
    ).

  ENDMETHOD.

ENDCLASS.
