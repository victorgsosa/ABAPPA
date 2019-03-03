CLASS zcl_datasource DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_datasource.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_datasource IMPLEMENTATION.
  METHOD zif_datasource~execute_statement.
    SELECT (i_fields)
    FROM (i_table)
    INTO CORRESPONDING FIELDS OF TABLE e_result_set
    WHERE (i_where).
  ENDMETHOD.

ENDCLASS.
