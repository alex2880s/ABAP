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
    METHODS setIsoCode FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Market~setIsoCode.

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
       FIELDS ( Mrktname ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_markets).

*    READ ENTITIES OF zsa_i_product IN LOCAL MODE
*      ENTITY Product BY \_Market
*        FROM CORRESPONDING #( lt_markets )
*      LINK DATA(lt_link_product).

    DATA lt_market_type TYPE SORTED TABLE OF zsa_d_market WITH UNIQUE KEY mrktname.

    lt_market_type = CORRESPONDING #( lt_markets DISCARDING DUPLICATES MAPPING mrktname =  Mrktname   EXCEPT * ).

    DELETE lt_market_type WHERE mrktname IS INITIAL.

    IF lt_market_type IS NOT INITIAL.

      SELECT FROM zsa_d_market FIELDS mrktname
        FOR ALL ENTRIES IN @lt_market_type
        WHERE mrktname = @lt_market_type-mrktname
        INTO TABLE @DATA(market_type_db).
    ENDIF.

    LOOP AT lt_markets INTO DATA(ls_market).
      IF ls_market-%tky-%is_draft = if_abap_behv=>mk-on.
        APPEND VALUE #(  %tky               = ls_market-%tky
                         %state_area        = 'VALIDATE_MARKET' )
          TO reported-market.
      ENDIF.

      IF ls_market IS INITIAL OR NOT line_exists( market_type_db[ mrktname = ls_market-Mrktname ] ).
        APPEND VALUE #( %tky = ls_market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = ls_market-%tky
                        %state_area = 'VALIDATE_MARKET'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>market_dsnt_exist
                                          mrktname = ls_market-Mrktname )
                        %path       = VALUE #( product-%is_draft = ls_market-%is_draft
                                               product-produuid  = ls_market-ProdUuid  )
*                        VALUE #( product-%tky = lt_link_product[ source-ProdUuid = market-ProdUuid source-%is_draft = market-%is_draft ]-target-%tky )
                        %element-Mrktname = if_abap_behv=>mk-on )
          TO reported-market.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStartDate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Startdate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_markets).


    LOOP AT lt_markets INTO DATA(ls_market).
      IF ls_market-%tky-%is_draft = if_abap_behv=>mk-on.
        APPEND VALUE #(  %tky               = ls_market-%tky
                         %state_area        = 'VALIDATE_START_DATE' )
        TO reported-market.
      ENDIF.

      IF ls_market IS INITIAL OR ls_market-Startdate < sy-datum.
        APPEND VALUE #( %tky = ls_market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = ls_market-%tky
                        %state_area = 'VALIDATE_START_DATE'
                        %msg        = NEW zcm_product(
                                                      severity = if_abap_behv_message=>severity-error
                                                      textid   = zcm_product=>date_ge_today
                                                      date_pref = 'Start' )
                        %path        = VALUE #( product-%is_draft = ls_market-%is_draft
                                                product-produuid  = ls_market-ProdUuid  )
                        %element-Startdate = if_abap_behv=>mk-on )
        TO reported-market.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Enddate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_markets).

    LOOP AT lt_markets INTO DATA(ls_market).
      IF ls_market-%tky-%is_draft = if_abap_behv=>mk-on.
        APPEND VALUE #(  %tky               = ls_market-%tky
                         %state_area        = 'VALIDATE_END_DATE' )
        TO reported-market.
      ENDIF.

      IF ls_market-Enddate IS NOT INITIAL AND ls_market-Enddate < sy-datum.
        APPEND VALUE #( %tky = ls_market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = ls_market-%tky
                    %state_area = 'VALIDATE_END_DATE'
                    %msg        = NEW zcm_product(
                                      severity = if_abap_behv_message=>severity-error
                                      textid   = zcm_product=>date_ge_today
                                      date_pref = 'End' )
                    %path       = VALUE #( product-%is_draft = ls_market-%is_draft
                                           product-produuid  = ls_market-ProdUuid  )
                    %element-Enddate = if_abap_behv=>mk-on )
      TO reported-market.
      ENDIF.
      IF ls_market-Enddate IS NOT INITIAL AND ls_market-Enddate < ls_market-Startdate.
        APPEND VALUE #( %tky = ls_market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = ls_market-%tky
                    %state_area = 'VALIDATE_END_DATE'
                    %msg        = NEW zcm_product(
                                      severity = if_abap_behv_message=>severity-error
                                      textid   = zcm_product=>enddate_gt_startdate )
                    %path       = VALUE #( product-%is_draft = ls_market-%is_draft
                                           product-produuid  = ls_market-ProdUuid  )
                    %element-Enddate = if_abap_behv=>mk-on )
      TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDuplicate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Market
        FIELDS ( Mrktid ProdUuid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_markets).

*    READ ENTITIES OF zsa_i_product IN LOCAL MODE
*    ENTITY Product BY \_Market
*      FROM CORRESPONDING #( lt_markets )
*    LINK DATA(lt_link_product).


    DATA lt_market_exists TYPE SORTED TABLE OF zsa_d_prod_mrkt WITH UNIQUE KEY mrkt_uuid.

    lt_market_exists = CORRESPONDING #( lt_markets DISCARDING DUPLICATES
                                        MAPPING mrktid =  Mrktid
                                                prod_uuid = ProdUuid  EXCEPT * ).

    DELETE lt_market_exists WHERE mrktid IS INITIAL.

    IF lt_market_exists IS NOT INITIAL.
      SELECT FROM zsa_d_prod_mrkt FIELDS prod_uuid, mrktid
        FOR ALL ENTRIES IN @lt_market_exists
        WHERE prod_uuid = @lt_market_exists-prod_uuid
        INTO TABLE @DATA(market_exists_db).
    ENDIF.

    LOOP AT lt_markets INTO DATA(ls_market).

      IF ls_market-%tky-%is_draft = if_abap_behv=>mk-on.
        APPEND VALUE #(  %tky               = ls_market-%tky
                         %state_area        = 'VALIDATE_MARKET_ASSIGN' )
          TO reported-market.
      ENDIF.

      IF ls_market IS INITIAL OR line_exists( market_exists_db[ mrktid = ls_market-mrktid ] ).
        APPEND VALUE #( %tky = ls_market-%tky ) TO failed-market.

        APPEND VALUE #( %tky        = ls_market-%tky
                        %state_area = 'VALIDATE_MARKET_ASSIGN'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>duplicate_market )
                        %path        = VALUE #( product-%is_draft = ls_market-%is_draft
                                                product-produuid  = ls_market-ProdUuid  )
*                        VALUE #( product-%tky = lt_link_product[ source-ProdUuid = market-ProdUuid source-%is_draft = market-%is_draft ]-target-%tky )
                        %element-Mrktname = if_abap_behv=>mk-on )
          TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setIsoCode.

    DATA: lv_iso_code TYPE zsa_d_prod_mrkt-iso_code.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Market
      FIELDS ( mrktname ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_markets).

    DATA(lv_mrktname) = lt_markets[ 1 ]-Mrktname.

    CHECK lv_mrktname IS NOT INITIAL.
    zsa_cl_ext_call=>get_market_iso_code(
                                         EXPORTING ip_mrktname = lv_mrktname
                                         IMPORTING ep_iso_code = lv_iso_code
                                       ).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY Market
          UPDATE
            FIELDS ( IsoCode )
            WITH VALUE #( FOR ls_market IN lt_markets
                          ( %tky         = ls_market-%tky
                            IsoCode      = lv_iso_code ) )
        REPORTED DATA(lt_update_reported).

    reported = CORRESPONDING #( DEEP lt_update_reported ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
