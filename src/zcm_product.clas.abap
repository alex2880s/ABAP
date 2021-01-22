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
        attr1 TYPE scx_attrname VALUE 'PGNAME',
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
        attr1 TYPE scx_attrname VALUE 'mrktkname',
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
    CONSTANTS:
      BEGIN OF delivery_date_gt_st_date,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_gt_st_date .
    CONSTANTS:
      BEGIN OF delivery_date_le_end_date,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_le_end_date .
    CONSTANTS:
      BEGIN OF business_partner,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'businesspartner',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF business_partner ,

      BEGIN OF quantity_issue,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'quantity',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF quantity_issue,

      BEGIN OF order_obligatory_flds_issue,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF  order_obligatory_flds_issue,


      BEGIN OF quantity_alignment_issue,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '013',
        attr1 TYPE scx_attrname VALUE 'reason',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF  quantity_alignment_issue,

      BEGIN OF translation_info,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '014',
        attr1 TYPE scx_attrname VALUE 'lang',
        attr2 TYPE scx_attrname VALUE 'text_trans',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF  translation_info,

      BEGIN OF no_language_code,
        msgid TYPE symsgid VALUE 'ZSA_MC_PRODUCT',
        msgno TYPE symsgno VALUE '015',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF  no_language_code.


    METHODS constructor
      IMPORTING
        !textid         LIKE if_t100_message=>t100key     OPTIONAL
        !previous       TYPE REF TO cx_root               OPTIONAL
        severity        TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        pgname          TYPE zsa_d_prod_group-pgname      OPTIONAL
        prodid          TYPE zsa_d_product-prodid         OPTIONAL
        mrktname        TYPE zsa_d_prod_mrkt-mrkname      OPTIONAL
        date_pref       TYPE string OPTIONAL
        businesspartner TYPE zsa_d_mrkt_order-busspartner OPTIONAL
        quantity        TYPE string    OPTIONAL
        reason          TYPE string    OPTIONAL
        lang            TYPE zsa_langu_code OPTIONAL
        text_trans      TYPE zsa_pg_name    OPTIONAL.

    DATA pgname     TYPE string READ-ONLY.
    DATA prodid     TYPE string READ-ONLY.
    DATA mrktkname  TYPE string READ-ONLY.
    DATA date_pref  TYPE string READ-ONLY.
    DATA quantity   TYPE string READ-ONLY.
    DATA businesspartner TYPE string READ-ONLY.
    DATA reason     TYPE string READ-ONLY.
    DATA lang       TYPE zsa_langu_code  READ-ONLY.
    DATA text_trans TYPE zsa_pg_name     READ-ONLY.

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
    me->pgname = pgname.
    me->prodid = prodid.
    me->mrktkname = mrktkname.
    me->date_pref = date_pref.
    me->businesspartner = businesspartner.
    me->quantity         = quantity.
    me->reason           = reason.
    me->text_trans       = text_trans.
    me->lang             = lang.
  ENDMETHOD.
ENDCLASS.
