@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}


define view entity ZSA_I_MRKT_ORDER as select from zsa_d_mrkt_order
association to parent ZSA_I_PROD_MRKT as _Market on  $projection.MrktUuid = _Market.MrktUuid
                                                 and $projection.ProdUuid = _Market.ProdUuid
{
    key prod_uuid as ProdUuid,
    key mrkt_uuid as MrktUuid,
    key order_uuid as OrderUuid,
    orderid as Orderid,
    quantity as Quantity,
    calendar_year as CalendarYear,
    delivery_date as DeliveryDate,
    @Semantics.amount.currencyCode: 'amountcurr'
    netamount as Netamount,
    @Semantics.amount.currencyCode: 'amountcurr'
    grossamount as Grossamount,
    amountcurr as Amountcurr,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    creation_time as CreationTime,
    @Semantics.user.lastChangedBy: true
    changed_by as ChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    change_time as ChangeTime,
    _Market.ProdUuid as prdid,
   
    //Association
    _Market,
    _Market._Product
}
