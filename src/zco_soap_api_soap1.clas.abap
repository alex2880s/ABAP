class ZCO_SOAP_API_SOAP1 definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods ADD_PRODUCT
    importing
      !INPUT type ZADD_PRODUCT_SOAP_IN1
    exporting
      !OUTPUT type ZADD_PRODUCT_SOAP_OUT1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods DELETE_PRODUCT
    importing
      !INPUT type ZDELETE_PRODUCT_SOAP_IN1
    exporting
      !OUTPUT type ZDELETE_PRODUCT_SOAP_OUT1
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_PRODUCT
    importing
      !INPUT type ZGET_PRODUCT_SOAP_IN1
    exporting
      !OUTPUT type ZGET_PRODUCT_SOAP_OUT1
    raising
      CX_AI_SYSTEM_FAULT .
  methods UPDATE_PRODUCT
    importing
      !INPUT type ZUPDATE_PRODUCT_SOAP_IN1
    exporting
      !OUTPUT type ZUPDATE_PRODUCT_SOAP_OUT1
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_SOAP_API_SOAP1 IMPLEMENTATION.


  method ADD_PRODUCT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'ADD_PRODUCT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_SOAP_API_SOAP1'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method DELETE_PRODUCT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'DELETE_PRODUCT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GET_PRODUCT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'GET_PRODUCT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method UPDATE_PRODUCT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'UPDATE_PRODUCT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
