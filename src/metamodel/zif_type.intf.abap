interface ZIF_TYPE
  public .
    methods get_abap_type
        RETURNING VALUE(r_type) type ref to cl_abap_objectdescr.
endinterface.
