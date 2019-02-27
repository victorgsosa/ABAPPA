CLASS zcl_transition DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces zif_transition.
    METHODS constructor
      IMPORTING
        i_pattern TYPE string
        i_next TYPE REF TO zif_state.

  PROTECTED SECTION.
  PRIVATE SECTION.
    data pattern type string.
    data next type ref to zif_state.
ENDCLASS.



CLASS zcl_transition IMPLEMENTATION.

  METHOD constructor.

    me->pattern = i_pattern.
    me->next = i_next.

  ENDMETHOD.
  METHOD zif_transition~is_possible.
    r_possible = CL_ABAP_MATCHER=>matches( pattern = me->pattern text = i_c ignore_case = abap_true ).
  ENDMETHOD.

  METHOD zif_transition~state.
    r_state = me->next.
  ENDMETHOD.

ENDCLASS.
