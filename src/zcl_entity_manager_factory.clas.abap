CLASS zcl_entity_manager_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_entity_manager
        RETURNING VALUE(r_em) type ref to zif_entity_manager.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_entity_manager_factory IMPLEMENTATION.
  METHOD get_entity_manager.

  ENDMETHOD.

ENDCLASS.
