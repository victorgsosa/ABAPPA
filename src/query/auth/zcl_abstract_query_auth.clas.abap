CLASS zcl_abstract_query_auth DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PROTECTED .

  PUBLIC SECTION.
    INTERFACES zif_query_auth ABSTRACT METHODS map_field.
  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        i_object         TYPE xuobject
        i_activity       TYPE activ_auth
        i_auth_retriever TYPE REF TO zif_auth_retriever.

  PRIVATE SECTION.
    DATA object TYPE xuobject.
    DATA activity TYPE activ_auth.
    DATA auth_retriever TYPE REF TO zif_auth_retriever.
    METHODS auth_to_sql
      IMPORTING
                i_authorization      TYPE REF TO zif_auth_profile
      RETURNING VALUE(r_restriction) TYPE string.
    METHODS field_to_sql
      IMPORTING
                i_value              TYPE REF TO zif_auth_value
      RETURNING VALUE(r_restriction) TYPE string.
ENDCLASS.



CLASS zcl_abstract_query_auth IMPLEMENTATION.

  METHOD constructor.

    me->object = i_object.
    me->activity = i_activity.
    me->auth_retriever = i_auth_retriever.

  ENDMETHOD.


  METHOD zif_query_auth~get_auth_retriever.
    r_auth_retriever = me->auth_retriever.
  ENDMETHOD.


  METHOD zif_query_auth~restrict.
    DATA(authorizations) = me->zif_query_auth~get_auth_retriever( )->get_authorizations(
        i_object = me->zif_query_auth~get_object( )
        i_user = i_user
        i_activity = me->zif_query_auth~get_activity( )
    ).
    r_restriction = REDUCE #(
        INIT r = ``
        FOR authorization IN authorizations
        NEXT r = COND #( WHEN r IS INITIAL THEN auth_to_sql( authorization ) ELSE r && ` OR ` && auth_to_sql( authorization ) )
    ).
  ENDMETHOD.

  METHOD zif_query_auth~get_object.
    r_object = me->object.
  ENDMETHOD.


  METHOD auth_to_sql.
    r_restriction = REDUCE #(
       INIT r = ``
       FOR value IN i_authorization->get_values( )
       NEXT r = COND #(
        WHEN r IS INITIAL THEN field_to_sql( value )
        ELSE r && ` AND ` && field_to_sql( value  )
       )
    ).
    r_restriction = `( ` && r_restriction && ` )`.
  ENDMETHOD.


  METHOD field_to_sql.
    DATA(field) = me->zif_query_auth~map_field( i_value->get_field( ) ).
    r_restriction = COND #(
    WHEN i_value->get_bis( ) IS NOT INITIAL
    THEN field &&
        ` BETWEEN ` &&
        cl_abap_dyn_prg=>quote( i_value->get_von( ) ) &&
        ` AND ` &&
        cl_abap_dyn_prg=>quote( i_value->get_bis( ) )
     WHEN i_value->get_von( ) CS '*' OR i_value->get_von( ) CS '+'
     THEN field && ` LIKE ` && cl_abap_dyn_prg=>quote( i_value->get_von( ) )
     ELSE field && ` = ` && cl_abap_dyn_prg=>quote( i_value->get_von( ) )
     ).
    TRANSLATE r_restriction USING '*%+_'.
  ENDMETHOD.

  METHOD zif_query_auth~get_activity.
    r_activity = me->activity.
  ENDMETHOD.

ENDCLASS.
