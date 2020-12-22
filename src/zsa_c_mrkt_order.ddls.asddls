@EndUserText.label: 'Projection view order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true


define view entity ZSA_C_MRKT_ORDER as projection on ZSA_I_MRKT_ORDER

 {
    key ProdUuid,
    key MrktUuid,
    key OrderUuid,
    Orderid,
    Quantity,
    CalendarYear,
    DeliveryDate,
    Netamount,
    Grossamount,
    Amountcurr,
    CreatedBy,
    CreationTime,
    ChangedBy,
    ChangeTime,
    ZSA_I_MRKT_ORDER.prdid as prodid,
    //Associations
    _Market  : redirected to parent ZSA_C_PROD_MRKT,
    _Product : redirected to ZSA_C_PRODUCT

}
