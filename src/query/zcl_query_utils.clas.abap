CLASS zcl_query_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS range_as_where
      IMPORTING
                i_selections   TYPE zif_query=>selection_tab
      RETURNING VALUE(c_where) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS selection_where
      IMPORTING
        i_selection      TYPE zif_query=>selection
      CHANGING
        c_where          TYPE string
        c_previous_field TYPE zif_query=>selection-field.
ENDCLASS.



CLASS ZCL_QUERY_UTILS IMPLEMENTATION.
  METHOD range_as_where.
    DATA(selections) = VALUE zif_query=>selection_tab( FOR s IN i_selections (
        SWITCH #( s-sign
            WHEN 'E' THEN
                VALUE #(
                    field = s-field
                    sign = 'I'
                    option = SWITCH #( s-option
                        WHEN 'EQ'
                         THEN 'NE'
                       WHEN 'NE'
                         THEN 'EQ'
                       WHEN 'BT'
                         THEN 'NB'
                       WHEN 'NB'
                         THEN 'BT'
                       WHEN 'CP'
                         THEN 'NP'
                       WHEN 'NP'
                         THEN 'CP'
                       WHEN 'LT'
                         THEN 'GE'
                       WHEN 'GE'
                         THEN 'LT'
                       WHEN 'GT'
                         THEN 'LE'
                       WHEN 'LE'
                         THEN 'GT'
                    )
                    low = s-low
                    high = s-high )
            ELSE s
        )
     ) ).
    SORT selections BY field option.
    CLEAR c_where.
    DATA where TYPE string.
    DATA previous_field TYPE zif_query=>selection-field.
    LOOP AT selections INTO DATA(selection).
      selection_where( EXPORTING i_selection = selection CHANGING c_where = where c_previous_field = previous_field ).
      c_where = COND #(  WHEN c_where IS INITIAL THEN where  ELSE |{ c_where } { where }| ).
    ENDLOOP.
    IF sy-subrc = 0.
      c_where = |{ c_where } )| .
    ENDIF.
  ENDMETHOD.


  METHOD selection_where.
    CLEAR c_where.
    data prefix type string.
    data option type string.
    IF c_previous_field <> i_selection-field
* Note 403033
    OR (     i_selection-sign      = 'I'     "= Include
         AND i_selection-option(1) = 'N' ).  "= NE, NB, NP
      IF c_previous_field IS INITIAL.
        prefix = '('.
      ELSE.
        prefix = ' ) AND ('.
      ENDIF.
    ELSE.
      prefix = 'OR'.
    ENDIF.
    c_previous_field = i_selection-field.

    CONSTANTS lc_quote TYPE string VALUE ''''.
    DATA: lr_field_low  TYPE REF TO data,
          lr_field_high TYPE REF TO data.
    FIELD-SYMBOLS: <lf_field_low>  TYPE any,
                   <lf_field_high> TYPE any.

    CREATE DATA lr_field_low TYPE c LENGTH 82. "LIKE i_selection-LOW.
    ASSIGN lr_field_low->* TO <lf_field_low>.
    <lf_field_low> = i_selection-low.
    REPLACE ALL OCCURRENCES OF lc_quote IN <lf_field_low> WITH ''''''.

    CREATE DATA lr_field_high TYPE c LENGTH 82. "LIKE i_selection-HIGH.
    ASSIGN lr_field_high->* TO <lf_field_high>.
    <lf_field_high> = i_selection-high.
    REPLACE ALL OCCURRENCES OF lc_quote IN <lf_field_high> WITH ''''''.
    data(field) = to_upper( i_selection-field ).
* Range-OPTION auswerten und als WHERE-Bedingung formulieren
    CASE i_selection-option.
      WHEN 'EQ' OR 'NE' OR 'LT' OR 'LE' OR 'GT' OR 'GE'.
        CASE i_selection-option.
          WHEN 'EQ'.
            option = ' = '''.
          WHEN 'NE'.
            option = ' <> '''.
          WHEN 'LT'.
            option = ' < '''.
          WHEN 'LE'.
            option = ' <= '''.
          WHEN 'GT'.
            option = ' > '''.
          WHEN 'GE'.
            option = ' >= '''.
          WHEN OTHERS.
            CLEAR option.
        ENDCASE.

        CONCATENATE prefix
                    field
                    INTO c_where SEPARATED BY space.
        CONCATENATE c_where
                    option
                    <lf_field_low> ''''
                    INTO c_where.
      WHEN 'BT' OR 'NB'.
        IF i_selection-option = 'NB'.
          CONCATENATE prefix
                      ' NOT'
                      INTO prefix.
        ENDIF.
        CONCATENATE prefix
                    field
                    INTO c_where SEPARATED BY space.
        CONCATENATE c_where
                    ' BETWEEN '''
                    <lf_field_low> '''' INTO c_where.
        CONCATENATE c_where
                    ' AND '''
                    <lf_field_high> ''''
                    INTO c_where.
      WHEN 'CP' OR 'NP'.
        IF i_selection-option = 'NP'.
          CONCATENATE prefix
                      ' NOT'
                      INTO prefix.
        ENDIF.
        CONCATENATE c_where
                    prefix
                    i_selection-field
                    INTO c_where SEPARATED BY space.
*   replace seach signs from ABAP with corresponding signs of DB
*   note 537230
        IF <lf_field_low> CA '#'.
          TRANSLATE <lf_field_low> USING '#&'.
          DO.
            REPLACE '&' WITH '##' INTO <lf_field_low>.
            IF NOT sy-subrc IS INITIAL.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
        IF <lf_field_low> CA '_'.
          TRANSLATE <lf_field_low> USING '_&'.
          DO.
            REPLACE '&' WITH '#_' INTO <lf_field_low>.
            IF NOT sy-subrc IS INITIAL.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
        IF <lf_field_low> CA '%'.
          TRANSLATE <lf_field_low> USING '%&'.
          DO.
            REPLACE '&' WITH '#%' INTO <lf_field_low>.
            IF NOT sy-subrc IS INITIAL.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
*note 539899
        CONCATENATE c_where
                    ' LIKE '''
                    <lf_field_low> ''''
                    INTO c_where.

*   Generische Suchzeichen im ABAP durch DB-Suchzeichen ersetzen.
*   Falls DB-Suchzeichen im String enthalten sind mÃ¼ssen diese vorher
*   maskiert werden.
*    IF c_where CA '%_#'.
*      REPLACE '#' WITH '##' INTO c_where.
*      REPLACE '%' WITH '#%' INTO c_where.
*      REPLACE '_' WITH '#_' INTO c_where.
*      CONCATENATE c_where
*                  ' ESCAPE ''' '#' ''''
*                  INTO c_where.
*    ENDIF.
*   replace seach signs from ABAP with corresponding signs of DB
        IF <lf_field_low> CA '%_#'.
          CONCATENATE c_where
                      ' ESCAPE ''' '#' ''''
                      INTO c_where.
        ENDIF.

*   '*' durch '%' und '+' durch '_' ersetzen bei generischer Suche
        TRANSLATE c_where USING '*%+_'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
