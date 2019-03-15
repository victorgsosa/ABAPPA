INTERFACE zif_auth_retriever
  PUBLIC .
  METHODS get_authorizations
    IMPORTING
              i_object                TYPE xuobject
              i_user                  TYPE sy-uname DEFAULT sy-uname
              i_activity              TYPE activ_auth OPTIONAL
    RETURNING VALUE(r_authorizations) TYPE zif_auth_profile=>tab
    RAISING
      zcx_query_auth.
ENDINTERFACE.
