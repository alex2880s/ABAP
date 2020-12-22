CLASS lhc_market DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Market RESULT result.

    METHODS confirm FOR MODIFY
      IMPORTING keys FOR ACTION Market~confirm RESULT result.
    METHODS validateMarket FOR VALIDATE ON SAVE
      IMPORTING keys FOR Market~validateMarket.
    METHODS validateStartDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Market~validateStartDate.
    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Market~validateEndDate.
    METHODS validateDuplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Market~validateDuplicate.

ENDCLASS.

CLASS lhc_market IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Market
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(markets)
    FAILED failed.

    result =
      VALUE #(
        FOR market IN markets
          LET is_confirmed =   COND #( WHEN market-status = 'X'
                                       THEN if_abap_behv=>fc-o-disabled
                                       ELSE if_abap_behv=>fc-o-enabled  )
          IN
            ( %tky                    = market-%tky
              %action-confirm = is_confirmed
              %assoc-_Order   = COND #( WHEN market-status = 'X'
                                        THEN if_abap_behv=>fc-o-enabled
                                        ELSE if_abap_behv=>fc-o-disabled )
             ) ).

  ENDMETHOD.

  METHOD confirm.
    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
         UPDATE
           FIELDS ( Status )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             Status = 'X' ) )
      FAILED failed
      REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(markets).

    result = VALUE #( FOR market IN markets
                        ( %tky   = market-%tky
                          %param = market ) ).
  ENDMETHOD.

  METHOD validateMarket.
     READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Mrktid ) WITH CORRESPONDING #( keys )
      RESULT DATA(markets).

    DATA market_type TYPE SORTED TABLE OF zsa_d_market WITH UNIQUE KEY mrktid.

    market_type = CORRESPONDING #( markets DISCARDING DUPLICATES MAPPING mrktid =  Mrktid   EXCEPT * ).

    DELETE market_type WHERE mrktid IS INITIAL.

    IF market_type IS NOT INITIAL.

      SELECT FROM zsa_d_market FIELDS mrktid
        FOR ALL ENTRIES IN @market_type
        WHERE mrktid = @market_type-mrktid
        INTO TABLE @DATA(market_type_db).
    ENDIF.

    LOOP AT markets INTO DATA(market).

      APPEND VALUE #(  %tky               = market-%tky
                       %state_area        = 'VALIDATE_MARKET' )
        TO reported-market.

      IF market IS INITIAL OR NOT line_exists( market_type_db[ mrktid = market-Mrktid ] ).
        APPEND VALUE #( %tky = market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = market-%tky
                        %state_area = 'VALIDATE_MARKET'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>market_dsnt_exist
                                          mrktkid = market-Mrktid )
                        %element-Mrktid = if_abap_behv=>mk-on )
          TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStartDate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Startdate ) WITH CORRESPONDING #( keys )
      RESULT DATA(markets).
    LOOP AT markets INTO DATA(market).

        APPEND VALUE #(  %tky               = market-%tky
                       %state_area        = 'VALIDATE_START_DATE' )
        TO reported-market.


        IF market IS INITIAL OR market-Startdate < sy-datum.
            APPEND VALUE #( %tky = market-%tky ) TO failed-market.

            APPEND VALUE #( %tky        = market-%tky
                        %state_area = 'VALIDATE_START_DATE'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>date_ge_today
                                          date_pref = 'Start' )
                        %element-Startdate = if_abap_behv=>mk-on )
          TO reported-market.

        ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Enddate ) WITH CORRESPONDING #( keys )
      RESULT DATA(markets).
    LOOP AT markets INTO DATA(market).

        APPEND VALUE #(  %tky               = market-%tky
                         %state_area        = 'VALIDATE_END_DATE' )
        TO reported-market.

        IF market-Enddate IS NOT INITIAL AND market-Enddate < sy-datum.
            APPEND VALUE #( %tky = market-%tky ) TO failed-market.

            APPEND VALUE #( %tky        = market-%tky
                        %state_area = 'VALIDATE_END_DATE'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>date_ge_today
                                          date_pref = 'End' )
                        %element-Enddate = if_abap_behv=>mk-on )
          TO reported-market.
        ENDIF.
        IF market-Enddate IS NOT INITIAL AND market-Enddate < market-Startdate.
            APPEND VALUE #( %tky = market-%tky ) TO failed-market.

            APPEND VALUE #( %tky        = market-%tky
                        %state_area = 'VALIDATE_END_DATE'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>enddate_gt_startdate )
                        %element-Enddate = if_abap_behv=>mk-on )
          TO reported-market.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDuplicate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Market
        FIELDS ( Mrktid ProdUuid ) WITH CORRESPONDING #( keys )
    RESULT DATA(markets).

    DATA market_exists TYPE SORTED TABLE OF zsa_d_prod_mrkt WITH UNIQUE KEY mrkt_uuid.

    market_exists = CORRESPONDING #( markets DISCARDING DUPLICATES
                                     MAPPING mrktid =  Mrktid
                                             prod_uuid = ProdUuid  EXCEPT * ).

    DELETE market_exists WHERE mrktid IS INITIAL.

    IF market_exists IS NOT INITIAL.

      SELECT FROM zsa_d_prod_mrkt FIELDS prod_uuid, mrktid
        FOR ALL ENTRIES IN @market_exists
        WHERE prod_uuid = @market_exists-prod_uuid
        INTO TABLE @DATA(market_exists_db).
    ENDIF.

    LOOP AT markets INTO DATA(market).

      APPEND VALUE #(  %tky               = market-%tky
                       %state_area        = 'VALIDATE_MARKET_ASSIGN' )
        TO reported-market.

      IF market IS INITIAL OR line_exists( market_exists_db[ mrktid = market-mrktid ] ).
        APPEND VALUE #( %tky = market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = market-%tky
                        %state_area = 'VALIDATE_MARKET_ASSIGN'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>duplicate_market )
                        %element-Mrktid = if_abap_behv=>mk-on )
          TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
