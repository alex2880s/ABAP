CLASS zsa_cl_ext_call DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS GET_EXT_PRICE_SOAP
    importing
      !ip_id type ZSA_D_PRODUCT-prodid
    exporting
      !ep_price type ZSA_D_PRODUCT-external_price.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsa_cl_ext_call IMPLEMENTATION.
  METHOD get_ext_price_soap.
     try.
        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url = 'https://soapapi.webservicespros.com/soapapi.asmx' ).

        destination->set_soap_action( i_action = 'http://tempuri.org/GetProduct'
                                      i_operation = 'GetProduct' ).

        data(proxy) = new zsc_co_soap_api_soap(
                        destination = destination
                      ).

        data(request) = value zsc_get_product_soap_in( product_id = ip_id ).



        proxy->get_product(
          exporting
            input = request
          importing
            output = data(response)
        ).

       ep_price =  response-get_product_result-list_price.

        "handle response
      catch cx_soap_destination_error.
        "handle error
      catch cx_ai_system_fault into DATA(exc).


    endtry.
  ENDMETHOD.

ENDCLASS.
