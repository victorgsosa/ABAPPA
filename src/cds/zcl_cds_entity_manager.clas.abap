CLASS zcl_cds_entity_manager DEFINITION
  PUBLIC
  INHERITING FROM zcl_abstract_entity_manager
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: zif_entity_manager~create_query REDEFINITION.
    METHODS constructor
      IMPORTING
        i_datasource TYPE REF TO zif_datasource
        i_metamodel  TYPE REF TO zif_metamodel.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cds_entity_manager IMPLEMENTATION.

  METHOD constructor.

    super->constructor( i_datasource = i_datasource i_metamodel = i_metamodel ).

  ENDMETHOD.

  METHOD zif_entity_manager~create_query.
    DATA exception TYPE REF TO cx_root.
    DATA fsm TYPE REF TO zif_fsm.
    CLEAR r_query.
    fsm = lcl_query_fsm=>create( i_em = me ).
    SPLIT to_upper( i_query ) AT space INTO TABLE DATA(tokens).
    TRY.
        fsm = REDUCE #(
            INIT new_fsm = fsm
            FOR token IN tokens
            NEXT new_fsm = new_fsm->switch_state( token )
        ).
      CATCH zcx_fsm INTO exception.
        RAISE EXCEPTION TYPE zcx_query
          EXPORTING
            previous = exception.
    ENDTRY.

    DATA(result) = CAST lcl_query_fsm( fsm )->get_result( ).
    DATA(where) = COND #(
    WHEN i_selections IS NOT INITIAL THEN |( { result->get_where( ) } ) AND ( { zcl_query_utils=>range_as_where( i_selections = i_selections ) } )|
    ELSE result->get_where( )
    ).
    IF i_authorizations IS NOT INITIAL.
      DATA(authorization_where) = REDUCE string(
          INIT r = ``
          FOR authorization IN i_authorizations
          NEXT r =  r && ` AND ( ` && authorization->restrict( ) && ` )`
      ).
      where = where && authorization_where.
    ENDIF.
    r_query = NEW zcl_query(
        i_entity_manager = me
        i_entity = result->get_entity( )
        i_parameters = result->get_parameters( )
        i_where_string = where
        i_fields = result->get_fields( )
    ).
  ENDMETHOD.



ENDCLASS.
