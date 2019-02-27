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
      CATCH zcx_fsm INTO DATA(exception).
        RAISE EXCEPTION TYPE zcx_query
          EXPORTING
            previous = exception.
    ENDTRY.
    DATA(result) = CAST lcl_query_fsm( fsm )->get_result( ).
    r_query = NEW zcl_query(
        i_entity_manager = me
        i_entity = result->get_entity( )
        i_parameters = result->get_parameters( )
        i_where_string = result->get_where( )
    ).
  ENDMETHOD.


ENDCLASS.
