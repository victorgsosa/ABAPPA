CLASS zcl_entity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_entity.
    METHODS constructor
      IMPORTING
        i_abap_type  TYPE REF TO cl_abap_objectdescr
        i_table_type TYPE REF TO cl_abap_structdescr.
    METHODS add_attribute
      IMPORTING
        i_attribute TYPE REF TO zif_attribute
      RAISING
        zcx_metamodel.
    METHODS add_association
      IMPORTING
        i_association TYPE REF TO zif_association
      RAISING
        zcx_metamodel.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF attribute,
             name      TYPE string,
             attribute TYPE REF TO zif_attribute,
           END OF attribute.
    TYPES: attribute_table TYPE HASHED TABLE OF attribute WITH UNIQUE KEY name.
    TYPES: BEGIN OF association,
             name        TYPE string,
             association TYPE REF TO zif_association,
           END OF association.
    TYPES: association_table TYPE HASHED TABLE OF association WITH UNIQUE KEY name.
    DATA abap_type TYPE REF TO cl_abap_objectdescr.
    DATA table_type TYPE REF TO cl_abap_structdescr.
    DATA attributes TYPE attribute_table.
    DATA associations TYPE association_table.
ENDCLASS.



CLASS zcl_entity IMPLEMENTATION.


  METHOD add_attribute.
    IF line_exists( me->attributes[ KEY primary_key COMPONENTS name = i_attribute->get_name( ) ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    INSERT VALUE #( name = i_attribute->get_name( ) attribute = i_attribute ) INTO TABLE me->attributes.
  ENDMETHOD.


  METHOD constructor.

    me->abap_type = i_abap_type.
    me->table_type = i_table_type.

  ENDMETHOD.


  METHOD zif_managed_type~get_association.
    DATA(name) = to_upper( i_name ).
    IF NOT line_exists( me->associations[ KEY primary_key COMPONENTS name = name ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    r_association = me->associations[ KEY primary_key COMPONENTS name = name ]-association.
  ENDMETHOD.


  METHOD zif_managed_type~get_associations.
    r_associations = VALUE zif_association=>tab( FOR association IN me->associations ( association-association ) ).
  ENDMETHOD.

  METHOD zif_managed_type~get_attribute.
    DATA(name) = to_upper( i_name ).
    IF NOT line_exists( me->attributes[ KEY primary_key COMPONENTS name = name ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    r_attribute = me->attributes[ KEY primary_key COMPONENTS name = name ]-attribute.
  ENDMETHOD.

  METHOD zif_managed_type~get_attributes.
    r_attributes = VALUE zif_attribute=>tab( FOR attribute IN me->attributes ( attribute-attribute ) ).
  ENDMETHOD.

  METHOD zif_managed_type~get_table_type.
    r_table_type = me->table_type.
  ENDMETHOD.


  METHOD zif_type~get_abap_type.
    r_type = me->abap_type.
  ENDMETHOD.

  METHOD add_association.
    IF line_exists( me->associations[ KEY primary_key COMPONENTS name = i_association->get_name( ) ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    INSERT VALUE #( name = i_association->get_name( ) association = i_association ) INTO TABLE me->associations.
  ENDMETHOD.

ENDCLASS.
