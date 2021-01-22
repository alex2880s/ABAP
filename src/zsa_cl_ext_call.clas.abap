CLASS zsa_cl_ext_call DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF mty_s_service_config,
             url      TYPE string,
             username TYPE string,
             password TYPE string,
           END OF mty_s_service_config.
    TYPES:
        lty_bool TYPE c LENGTH 1.

    TYPES:
      BEGIN OF mty_s_items,
        availableFrom TYPE string,
        quantity      TYPE string,
      END OF mty_s_items,
      mty_t_item TYPE STANDARD TABLE OF mty_s_items WITH EMPTY KEY,

      BEGIN OF mty_s_source,
        sourceId   TYPE string,
        sourceType TYPE string,
      END OF mty_s_source,

      BEGIN OF mty_s_gen_items,
        productId    TYPE string,
        unit         TYPE string,
        calculatedAt TYPE string,
        items        TYPE mty_t_item,
        source       TYPE mty_s_source,
      END OF mty_s_gen_items,
      mty_t_item_root TYPE STANDARD TABLE OF mty_s_gen_items WITH EMPTY KEY,

      BEGIN OF mty_s_root_items,
        items TYPE  mty_t_item_root,
      END OF mty_s_root_items.

    CLASS-METHODS get_ext_price_soap
      IMPORTING
        !ip_id    TYPE zsa_d_product-prodid
      EXPORTING
        !ep_price TYPE zsa_d_product-external_price.
    CLASS-METHODS check_ext_id_exst
      IMPORTING
        !ip_id   TYPE zsa_d_product-prodid
      EXPORTING
        !ep_exst TYPE lty_bool.
    CLASS-METHODS get_market_iso_code
      IMPORTING
        !ip_mrktname TYPE zsa_d_prod_mrkt-mrkname
      EXPORTING
        !ep_iso_code TYPE zsa_d_prod_mrkt-iso_code.
    CLASS-METHODS get_translate
      IMPORTING
        !ip_pgname    TYPE zsa_d_product-pgname
        !ip_trcode    TYPE zsa_d_product-trans_code
      EXPORTING
        !ep_pgname_tr TYPE zsa_d_product-pgname_tr.
    CLASS-METHODS get_cop_product    IMPORTING iv_product_id    TYPE zsa_d_product-prodid
                                     RETURNING VALUE(rt_result) TYPE mty_s_root_items
                                     RAISING   cx_web_http_client_error
                                               cx_http_dest_provider_error.
    CLASS-METHODS update_cop_product IMPORTING is_product       TYPE mty_s_root_items
                                     RETURNING VALUE(rs_status) TYPE if_web_http_response=>http_status
                                     RAISING   cx_web_http_client_error
                                               cx_http_dest_provider_error.
  PROTECTED SECTION.
    CONSTANTS:
      BEGIN OF mc_cos_service,
        url      TYPE string VALUE 'https://b592362atrial.authentication.eu10.hana.ondemand.com/oauth/token?grant_type=client_credentials',
        username TYPE string VALUE 'sb-bff49e76-f8b8-427f-9eda-a65cafa348ca!b68033|customer-order-sourcing-trial!b20218',
        password TYPE string VALUE 'NUFr3T4PUOhvmhHJF93N1XjS2ro=',
      END   OF mc_cos_service.
    CLASS-METHODS:
      get_token  IMPORTING is_service_config TYPE mty_s_service_config
                 RETURNING VALUE(rv_token)   TYPE string
                 RAISING   cx_web_http_client_error
                           cx_http_dest_provider_error,

      get_cop_mapping RETURNING VALUE(rt_mapping) TYPE /ui2/cl_json=>name_mappings.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsa_cl_ext_call IMPLEMENTATION.
  METHOD get_ext_price_soap.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url = 'https://soapapi.webservicespros.com/soapapi.asmx' ).

        destination->set_soap_action( i_action = 'http://tempuri.org/GetProduct'
                                      i_operation = 'GetProduct' ).

        DATA(proxy) = NEW zsc_co_soap_api_soap(
                        destination = destination
                      ).

        DATA(request) = VALUE zsc_get_product_soap_in( product_id = ip_id ).



        proxy->get_product(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
        ).

        ep_price =  response-get_product_result-list_price.

        "handle response
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault INTO DATA(exc).

      CATCH cx_sy_conversion_no_number.

    ENDTRY.
  ENDMETHOD.

  METHOD check_ext_id_exst.
    DATA: ep_price TYPE zsa_d_product-external_price.

    zsa_cl_ext_call=>get_ext_price_soap(
      EXPORTING
        ip_id    = ip_id
      IMPORTING
        ep_price = ep_price
    ).

    IF ep_price IS NOT INITIAL.
      ep_exst = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD get_market_iso_code.
    TRY.

        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url = 'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso' ).

        destination->set_soap_action( i_action = ''
                                      i_operation = 'CountryISOCode' ).

        DATA(proxy) = NEW zco_country_info_service_soap(
                        destination = destination
                      ).

        DATA(request) = VALUE zcountry_isocode_soap_request( s_country_name = ip_mrktname ).
        proxy->country_isocode(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
        ).

        IF response-country_isocode_result <> 'No country found by that name'.
          ep_iso_code = response-country_isocode_result.
        ENDIF.

        "handle response
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault.
        "handle error
    ENDTRY.

  ENDMETHOD.

  METHOD get_translate.

    DATA:
      lv_url     TYPE string VALUE 'https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20210114T102124Z.02c777e90a7d0d6f.de8b18010e741b082b7a93c50796623ed13cc7fd&lang=en-',
      lv_tr_code LIKE ip_trcode.

    lv_tr_code = ip_trcode.

    TRANSLATE lv_tr_code+0(2) TO LOWER CASE.

    CONCATENATE lv_url lv_tr_code '&text=' ip_pgname INTO lv_url.

    REPLACE ALL OCCURRENCES OF  ` ` IN lv_url WITH '%20'.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                    cl_http_destination_provider=>create_by_url(
                    i_url = lv_url ) ).

        DATA(lo_request) = lo_http_client->get_http_request( ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).

        TYPES:
          BEGIN OF ls_tr,
            text TYPE string,
            pos  TYPE string,
          END OF ls_tr,
          lt_tr_table TYPE STANDARD TABLE OF ls_tr WITH EMPTY KEY,
          BEGIN OF ls_def,
            text TYPE string,
            pos  TYPE string,
            ts   TYPE string,
            tr   TYPE lt_tr_table,
          END OF ls_def.

        TYPES lt_result_table TYPE
          STANDARD TABLE OF ls_def
            WITH EMPTY KEY.

        TYPES:
          BEGIN OF ls_complete_result_structure,
            head TYPE string,
            def  TYPE lt_result_table,
          END OF ls_complete_result_structure.

        DATA: ls_json TYPE ls_complete_result_structure.


        CALL METHOD /ui2/cl_json=>deserialize
          EXPORTING
            json         = lo_response->get_text( )
            pretty_name  = /ui2/cl_json=>pretty_mode-camel_case
            assoc_arrays = abap_true
          CHANGING
            data         = ls_json.

        CHECK ls_json IS NOT INITIAL.

        ep_pgname_tr  = ls_json-def[ 1 ]-tr[ 1 ]-text.

        TRANSLATE ep_pgname_tr+0(1) TO UPPER CASE.

      CATCH cx_web_http_client_error cx_http_dest_provider_error.
        "handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD get_token.
    TYPES: BEGIN OF lty_s_token_json,
             access_token TYPE string,
           END OF lty_s_token_json.

    DATA: lv_token      TYPE string,
          ls_token_json TYPE lty_s_token_json.

    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
          cl_http_destination_provider=>create_by_url(
          i_url = is_service_config-url ) ).

    lo_http_client->get_http_request(  )->set_authorization_basic(
                   i_username = is_service_config-username
                   i_password = is_service_config-password ).

    DATA(lo_request)  = lo_http_client->get_http_request( ).
    DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = lo_response->get_text( )
        pretty_name  = /ui2/cl_json=>pretty_mode-camel_case
        assoc_arrays = abap_true
      CHANGING
        data         = ls_token_json ).

    rv_token = ls_token_json-access_token.
  ENDMETHOD.

  METHOD get_cop_product.

    CLEAR rt_result.

    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
             cl_http_destination_provider=>create_by_url(
             i_url = 'https://cpfs-dtrt-trial.cfapps.eu10.hana.ondemand.com/v1/availabilityRawData?productId=' && iv_product_id ) ).

    DATA(lv_token) = get_token( is_service_config = mc_cos_service ).
    lo_http_client->get_http_request(  )->set_authorization_bearer( i_bearer = lv_token ).

    DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = lo_response->get_text( )
        pretty_name  = /ui2/cl_json=>pretty_mode-low_case
        assoc_arrays = abap_true
      CHANGING
        data         = rt_result ).

  ENDMETHOD.

  METHOD update_cop_product.

    DATA: lt_products TYPE STANDARD TABLE OF mty_s_gen_items.

    lt_products = is_product-items.

    /ui2/cl_json=>serialize(
      EXPORTING
        data             = lt_products
        assoc_arrays     = abap_true
        pretty_name      = /ui2/cl_json=>pretty_mode-low_case
        name_mappings    = get_cop_mapping(  )
      RECEIVING
        r_json           = DATA(lv_json) ).

    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
             cl_http_destination_provider=>create_by_url(
             i_url = 'https://cpfs-dtrt-trial.cfapps.eu10.hana.ondemand.com/v1/availabilityRawData' ) ).

    DATA(lv_token) = get_token( is_service_config = mc_cos_service ).
    DATA(lo_request) = lo_http_client->get_http_request(  ).

    lo_request->set_authorization_bearer( i_bearer = lv_token ).
    lo_request->set_text( i_text   = lv_json
                          i_length = strlen( lv_json )  ).

    lo_request->set_header_field( i_name  = 'content-type'
                                  i_value = 'application/json').

    DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).

    rs_status = lo_response->get_status(  ).

  ENDMETHOD.

  METHOD get_cop_mapping.

    CLEAR rt_mapping.

    rt_mapping = VALUE #( ( abap = 'productid'
                          json = 'productId' )
                        ( abap = 'calculatedat'
                          json = 'calculatedAt' )
                        ( abap = 'availablefrom'
                          json = 'availableFrom' )
                        ( abap = 'sourceid'
                          json = 'sourceId' )
                        ( abap = 'sourceType'
                          json = 'sourceType' ) ).
  ENDMETHOD.
ENDCLASS.
