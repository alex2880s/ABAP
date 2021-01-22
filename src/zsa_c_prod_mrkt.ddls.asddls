@EndUserText.label: 'Projection view Product market'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['Mrktid']

define view entity ZSA_C_PROD_MRKT as projection on ZSA_I_PROD_MRKT {
    key ProdUuid,
    key MrktUuid,
    @Search.defaultSearchElement: true
    Mrktid,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_MARKET', element: 'Mrktname' }, 
                                        additionalBinding: [{  element: 'Mrktid', localElement: 'Mrktid' }] }]
    @ObjectModel.text.element: ['Mrktid']
    @Search.defaultSearchElement: true
    Mrktname,
    Status,
    Startdate,
    Enddate,
    IsoCode,
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
    LocalLastChangedAt,
    
    /* Associations */
    _Product : redirected to parent ZSA_C_PRODUCT,
    _Order: redirected to composition child ZSA_C_MRKT_ORDER, 
    _MarketDesc,
    _OrderQantity,
    _OrderAmount,
    _MarketAgr
}
