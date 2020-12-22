@EndUserText.label: 'Projection view Product market'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZSA_C_PROD_MRKT as projection on ZSA_I_PROD_MRKT {
    key ProdUuid,
    key MrktUuid,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_MARKET', element: 'Mrktid' }}]
    @ObjectModel.text.element: ['Mrktname']
    @Search.defaultSearchElement: true
    Mrktid,
    _MarketDesc.Mrktname as Mrktname,
    Status,
    Startdate,
    Enddate,
    CreatedBy,
    CreationTime,
    ChangedBy,
    ChangeTime,
    CreationTime_Date,
    ChangeTime_Date,
    Criticality,
    TotalGrossamount,
    TotalNetamount,
    TotalQuantity,
    amountcurr,
    /* Associations */
    _Product : redirected to parent ZSA_C_PRODUCT,
    _Order: redirected to composition child ZSA_C_MRKT_ORDER, 
    _MarketDesc,
    _OrderQantity,
    _OrderAmount,
    _MarketAgr
}
