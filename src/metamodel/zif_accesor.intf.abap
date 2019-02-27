interface ZIF_ACCESOR
  public .
    METHODS get_value
      IMPORTING
        i_parent_object TYPE REF TO object
      EXPORTING
        e_value         TYPE any
      RAISING
        zcx_metamodel.
endinterface.
