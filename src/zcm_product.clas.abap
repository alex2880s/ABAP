CLASS zcm_product DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message.

     CONSTANTS:
      BEGIN OF product_group_exist,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'PGID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF product_group_exist .
     CONSTANTS:
      BEGIN OF product_id_exist,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF product_id_exist .
     CONSTANTS:
      BEGIN OF market_dsnt_exist,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'mrktkid',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF market_dsnt_exist .
      CONSTANTS:
      BEGIN OF date_ge_today,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'date_pref',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_ge_today .
      CONSTANTS:
      BEGIN OF enddate_gt_startdate,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enddate_gt_startdate .
      CONSTANTS:
      BEGIN OF duplicate_market,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF duplicate_market .
      CONSTANTS:
      BEGIN OF external_price,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF external_price .
    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous TYPE REF TO cx_root           OPTIONAL
        severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        pgid      TYPE zsa_d_prod_group-pgid    OPTIONAL
        prodid    TYPE zsa_d_product-prodid     OPTIONAL
        mrktkid   TYPE zsa_d_prod_mrkt-mrktid   OPTIONAL
        date_pref TYPE string                   OPTIONAL.
        .
    DATA pgid      TYPE string READ-ONLY.
    DATA prodid    TYPE string READ-ONLY.
    DATA mrktkid   TYPE string READ-ONLY.
    DATA date_pref TYPE string READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_product IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->pgid = pgid.
    me->prodid = prodid.
    me->mrktkid = mrktkid.
    me->date_pref = date_pref.
  ENDMETHOD.
ENDCLASS.
