@AbapCatalog.sqlViewName: 'ZSA_ORD_QAN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order qantity chart'

@UI.chart: [{
    title:       'Quantity by orders',
    description: 'Line-chart displaying the gross amount by customer',
    chartType:    #BAR,
    dimensions:   [ 'DeliveryDate' ], 
    measures:     [ 'Quantity' ] 
}]


define view ZSA_I_ORDER_QAN_CH as select from zsa_d_mrkt_order {

        key prod_uuid     as ProdUuid,
        key mrkt_uuid     as MrktUuid,
        key order_uuid    as OrderUuid,
            orderid       as Orderid,
            @Aggregation.default: #SUM
            quantity      as Quantity,
            delivery_date as DeliveryDate
}
