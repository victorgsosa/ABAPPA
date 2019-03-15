INTERFACE zif_auth_profile
  PUBLIC .
  TYPES: tab TYPE STANDARD TABLE OF REF TO zif_auth_profile WITH DEFAULT KEY.
  TYPES activity_tab TYPE STANDARD TABLE OF activ_auth WITH DEFAULT KEY.
  METHODS get_name
    RETURNING VALUE(r_name) TYPE xuauth.
  METHODS get_activities
    RETURNING VALUE(r_activities) TYPE activity_tab.
  METHODS get_values
    RETURNING VALUE(r_values) TYPE zif_auth_value=>tab.

ENDINTERFACE.
