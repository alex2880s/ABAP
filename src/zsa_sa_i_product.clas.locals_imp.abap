CLASS lhc_product DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Product~setInitialStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Product RESULT result.

    METHODS moveToNextPhase FOR MODIFY
      IMPORTING keys FOR ACTION Product~moveToNextPhase RESULT result.
    METHODS validateProductGroup FOR VALIDATE ON SAVE
      IMPORTING keys FOR Product~validateProductGroup.
    METHODS validateProductID FOR VALIDATE ON SAVE
      IMPORTING keys FOR Product~validateProductID.
    METHODS copyProduct FOR MODIFY
      IMPORTING keys FOR ACTION Product~copyProduct RESULT result.
    METHODS setExternalPrice FOR DETERMINE ON SAVE
      IMPORTING keys FOR Product~setExternalPrice.
    METHODS validateExtID FOR VALIDATE ON SAVE
      IMPORTING keys FOR Product~validateExtID.
    METHODS setPgnameTranslation FOR DETERMINE ON SAVE
      IMPORTING keys FOR Product~setPgnameTranslation.
    METHODS getProductTransl FOR MODIFY
      IMPORTING keys FOR ACTION Product~getProductTransl RESULT result.
ENDCLASS.

CLASS lhc_product IMPLEMENTATION.

  METHOD setInitialStatus.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DELETE products WHERE Phaseid IS NOT INITIAL.
    CHECK products IS NOT INITIAL.

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Product
      UPDATE
        FIELDS ( Phaseid )
        WITH VALUE #( FOR product IN products
                      ( %tky         = product-%tky
                        Phaseid = 1 ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(products)
    FAILED failed.

    TYPES: ty_product LIKE LINE OF products.

    TYPES: BEGIN OF ty_products_avail.
             INCLUDE TYPE ty_product.
    TYPES:   avail_phaseid TYPE zsa_i_product-phaseid.
    TYPES: END OF ty_products_avail.

    DATA: lt_product_avail TYPE STANDARD TABLE OF ty_products_avail,
          ls_product_avail LIKE LINE OF lt_product_avail.


    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Product BY \_Market
      FIELDS ( Mrktid ProdUuid status Enddate ) WITH CORRESPONDING #( keys )
    RESULT DATA(markets)
    FAILED failed.

    LOOP AT products INTO ls_product_avail.


      SELECT SINGLE Mrktid, produuid FROM @markets AS market WHERE produuid = @ls_product_avail-produuid INTO @DATA(market_av).
      IF market_av IS NOT INITIAL.
        ls_product_avail-avail_phaseid = 2.
      ENDIF.
      SELECT SINGLE Mrktid, status FROM  @markets AS market WHERE status = @abap_true AND
                                                          produuid = @ls_product_avail-produuid
                                                          INTO @DATA(market_av_conf).
      IF market_av_conf IS NOT INITIAL AND ls_product_avail-avail_phaseid = 2.
        ls_product_avail-avail_phaseid = 3.

      ENDIF.
      SELECT SINGLE Mrktid, enddate FROM  @markets AS market WHERE produuid     = @ls_product_avail-produuid AND
                                                                           ( enddate  > @sy-datum OR enddate IS INITIAL )
                                                INTO @DATA(market_av_out).
      IF market_av_out IS INITIAL AND ls_product_avail-avail_phaseid = 3.
        ls_product_avail-avail_phaseid = 4.
      ENDIF.

      APPEND ls_product_avail TO lt_product_avail.
      CLEAR market_av_conf.
      CLEAR market_av.
      CLEAR market_av_out.
    ENDLOOP.

    result =
      VALUE #(
        FOR product IN lt_product_avail
          LET is_accepted =   COND #( WHEN product-Phaseid  < product-avail_phaseid
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled  )
          IN
            ( %tky                    = product-%tky
              %action-moveToNextPhase = is_accepted
              %field-Prodid           = COND #( WHEN product-Phaseid  = 1
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                WHEN product-Phaseid  > 1
                                                     THEN if_abap_behv=>fc-f-read_only )
              %field-Pgname            = COND #( WHEN product-Phaseid  = 1
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                WHEN product-Phaseid  > 1
                                                     THEN if_abap_behv=>fc-f-read_only )
              %field-Height           = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                ELSE if_abap_behv=>fc-o-enabled )
              %field-Depth             = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )
              %field-Width             = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )
              %field-SizeUom           = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )
              %field-Price             = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )
              %field-PriceCurrency     = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )
             %field-Taxrate            = COND #( WHEN product-Phaseid  = 2
                                                    THEN if_abap_behv=>fc-f-mandatory
                                                 WHEN product-Phaseid  > 2
                                                     THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-o-enabled )

             ) ).



  ENDMETHOD.

  METHOD moveToNextPhase.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
      FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_products).

    DATA(lv_phaseid) = lt_products[ 1 ]-Phaseid.

    DATA:
         lv_next_id LIKE lv_phaseid.

    IF lv_phaseid < 4.
      lv_next_id = lv_phaseid + 1.
    ENDIF.


    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY Product
           UPDATE
             FIELDS ( Phaseid )
             WITH VALUE #( FOR key IN keys
                             ( %tky         = key-%tky

                               Phaseid = lv_next_id ) )
        FAILED failed
        REPORTED reported.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    result = VALUE #( FOR product IN products
                        ( %tky   = product-%tky
                          %param = product ) ).

  ENDMETHOD.

  METHOD validateProductGroup.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Pgname ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DATA prod_group TYPE SORTED TABLE OF zsa_d_prod_group WITH UNIQUE KEY pgname.

    prod_group = CORRESPONDING #( products DISCARDING DUPLICATES MAPPING pgname =  pgname   EXCEPT * ).

    DELETE prod_group WHERE pgname IS INITIAL.

    IF prod_group IS NOT INITIAL.

      SELECT FROM zsa_d_prod_group FIELDS pgname
        FOR ALL ENTRIES IN @prod_group
        WHERE pgname = @prod_group-pgname
        INTO TABLE @DATA(prod_group_db).
    ENDIF.

    LOOP AT products INTO DATA(product).

      APPEND VALUE #(  %tky               = product-%tky
                       %state_area        = 'VALIDATE_PRODUCT_GROUP' )
        TO reported-product.

      IF product-Pgname IS INITIAL OR NOT line_exists( prod_group_db[ pgname = product-Pgname ] ).
        APPEND VALUE #( %tky = product-%tky ) TO failed-product.

        APPEND VALUE #( %tky        = product-%tky
                        %state_area = 'VALIDATE_PRODUCT_GROUP'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>product_group_exist
                                          pgname  = product-Pgname )
                        %element-pgname = if_abap_behv=>mk-on )
          TO reported-product.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateProductID.
    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Prodid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).
      APPEND VALUE #(  %tky               = product-%tky
                       %state_area        = 'VALIDATE_PRODUCT_ID' )
      TO reported-product.

      SELECT SINGLE prodid FROM zsa_c_product
          WHERE Prodid = @product-Prodid
          INTO @DATA(ex_prod).

      IF product-Prodid IS INITIAL OR ex_prod IS NOT INITIAL.
        APPEND VALUE #( %tky = product-%tky ) TO failed-product.
        APPEND VALUE #( %tky        = product-%tky
                        %state_area = 'VALIDATE_PRODUCT_ID'
                        %msg        = NEW zcm_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_product=>product_id_exist )
                    %element-Prodid = if_abap_behv=>mk-on )
      TO reported-product.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD copyProduct.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
          ALL FIELDS
           WITH CORRESPONDING #( keys )
         RESULT    DATA(lt_read_result)
         FAILED    failed
         REPORTED  reported.

    DATA(lv_today) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_user)  = cl_abap_context_info=>get_user_alias( ).
    DATA(lv_uuid)  = cl_system_uuid=>create_uuid_x16_static( ).

    DATA lt_create TYPE TABLE FOR CREATE zsa_i_product\\Product.

    LOOP AT keys INTO DATA(key).
      DATA(lv_key) = key-%param-prodid.
    ENDLOOP.

    lt_create = VALUE #( FOR row IN  lt_read_result INDEX INTO idx
                             (
                               produuid = lv_uuid
                               Width = row-Width
                               Height = row-Height
                               Depth  = row-Depth
                               Taxrate = row-Taxrate
                               SizeUom = row-SizeUom
                               Prodid  =  lv_key
                               PriceCurrency = row-PriceCurrency
                               Price  = row-Price
                               Phaseid = 1
                               Pgid = row-Pgid
                               Pgname = row-Pgname
                               ChangeTime = lv_today
                               CreationTime = lv_today
                               CreatedBy = lv_user
                               ChangedBy = lv_user ) ).


    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        CREATE FIELDS (
                         ProdUuid
                         Width
                         Height
                         Depth
                         Taxrate
                         SizeUom
                         Prodid
                         PriceCurrency
                         Price
                         Phaseid
                         Pgid
                         Pgname
                         ChangeTime
                         CreationTime
                         CreatedBy
                         ChangedBy
                         )
            WITH  lt_create
      MAPPED mapped
      FAILED failed
      REPORTED reported.


    result = VALUE #( FOR create IN  lt_create INDEX INTO indx
                             ( %cid_ref = keys[ indx ]-%cid_ref
                               %key     = keys[ indx ]-%key
                               %param   = CORRESPONDING #( create ) ) ) .

  ENDMETHOD.

  METHOD setExternalPrice.
    DATA:
         lv_extprice TYPE zsa_d_product-external_price.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Product
      FIELDS ( Prodid ) WITH CORRESPONDING #( keys )
    RESULT DATA(products).

    DATA(lv_extID) = products[ 1 ]-Prodid.

    zsa_cl_ext_call=>get_ext_price_soap(
                                         EXPORTING ip_id = lv_extID
                                         IMPORTING ep_price = lv_extprice
                                       ).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY Product
          UPDATE
            FIELDS ( ExtPrice )
            WITH VALUE #( FOR product IN products
                          ( %tky         = product-%tky
                            ExtPrice     = lv_extprice ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD validateExtID.
    TYPES:
    lty_bool TYPE c LENGTH 1.

    DATA:
        lv_ext_id_exst TYPE lty_bool.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Prodid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DATA(lv_extID) = products[ 1 ]-Prodid.
    zsa_cl_ext_call=>check_ext_id_exst(
                                        EXPORTING ip_id = lv_extID
                                        IMPORTING ep_exst = lv_ext_id_exst
                                      ).

    IF lv_ext_id_exst IS INITIAL.
      APPEND VALUE #(
                    %tky        = products[ 1 ]-%tky
                    %msg            = NEW zcm_product(
                                                      severity = if_abap_behv_message=>severity-information
                                                      textid   = zcm_product=>external_price
                                                     )
                    %element-Prodid = if_abap_behv=>mk-on
                   )
                   TO reported-product.
    ENDIF.
  ENDMETHOD.

  METHOD setPgnameTranslation.
    DATA:
         lv_pgnametr TYPE zsa_d_product-pgname_tr.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
    ENTITY Product
      FIELDS ( Pgname TransCode ) WITH CORRESPONDING #( keys )
    RESULT DATA(products).

    DATA(lv_pgname)    = products[ 1 ]-Pgname.
    DATA(lv_transcode) = products[ 1 ]-TransCode.

    zsa_cl_ext_call=>get_translate( EXPORTING
                                        ip_pgname = lv_pgname
                                        ip_trcode = lv_transcode
                                    IMPORTING
                                        ep_pgname_tr = lv_pgnametr
                                  ).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY Product
          UPDATE
            FIELDS ( PgnameTr )
            WITH VALUE #( FOR product IN products
                          ( %tky         = product-%tky
                            PgnameTr     = lv_pgnametr ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD getProductTransl.

     DATA:
         lv_pgnametr TYPE zsa_d_product-pgname_tr.

     READ ENTITIES OF zsa_i_product IN LOCAL MODE
     ENTITY Product
       FIELDS ( Pgname TransCode ) WITH CORRESPONDING #( keys )
     RESULT DATA(products).

     DATA(lv_pgname)    = products[ 1 ]-Pgname.
     DATA(lv_transcode) = products[ 1 ]-TransCode.

     SELECT code FROM zsa_d_langu INTO TABLE @DATA(lt_avail_lang).

     IF sy-subrc <> 0.
                APPEND VALUE #(
                    %tky        = products[ 1 ]-%tky
                    %msg            = NEW zcm_product(
                                                      severity   = if_abap_behv_message=>severity-error
                                                      textid     = zcm_product=>no_language_code
                                                     )
                   )
                   TO reported-product.
     ENDIF.

     LOOP AT lt_avail_lang ASSIGNING FIELD-SYMBOL(<lfs_lang>).
        CLEAR lv_pgnametr.

        CHECK <lfs_lang>-code <> lv_transcode.

        zsa_cl_ext_call=>get_translate( EXPORTING
                                        ip_pgname = lv_pgname
                                        ip_trcode = <lfs_lang>-code
                                       IMPORTING
                                        ep_pgname_tr = lv_pgnametr
                                  ).
        APPEND VALUE #(
                    %tky        = products[ 1 ]-%tky
                    %msg            = NEW zcm_product(
                                                      severity   = if_abap_behv_message=>severity-information
                                                      textid     = zcm_product=>translation_info
                                                      lang       = <lfs_lang>-code
                                                      text_trans = lv_pgnametr
                                                     )
                   )
                   TO reported-product.
     ENDLOOP.

     result = VALUE #( FOR product IN products
                        ( %tky   = product-%tky
                          %param = product ) ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
