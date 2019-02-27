CLASS zcl_method_mutator DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_attribute_info
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_mutator.
    METHODS constructor
      IMPORTING
        i_property_class TYPE REF TO cl_abap_objectdescr
        i_member TYPE REF TO zif_method.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_method_mutator IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_property_class = i_property_class i_member = i_member ).

  ENDMETHOD.
  METHOD zif_mutator~set_value.
    DATA r_value TYPE REF TO data.
    DATA(methods) = me->get_property_class( )->methods.
    IF NOT line_exists( methods[ name = me->get_member( )->get_name( ) ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    DATA(method) = methods[ name = me->get_member( )->get_name( ) ].
    IF NOT line_exists( method-parameters[ parm_kind = cl_abap_objectdescr=>importing ] ).
      RAISE EXCEPTION TYPE zcx_metamodel.
    ENDIF.
    DATA(importing_parameter) = method-parameters[ parm_kind = cl_abap_objectdescr=>importing ].

    GET REFERENCE OF i_value INTO r_value.
    DATA(parameters) = VALUE abap_parmbind_tab( ( name = importing_parameter-name kind = cl_abap_objectdescr=>exporting value = r_value ) ).
    CAST zif_method( me->get_member( ) )->invoke(
        EXPORTING
            i_parent_object = c_parent_object
        CHANGING
         c_parameters = parameters
     ).
  ENDMETHOD.

ENDCLASS.
