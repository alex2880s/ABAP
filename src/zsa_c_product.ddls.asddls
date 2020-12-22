@EndUserText.label: 'Projection view Products'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZSA_C_PRODUCT as projection on ZSA_I_PRODUCT 
{
    key ProdUuid,
    @Search.defaultSearchElement: true
    Prodid,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_PG', element: 'Pgid'} }]
    @ObjectModel.text.element: ['Pgname']
    @Search.defaultSearchElement: true
    Pgid,
    _ProductDesc.Pgname as Pgname,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_PHASE', element: 'Phaseid' }}]
    @ObjectModel.text.element: ['Phase']
    Phaseid,
    _Phase.Phase as Phase,
    @Semantics.quantity.unitOfMeasure:'SizeUom'
    Height,
    @Semantics.quantity.unitOfMeasure:'SizeUom'
    Depth,
    @Semantics.quantity.unitOfMeasure:'SizeUom'
    Width,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_UOM', element: 'Msehi' }}]
    SizeUom,
    @Search.defaultSearchElement: true
    @Semantics.amount.currencyCode:'PriceCurrency'
    Price,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_CURRENCY', element: 'Currency' }}]
    PriceCurrency,
    Taxrate,
    CreatedBy,
    CreationTime,
    ChangedBy,
    ChangeTime,
    Criticality,
    ExtPrice,
    
    //Associations
    _Market: redirected to composition child ZSA_C_PROD_MRKT ,
    _Phase,
    _Currency,
    _ProductDesc,
    _QuanChart,
    _AmoChart
    
}
