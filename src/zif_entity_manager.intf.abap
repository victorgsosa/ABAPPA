interface ZIF_ENTITY_MANAGER
  public .
    methods get_metamodel
        RETURNING VALUE(r_metamodel) type ref to zif_metamodel.
    methods get_datasource
        RETURNING VALUE(r_datasource) type ref to zif_datasource.
    methods create_query
        importing
            i_query type string
        RETURNING VALUE(r_query) type ref to zif_query
        RAISING
          zcx_query.
endinterface.
