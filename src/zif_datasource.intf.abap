INTERFACE zif_datasource
  PUBLIC .
  METHODS execute_statement
    IMPORTING
      i_table      TYPE string
      i_fields     TYPE string
      i_where      TYPE string
    EXPORTING
      e_result_set TYPE ANY TABLE.
ENDINTERFACE.
