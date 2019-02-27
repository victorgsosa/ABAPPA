CLASS zcl_field_info DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_attribute_info
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: zif_accesor, zif_mutator.
    METHODS constructor
      IMPORTING
        i_property_class TYPE REF TO cl_abap_objectdescr
        i_member         TYPE REF TO zif_field.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS check_attribute
      RAISING
        zcx_metamodel.
ENDCLASS.



CLASS zcl_field_info IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_property_class = i_property_class i_member = i_member ).

  ENDMETHOD.
  METHOD zif_accesor~get_value.
    DATA r_value TYPE REF TO data.
    check_attribute( ).
    DATA(type) = cl_abap_typedescr=>describe_by_data( e_value ).
    IF type IS INSTANCE OF cl_abap_objectdescr.
      DATA(name) = type->get_relative_name( ).
      CREATE OBJECT e_value TYPE (name).
    ELSE.
      DATA(data_type) = CAST cl_abap_datadescr( type ).
      CREATE DATA r_value TYPE HANDLE data_type.
      assign r_value->* to FIELD-SYMBOL(<fs_value>).
      e_value = <fs_value>.
    ENDIF.
    cast zif_field( me->get_member( ) )->get(
        EXPORTING
         i_parent_object = i_parent_object
        importing
           e_value = e_value
    ).
  ENDMETHOD.

  METHOD zif_mutator~set_value.
    check_attribute( ).
    cast zif_field( me->get_member( ) )->set(
        EXPORTING
            i_value = i_value
        CHANGING
            c_parent_object = c_parent_object
    ).

  ENDMETHOD.


  METHOD check_attribute.

    DATA(attributes) = me->get_property_class( )->attributes.
    IF NOT line_exists( attributes[ name = me->get_member( )->get_name( ) visibility = cl_abap_objectdescr=>public ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
