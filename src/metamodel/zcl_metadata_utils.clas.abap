CLASS zcl_metadata_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS getter_suffix TYPE string VALUE 'GET_'.
    CONSTANTS setter_suffix TYPE string VALUE 'SET_'.
    CLASS-METHODS accesor_for
      IMPORTING
                i_class          TYPE REF TO cl_abap_objectdescr
                i_name           TYPE string OPTIONAL
                i_member         TYPE REF TO zif_member OPTIONAL
      RETURNING VALUE(r_accesor) TYPE REF TO zif_accesor
      RAISING
                zcx_metamodel.
    CLASS-METHODS mutator_for
      IMPORTING
                i_class          TYPE REF TO cl_abap_objectdescr
                i_name           TYPE string OPTIONAL
                i_member         TYPE REF TO zif_member OPTIONAL
      RETURNING VALUE(r_mutator) TYPE REF TO zif_mutator
      RAISING
                zcx_metamodel.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_metadata_utils IMPLEMENTATION.
  METHOD accesor_for.
    IF i_member IS NOT INITIAL.
      IF i_member IS INSTANCE OF zif_method.
        r_accesor = NEW zcl_method_accesor( i_property_class = i_class i_member = CAST #( i_member ) ).
        RETURN.
      ENDIF.
      r_accesor = NEW zcl_field_info( i_property_class = i_class i_member = CAST #( i_member ) ).
      RETURN.
    ENDIF.
    DATA member TYPE REF TO zif_member.
    DATA(name) = to_upper( i_name ).
    IF line_exists( i_class->attributes[ name = name visibility = cl_abap_objectdescr=>public ] ).
      member = NEW zcl_field( i_parent_class = i_class i_name = name ).
      r_accesor = accesor_for( i_class = i_class i_member = member ).
      RETURN.
    ENDIF.
    IF line_exists( i_class->methods[ name = getter_suffix && name visibility = cl_abap_objectdescr=>public ] ).
      member = NEW zcl_method( i_parent_class = i_class i_name = getter_suffix && name ).
      r_accesor = accesor_for( i_class = i_class i_member = member ).
      RETURN.
    ENDIF.
    IF i_class->interfaces IS NOT INITIAL.
      LOOP AT i_class->interfaces INTO DATA(interface).
        DATA(alias) = interface-name && '~' && getter_suffix && name.
        IF line_exists( i_class->methods[ name = alias visibility = cl_abap_objectdescr=>public ] ).
          member = NEW zcl_method( i_parent_class = i_class i_name = alias ).
          r_accesor = accesor_for( i_class = i_class i_member = member ).
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDIF.
    RAISE EXCEPTION TYPE zcx_metamodel.
  ENDMETHOD.

  METHOD mutator_for.
    IF i_member IS NOT INITIAL.
      IF i_member IS INSTANCE OF zif_method.
        r_mutator = NEW zcl_method_mutator( i_property_class = i_class i_member = CAST #( i_member ) ).
        RETURN.
      ENDIF.
      r_mutator = NEW zcl_field_info( i_property_class = i_class i_member = CAST #( i_member ) ).
      RETURN.
    ENDIF.
    DATA member TYPE REF TO zif_member.
    DATA(name) = to_upper( i_name ).
    IF line_exists( i_class->attributes[ name = name visibility = cl_abap_objectdescr=>public ] ).
      member = NEW zcl_field( i_parent_class = i_class i_name = name ).
      r_mutator = mutator_for( i_class = i_class i_member = member ).
      RETURN.
    ENDIF.
    IF line_exists( i_class->methods[ name = setter_suffix && name visibility = cl_abap_objectdescr=>public ] ).
      member = NEW zcl_method( i_parent_class = i_class i_name = setter_suffix && name ).
      r_mutator = mutator_for( i_class = i_class i_member = member ).
      RETURN.
    ENDIF.
    IF i_class->interfaces IS NOT INITIAL.
      LOOP AT i_class->interfaces INTO DATA(interface).
        DATA(alias) = interface-name && '~' && setter_suffix && name.
        IF line_exists( i_class->methods[ name = alias visibility = cl_abap_objectdescr=>public ] ).
          member = NEW zcl_method( i_parent_class = i_class i_name = alias ).
          r_mutator = mutator_for( i_class = i_class i_member = member ).
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDIF.
    RAISE EXCEPTION TYPE zcx_metamodel.
  ENDMETHOD.


ENDCLASS.
