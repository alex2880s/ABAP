CLASS zsa_cl_bp_query_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: mty_t_business_partners TYPE STANDARD TABLE OF zsa_a_businesspartner.

    INTERFACES if_rap_query_provider .
    METHODS get_business_partners  IMPORTING it_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs
                                             iv_top               TYPE i OPTIONAL
                                             iv_skip              TYPE i OPTIONAL
                                             it_sort_elements     TYPE if_rap_query_request=>tt_sort_elements OPTIONAL
                                   EXPORTING et_business_data     TYPE mty_t_business_partners
                                   RAISING   cx_http_dest_provider_error
                                             cx_web_http_client_error
                                             cx_rap_query_filter_no_range
                                             /iwbep/cx_cp_remote
                                             /iwbep/cx_gateway.
  PROTECTED SECTION.
    METHODS get_client_proxy       RETURNING VALUE(io_client_proxy) TYPE REF TO /iwbep/if_cp_client_proxy
                                   RAISING   cx_http_dest_provider_error
                                             cx_web_http_client_error
                                             cx_rap_query_filter_no_range
                                             /iwbep/cx_cp_remote
                                             /iwbep/cx_gateway.
    METHODS set_filters            IMPORTING it_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs
                                   CHANGING  co_request           TYPE REF TO /iwbep/if_cp_request_read_list
                                   RAISING   cx_rap_query_filter_no_range
                                             /iwbep/cx_cp_remote
                                             /iwbep/cx_gateway.

  PRIVATE SECTION.
ENDCLASS.



CLASS zsa_cl_bp_query_provider IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA: lt_business_data    TYPE TABLE OF zsa_a_businesspartner,
          lt_business_data_ce TYPE TABLE OF zsa_i_busspartner_c.

    TRY.
        DATA(lv_top)  = io_request->get_paging(  )->get_page_size(  ).
        DATA(lv_skip) = io_request->get_paging(  )->get_offset(  ).
        DATA(lt_sort_elements) = io_request->get_sort_elements(  ).
        DATA(lt_filter_conditions) = io_request->get_filter(  )->get_as_ranges(  ).


        me->get_business_partners(
          EXPORTING
            it_filter_conditions = lt_filter_conditions
            iv_top               = CONV i( lv_top )
            iv_skip              = CONV i( lv_skip )
            it_sort_elements     = lt_sort_elements
          IMPORTING
            et_business_data     = lt_business_data
        ).

        IF lt_business_data IS NOT INITIAL.
          lt_business_data_ce = CORRESPONDING #( lt_business_data ).
        ENDIF.

        io_response->set_total_number_of_records( lines( lt_business_data_ce ) ).

        io_response->set_data( lt_business_data_ce ).

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_rap_query_filter_no_range
            /iwbep/cx_cp_remote
            /iwbep/cx_gateway INTO DATA(lo_exception).
        DATA(lv_exc_message) = cl_message_helper=>get_latest_t100_exception(
                                                                 lo_exception )->if_message~get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_client_proxy.
    DATA: lo_http_client  TYPE REF TO if_web_http_client.
    " Create http client
    " Details depend on your connection settings
    lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                              cl_http_destination_provider=>create_by_url(
                                                        i_url = 'https://my303843.s4hana.ondemand.com' ) ).

    lo_http_client->get_http_request(  )->set_authorization_basic(
                        i_username = 'POSTMAN_TEST_USER'
                        i_password = 'cZmFDcXiqJpLXEFVlKghcuNMiaYkuVamSMf~U5fQ' ).

    io_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
      EXPORTING
        iv_service_definition_name = 'ZSA_SC_BUSINESS_PARTNER'
        io_http_client             = lo_http_client
        iv_relative_service_root   = '/sap/opu/odata/sap/API_BUSINESS_PARTNER/' ).
  ENDMETHOD.

  METHOD set_filters.
    DATA: lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
          lo_root_filter_node TYPE REF TO /iwbep/if_cp_filter_node,
          lo_filter_node      TYPE REF TO /iwbep/if_cp_filter_node.
    lo_filter_factory = co_request->create_filter_factory( ).

    LOOP AT it_filter_conditions ASSIGNING FIELD-SYMBOL(<ls_filter_condition>).
      lo_filter_node = lo_filter_factory->create_by_range( iv_property_path = <ls_filter_condition>-name
                                                           it_range         = <ls_filter_condition>-range ).
      IF lo_root_filter_node IS INITIAL.
        lo_root_filter_node = lo_filter_node.
      ELSE.
        lo_root_filter_node = lo_root_filter_node->and( lo_filter_node ).
      ENDIF.
    ENDLOOP.

    IF lo_root_filter_node IS NOT INITIAL.
      co_request->set_filter( lo_root_filter_node ).
    ENDIF.
  ENDMETHOD.

  METHOD get_business_partners.

    DATA: lo_read_request      TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response          TYPE REF TO /iwbep/if_cp_response_read_lst,
          lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy,
          lt_select_properties TYPE /iwbep/if_cp_runtime_types=>ty_t_property_path,
          lt_sort_properties   TYPE /iwbep/if_cp_runtime_types=>ty_t_sort_order.

    lo_client_proxy = get_client_proxy(  ).

    lo_read_request = lo_client_proxy->create_resource_for_entity_set(
                                                        'A_BUSINESSPARTNER' )->create_request_for_read( ).

    "FILTERING
    me->set_filters( EXPORTING it_filter_conditions = it_filter_conditions
                     CHANGING  co_request           = lo_read_request ).

    "SORTING
    lt_sort_properties = CORRESPONDING #( it_sort_elements MAPPING property_path = element_name ).
    IF lt_sort_properties IS NOT INITIAL.
      lo_read_request->set_orderby( lt_sort_properties ).
    ENDIF.

    "PAGING
    IF iv_top > 0.
      lo_read_request->set_top( iv_top ).
    ENDIF.
    lo_read_request->set_skip( iv_skip ).

    lo_response = lo_read_request->execute( ).
    lo_response->get_business_data( IMPORTING et_business_data = et_business_data ).
  ENDMETHOD.

ENDCLASS.
