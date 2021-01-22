@EndUserText.label: 'Projection view order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Orderid']

define view entity ZSA_C_MRKT_ORDER as projection on ZSA_I_MRKT_ORDER

 {
    key ProdUuid,
    key MrktUuid,
    key OrderUuid,
    Orderid,
    Status,
    Criticality,
    Quantity,
    CalendarYear,
    DeliveryDate,
    @Semantics.amount.currencyCode: 'Amountcurr'
    Netamount,
    @Semantics.amount.currencyCode: 'Amountcurr'
    Grossamount,
    Amountcurr, 
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZSA_I_BUSSPARTNER_C', element: 'BusinessPartner' },
        additionalBinding: [  
                              {  element: 'BusinessPartnerGrouping', localElement: 'BusinessPartnerGroup'  },
                              {  element: 'BusinessPartnerName',     localElement: 'BusinessPartnerName'   }
                           ]   
                           }]     
    BusinessPartner,
    BusinessPartnerGroup,
    BusinessPartnerName,
    Country,
    Locality,
    Street,
    House,
    CreatedBy,
    CreationTime,
    ChangedBy,
    ChangeTime,
    LocalLastChangedAt,
    
    
    ZSA_I_MRKT_ORDER.prdid as prodid,
    //Associations
    _Market  : redirected to parent ZSA_C_PROD_MRKT,
    _Product : redirected to ZSA_C_PRODUCT,
    _BusinessPartner
    

}
