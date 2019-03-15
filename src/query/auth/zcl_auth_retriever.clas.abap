CLASS zcl_auth_retriever DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_auth_retriever.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS actvt_field TYPE string VALUE 'ACTVT' ##NO_TEXT.
    TYPES:
      value_tab TYPE STANDARD TABLE OF usvalues WITH DEFAULT KEY.
    METHODS find_user_authorizations
      IMPORTING
        i_object        TYPE xuobject
        i_user          TYPE sy-uname
      RETURNING
        VALUE(r_values) TYPE value_tab
      RAISING
        zcx_query_auth.
    TYPES:
      ty_selected TYPE SORTED TABLE OF xuauth WITH UNIQUE KEY table_line.
    METHODS activity_filter
      IMPORTING
        i_activity TYPE activ_auth
      CHANGING
        c_values   TYPE value_tab.
    METHODS to_profiles
      IMPORTING
        i_values                TYPE zcl_auth_retriever=>value_tab
      RETURNING
        VALUE(r_authorizations) TYPE zif_auth_profile=>tab.
ENDCLASS.



CLASS zcl_auth_retriever IMPLEMENTATION.
  METHOD zif_auth_retriever~get_authorizations.
    DATA values TYPE value_tab.
    DATA selected TYPE SORTED TABLE OF xuauth WITH UNIQUE KEY table_line.
    values = find_user_authorizations(
          i_object = i_object
          i_user   = i_user ).
    activity_filter(
      EXPORTING
        i_activity = i_activity
      CHANGING
        c_values = values ).
    r_authorizations = to_profiles( values ).
  ENDMETHOD.


  METHOD find_user_authorizations.

    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        sel_object          = i_object
        user_name           = i_user
      TABLES
        values              = r_values
      EXCEPTIONS
        user_name_not_exist = 1
        not_authorized      = 2
        internal_error      = 3.

    IF sy-subrc = 1 OR sy-subrc = 3 OR r_values IS INITIAL.
      RAISE EXCEPTION TYPE zcx_query_auth.
    ENDIF.

  ENDMETHOD.


  METHOD activity_filter.

    DATA selected TYPE ty_selected.

    IF i_activity IS NOT INITIAL.
      selected = VALUE #( FOR value IN c_values WHERE ( field = actvt_field AND ( von = i_activity OR von = '*' ) ) ( value-auth ) ).
      c_values = FILTER #( c_values IN selected WHERE auth = table_line ).
    ENDIF.

  ENDMETHOD.


  METHOD to_profiles.

    LOOP AT i_values INTO DATA(v) GROUP BY v-auth INTO DATA(profile).
      DATA(auth_profile) = NEW zcl_auth_profile( i_name = profile ).
      LOOP AT GROUP profile INTO DATA(member).
        IF member-field = actvt_field.
          auth_profile->add_activity( CONV #( member-von ) ).
        ELSE.
          auth_profile->add_value( NEW zcl_auth_value( i_field = member-field i_von = member-von i_bis = member-bis ) ).
        ENDIF.
      ENDLOOP.
      APPEND auth_profile TO r_authorizations.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
