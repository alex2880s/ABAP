@AbapCatalog.sqlViewName: 'ZSA_V_PROD_AM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product amount chart'

@UI.chart: [{
    title:       'Amount by markets',
    description: 'Line-chart displaying the gross amount by product',
    chartType:    #BAR,
    dimensions:   [ 'MarketName' ], 
    measures:     [ 'Netamount', 'Grossamount' ] 
}]


define view ZSA_I_PROD_AMO_CH as select from ZSA_I_PROD_MRKT_AGR
association [0..1] to ZSA_I_PROD_MRKT as _Market on $projection.MrktUuid = _Market.MrktUuid
{ 
    key MrktUuid,
        ProdUuid,
        @Aggregation.default: #SUM
        @Semantics.amount.currencyCode: 'amountcurr'
        Netamount,
        @Aggregation.default: #SUM
        @Semantics.amount.currencyCode: 'amountcurr'
        Grossamount,
        amountcurr,

        //Assotiations
       _Market._MarketDesc.Mrktname as MarketName
}
