@AbapCatalog.sqlViewName: 'ZSA_V_PROD_AV'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product quantity chart'

@UI.chart: [{
    title:       'Quantity by markets',
    description: 'Line-chart displaying the gross amount by customer',
    chartType:    #DONUT,
    dimensions:   [ 'MarketName' ], 
    measures:     [ 'Quantity' ] 
}]


define view ZSA_I_PROD_QAN_CH as select from ZSA_I_PROD_MRKT_AGR
association [0..1] to ZSA_I_PROD_MRKT as _Market on $projection.MrktUuid = _Market.MrktUuid
{
        key ProdUuid,
        key MrktUuid,
        @Aggregation.default: #SUM
        Quantity,
        _Market._MarketDesc.Mrktname as MarketName
}
