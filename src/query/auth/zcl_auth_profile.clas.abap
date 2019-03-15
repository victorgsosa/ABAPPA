CLASS zcl_auth_profile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_auth_profile.
    METHODS constructor
      IMPORTING
        i_name     TYPE xuauth
        i_activities TYPE zif_auth_profile=>activity_tab OPTIONAL
        i_values   TYPE zif_auth_value=>tab OPTIONAL.
    METHODS add_value
      IMPORTING
        i_value TYPE REF TO zif_auth_value.
    METHODS add_activity
      IMPORTING
        i_activity TYPE activ_auth.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA name TYPE xuauth.
    DATA activities TYPE zif_auth_profile=>activity_tab.
    DATA values TYPE zif_auth_value=>tab.
ENDCLASS.



CLASS zcl_auth_profile IMPLEMENTATION.

  METHOD constructor.

    me->name = i_name.
    me->activities = i_activities.
    me->values = i_values.

  ENDMETHOD.
  METHOD zif_auth_profile~get_name.
    r_name = me->name.
  ENDMETHOD.

  METHOD zif_auth_profile~get_activities.
    r_activities = me->activities.
  ENDMETHOD.

  METHOD zif_auth_profile~get_values.
    r_values = me->values.
  ENDMETHOD.

  METHOD add_value.
    APPEND i_value TO me->values.
  ENDMETHOD.

  METHOD add_activity.
    APPEND i_activity to me->activities.
  ENDMETHOD.

ENDCLASS.
