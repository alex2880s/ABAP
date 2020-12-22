CLASS lhc_MrktOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setOrderId FOR DETERMINE ON SAVE
      IMPORTING keys FOR MrktOrder~setOrderId.
    METHODS setYear FOR DETERMINE ON SAVE
      IMPORTING keys FOR MrktOrder~setYear.
    METHODS calculateAmount FOR DETERMINE ON SAVE
      IMPORTING keys FOR MrktOrder~calculateAmount.

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
           FIELDS ( Quantity ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).
    DELETE orders WHERE DeliveryDate IS INITIAL.

    CHECK orders IS NOT INITIAL.

    READ ENTITIES OF zsa_i_product IN LOCAL MODE
        ENTITY MrktOrder BY \_Product
            FIELDS ( Price Taxrate ) WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    SELECT SINGLE price, taxrate  FROM @products as prod INTO @DATA(ls_price).

    MODIFY ENTITIES OF zsa_i_product IN LOCAL MODE
   ENTITY MrktOrder
          UPDATE
            FROM VALUE #( FOR order IN orders (
              %tky                   = order-%tky
              Netamount              = order-Quantity * ls_price-Price
              Grossamount            = order-Quantity * ls_price-Price + ( order-Quantity * ls_price-Price * ls_price-taxrate / 100 )
              %control-Netamount     = if_abap_behv=>mk-on
              %control-Grossamount   = if_abap_behv=>mk-on ) )
        REPORTED DATA(update_reported).

        reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

ENDCLASS.
