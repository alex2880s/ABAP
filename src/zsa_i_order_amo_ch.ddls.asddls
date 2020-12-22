@AbapCatalog.sqlViewName: 'ZSA_AM_CH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order amount chart'

@UI.chart: [{
    title:       'Quantity by orders',
    description: 'Line-chart displaying the gross amount by customer',
    chartType:    #BAR,
    dimensions:   [ 'DeliveryDate' ], 
    measures:     [ 'Netamount', 'Grossamount' ] 
}]

define view ZSA_I_ORDER_AMO_CH as select from zsa_d_mrkt_order {
    
    key prod_uuid     as ProdUuid,
    key mrkt_uuid     as MrktUuid,
    key order_uuid    as OrderUuid,
        orderid       as Orderid,
        delivery_date as DeliveryDate,
        @Aggregation.default: #SUM
        netamount     as Netamount,
        @Aggregation.default: #SUM
        grossamount   as Grossamount,
        amountcurr    as Amountcurr
    
}
