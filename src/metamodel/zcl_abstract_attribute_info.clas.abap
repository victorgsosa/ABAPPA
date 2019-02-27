CLASS zcl_abstract_attribute_info DEFINITION
  PUBLIC
  abstract
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_property_class TYPE REF TO cl_abap_objectdescr
        i_member TYPE REF TO zif_member.
    METHODS: get_property_class RETURNING value(r_result) TYPE REF TO cl_abap_objectdescr,
             get_member RETURNING value(r_result) TYPE REF TO zif_member.
  PROTECTED SECTION.
  PRIVATE SECTION.
    data property_class type ref to cl_abap_objectdescr.
    data member type ref to zif_member.

ENDCLASS.



CLASS zcl_abstract_attribute_info IMPLEMENTATION.

  METHOD constructor.

    me->property_class = i_property_class.
    me->member = i_member.

  ENDMETHOD.
  METHOD get_property_class.
    r_result = me->property_class.
  ENDMETHOD.

  METHOD get_member.
    r_result = me->member.
  ENDMETHOD.

ENDCLASS.
