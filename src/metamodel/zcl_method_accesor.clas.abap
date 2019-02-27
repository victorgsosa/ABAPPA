CLASS zcl_method_accesor DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_attribute_info
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_accesor.
    METHODS constructor
      IMPORTING
        i_property_class TYPE REF TO cl_abap_objectdescr
        i_member         TYPE REF TO zif_method.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_method_accesor IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_property_class = i_property_class i_member = i_member ).

  ENDMETHOD.
  METHOD zif_accesor~get_value.
    DATA r_value TYPE REF TO data.
    DATA(methods) = me->get_property_class( )->methods.
    IF NOT line_exists( methods[ name = me->get_member( )->get_name( ) ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    DATA(method) = methods[ name = me->get_member( )->get_name( ) ].
    IF NOT line_exists( method-parameters[ parm_kind = cl_abap_objectdescr=>returning ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    DATA(returning_parameter) = method-parameters[ parm_kind = cl_abap_objectdescr=>returning ].
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
    GET REFERENCE OF e_value INTO r_value.
    DATA(parameters) = VALUE abap_parmbind_tab( ( name = returning_parameter-name kind = cl_abap_objectdescr=>receiving value = r_value ) ).
    CAST zif_method( me->get_member( ) )->invoke(
        EXPORTING
            i_parent_object = i_parent_object
        CHANGING
         c_parameters = parameters
     ).
  ENDMETHOD.

ENDCLASS.
