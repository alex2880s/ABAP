CLASS lhc_MrktOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setOrderId FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MrktOrder~setOrderId.
    METHODS setYear FOR DETERMINE ON SAVE
      IMPORTING keys FOR MrktOrder~setYear.
    METHODS calculateAmount FOR DETERMINE ON SAVE
      IMPORTING keys FOR MrktOrder~calculateAmount.
    METHODS validateDeliveryDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR MrktOrder~validateDeliveryDate.
    METHODS validateBusinessPartner FOR VALIDATE ON SAVE
      IMPORTING keys FOR MrktOrder~validateBusinessPartner.
    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR MrktOrder~validateQuantity.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MrktOrder RESULT result.

    METHODS confirmOrder FOR MODIFY
      IMPORTING keys FOR ACTION MrktOrder~confirmOrder RESULT result.
    METHODS align_cop
      IMPORTING iv_product_id TYPE zsa_product_id
                iv_quantity   TYPE zsa_quantity
      RETURNING VALUE(rs_status) TYPE if_web_http_response=>http_status .
ENDCLASS.

CLASS lhc_MrktOrder IMPLEMENTATION.

  METHOD setOrderId.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY MrktOrder
        FIELDS ( Orderid ) WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    DELETE orders WHERE Orderid IS NOT INITIAL.

    CHECK orders IS NOT INITIAL.


    SELECT SINGLE
        FROM  zsa_d_mrkt_order
        FIELDS MAX( orderid ) AS orderlID
        INTO @DATA(max_orderid).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY MrktOrder
       UPDATE
        FROM VALUE #( FOR order IN orders INDEX INTO i (
          %tky              = order-%tky
          Orderid           = max_orderid + i
          %control-Orderid  = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD setYear.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
          ENTITY MrktOrder
            FIELDS ( DeliveryDate ) WITH CORRESPONDING #( keys )
          RESULT DATA(orders).

    DELETE orders WHERE DeliveryDate IS INITIAL.

    CHECK orders IS NOT INITIAL.

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
       ENTITY MrktOrder
         UPDATE
           FROM VALUE #( FOR order IN orders (
             %tky                   = order-%tky
             CalendarYear           = order-DeliveryDate+0(4)
             %control-CalendarYear  = if_abap_behv=>mk-on ) )
       REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD calculateAmount.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY MrktOrder
           FIELDS ( Quantity DeliveryDate ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).
    DELETE orders WHERE DeliveryDate IS INITIAL.

    CHECK orders IS NOT INITIAL.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY MrktOrder BY \_Product
            FIELDS ( Price Taxrate PriceCurrency ) WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    SELECT SINGLE price, taxrate, pricecurrency FROM @products AS prod INTO @DATA(ls_price).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
   ENTITY MrktOrder
          UPDATE
            FROM VALUE #( FOR order IN orders (
              %tky                   = order-%tky
              Netamount              = order-Quantity * ls_price-Price
              Grossamount            = order-Quantity * ls_price-Price + ( order-Quantity * ls_price-Price * ls_price-taxrate / 100 )
              Amountcurr             = ls_price-pricecurrency
              %control-Netamount     = if_abap_behv=>mk-on
              %control-Grossamount   = if_abap_behv=>mk-on
              %control-Amountcurr    = if_abap_behv=>mk-on
              ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD validateDeliveryDate.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
          ENTITY MrktOrder
            FIELDS ( DeliveryDate ) WITH CORRESPONDING #( keys )
          RESULT DATA(orders).

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY MrktOrder BY \_Market
            FIELDS ( Startdate Enddate ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_markets).

    DATA(order)   = orders[ 1 ].
    DATA(ls_market) = lt_markets[ 1 ].

    IF order-DeliveryDate <= ls_market-Startdate.
      APPEND VALUE #( %tky = order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = order-%tky
                      %state_area = 'VALIDATE_ORDER'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>delivery_date_gt_st_date )
                      %path       = VALUE #( product-%is_draft = ls_market-%is_draft
                                             product-produuid  = ls_market-ProdUuid  )
                      %element-DeliveryDate = if_abap_behv=>mk-on )
        TO reported-mrktorder.
    ENDIF.
    IF ls_market-Enddate IS NOT INITIAL AND order-DeliveryDate > ls_market-Enddate.
      APPEND VALUE #( %tky = order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = order-%tky
                      %state_area = 'VALIDATE_ORDER'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>delivery_date_le_end_date )
                      %path       = VALUE #( product-%is_draft = ls_market-%is_draft
                                             product-produuid  = ls_market-ProdUuid  )
                      %element-DeliveryDate = if_abap_behv=>mk-on )
        TO reported-mrktorder.
    ENDIF.


  ENDMETHOD.

  METHOD validateBusinessPartner.

    DATA: lt_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs,
          lt_ranges            TYPE if_rap_query_filter=>tt_range_option,
          lt_business_data     TYPE TABLE OF zsa_a_businesspartner.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY MrktOrder
    FIELDS ( BusinessPartner )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

    DATA lt_busspartners TYPE SORTED TABLE OF zsa_i_busspartner_c WITH UNIQUE KEY BusinessPartner.

    lt_busspartners = CORRESPONDING #( lt_orders DISCARDING DUPLICATES MAPPING BusinessPartner = BusinessPartner EXCEPT * ).
    DELETE lt_busspartners WHERE BusinessPartner IS INITIAL.

    CHECK lt_busspartners IS NOT INITIAL.

    lt_ranges = VALUE #( FOR ls_busspartner IN lt_busspartners ( sign = 'I' option = 'EQ' low = ls_busspartner-BusinessPartner ) ).
    lt_filter_conditions = VALUE #( ( name = 'BUSINESSPARTNER' range = lt_ranges ) ).

    TRY.
        NEW zsa_cl_bp_query_provider(  )->get_business_partners(
          EXPORTING
            it_filter_conditions = lt_filter_conditions
          IMPORTING
            et_business_data     = lt_business_data ).

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_rap_query_filter_no_range
            /iwbep/cx_cp_remote
            /iwbep/cx_gateway INTO DATA(lo_exception).
        DATA(lv_exc_message) = cl_message_helper=>get_latest_t100_exception(
                                                                 lo_exception )->if_message~get_longtext( ).
    ENDTRY.

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      IF <ls_order>-BusinessPartner IS INITIAL OR NOT line_exists( lt_business_data[
                                                      businesspartner = <ls_order>-BusinessPartner ] ).
        APPEND VALUE #( %tky = <ls_order>-%tky ) TO failed-mrktorder.

        APPEND VALUE #( %tky        = <ls_order>-%tky
                        %state_area = 'VALIDATE_BUSINESS_PARTNER'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>business_partner
                                          businesspartner = <ls_order>-BusinessPartner
                                           )
                        %path       = VALUE #( product-%is_draft = <ls_order>-%is_draft
                                               product-produuid  = <ls_order>-ProdUuid  )
                        %element-businesspartner = if_abap_behv=>mk-on )
          TO reported-mrktorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateQuantity.

    DATA: ls_cop_product TYPE zsa_cl_ext_call=>mty_s_root_items.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY MrktOrder
    FIELDS ( Quantity )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders)

    ENTITY Product
    FIELDS ( Prodid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_products).

    DATA(ls_order)  = lt_orders[ 1 ].
    DATA(ls_product) = lt_products[ 1 ].


    TRY.
        ls_cop_product = zsa_cl_ext_call=>get_cop_product( ls_product-Prodid ).

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error INTO DATA(lo_exception).
        DATA(lv_exc_message) = cl_message_helper=>get_latest_t100_exception(
                                                                 lo_exception )->if_message~get_longtext( ).
    ENDTRY.

    IF ls_order-Quantity > ls_cop_product-items[ 1 ]-items[ 1 ]-quantity.
      APPEND VALUE #( %tky = ls_order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = ls_order-%tky
                      %state_area = 'VALIDATE_QUANTITY'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>quantity_issue
                                        quantity = ls_cop_product-items[ 1 ]-items[ 1 ]-quantity
                                         )
                      %path       = VALUE #( product-%is_draft = ls_order-%is_draft
                                             product-produuid  = ls_order-ProdUuid  )
                      %element-quantity = if_abap_behv=>mk-on )
        TO reported-mrktorder.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY MrktOrder
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

    result =
      VALUE #(
        FOR ls_order IN lt_orders
          LET  is_confirmed  = COND #( WHEN ls_order-Status = 'X'
                                       THEN if_abap_behv=>fc-f-read_only
                                       ELSE if_abap_behv=>fc-f-unrestricted  )
          IN
            ( %tky                         = ls_order-%tky
              %action-confirmOrder         = is_confirmed
              %field-DeliveryDate          = is_confirmed
              %field-BusinessPartner       = is_confirmed
              %field-BusinessPartnerGroup  = is_confirmed
              %field-BusinessPartnerName   = is_confirmed
              %field-Country               = is_confirmed
              %field-Locality              = is_confirmed
              %field-Street                = is_confirmed
              %field-House                 = is_confirmed
              %field-Quantity              = is_confirmed ) ).
  ENDMETHOD.

  METHOD confirmOrder.

    DATA: ls_cop_product TYPE zsa_cl_ext_call=>mty_s_root_items.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY MrktOrder
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders)

    ENTITY Product
    FIELDS ( Prodid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_products).

    DATA(ls_order) = lt_orders[ 1 ].
    DATA(ls_product) = lt_products[ 1 ].

    IF ls_order-Quantity        IS INITIAL OR
       ls_order-DeliveryDate    IS INITIAL OR
       ls_order-BusinessPartner IS INITIAL OR
       ls_order-Country         IS INITIAL OR
       ls_order-Locality        IS INITIAL OR
       ls_order-Street          IS INITIAL OR
       ls_order-House           IS INITIAL.

      APPEND VALUE #( %tky = ls_order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = ls_order-%tky
                      %state_area = 'VALIDATE_MANDATORY_FIELDS'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>order_obligatory_flds_issue
                                         )
                      %path       = VALUE #( product-%is_draft = ls_order-%is_draft
                                             product-produuid  = ls_order-ProdUuid  ) )
       TO reported-mrktorder.
       EXIT.
    ENDIF.

* Check Quantity
    TRY.
        ls_cop_product = zsa_cl_ext_call=>get_cop_product( ls_product-Prodid ).

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error INTO DATA(lo_exception).
        DATA(lv_exc_message) = cl_message_helper=>get_latest_t100_exception(
                                                                 lo_exception )->if_message~get_longtext( ).
    ENDTRY.

    IF ls_order-Quantity > ls_cop_product-items[ 1 ]-items[ 1 ]-quantity.
      APPEND VALUE #( %tky = ls_order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = ls_order-%tky
                      %state_area = 'VALIDATE_QUANTITY'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>quantity_issue
                                        quantity = ls_cop_product-items[ 1 ]-items[ 1 ]-quantity
                                         )
                      %path       = VALUE #( product-%is_draft = ls_order-%is_draft
                                             product-produuid  = ls_order-ProdUuid  )
                      %element-quantity = if_abap_behv=>mk-on )
        TO reported-mrktorder.
        EXIT.
    ENDIF.

    DATA(ls_status) = me->align_cop( iv_product_id = ls_product-Prodid
                                     iv_quantity   = ls_order-Quantity ).

    IF ls_status-code <> '201'.
      APPEND VALUE #( %tky = ls_order-%tky ) TO failed-mrktorder.

      APPEND VALUE #( %tky        = ls_order-%tky
                      %state_area = 'ALIGN_COP'
                      %msg        = NEW zcm_product(
                                        severity = if_abap_behv_message=>severity-error
                                        textid   = zcm_product=>quantity_alignment_issue
                                        reason   = ls_status-reason )
                      %path       = VALUE #( product-%is_draft = ls_order-%is_draft
                                             product-produuid  = ls_order-ProdUuid  ) )
        TO reported-mrktorder.
        EXIT.
    ENDIF.

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY MrktOrder
         UPDATE
           FIELDS ( Status )
           WITH VALUE #( FOR ls_key IN keys
                           ( %tky         = ls_key-%tky
                             Status = 'X' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY MrktOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated_orders).

    result = VALUE #( FOR ls_updated_orders IN lt_updated_orders
                    ( %tky   = ls_updated_orders-%tky
                      %param = ls_updated_orders ) ).

  ENDMETHOD.

  METHOD align_cop.

    DATA: ls_cop_product TYPE zsa_cl_ext_call=>mty_s_root_items.

    TRY.
        ls_cop_product = zsa_cl_ext_call=>get_cop_product( iv_product_id ).

        ls_cop_product-items[ 1 ]-items[ 1 ]-quantity = ls_cop_product-items[ 1 ]-items[ 1 ]-quantity - iv_quantity.

        rs_status = zsa_cl_ext_call=>update_cop_product( is_product = ls_cop_product ).

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error INTO DATA(lo_exception).
        DATA(lv_exc_message) = cl_message_helper=>get_latest_t100_exception(
                                                                 lo_exception )->if_message~get_longtext( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
