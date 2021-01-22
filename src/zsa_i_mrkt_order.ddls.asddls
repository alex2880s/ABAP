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
association [0..1] to zsa_i_busspartner_c as _BusinessPartner on $projection.BusinessPartner = _BusinessPartner.BusinessPartner

{
    key prod_uuid as ProdUuid,
    key mrkt_uuid as MrktUuid,
    key order_uuid as OrderUuid,
    orderid as Orderid,
    quantity as Quantity,
    status as Status,
        case status 
        when 'X' then 3
        when ''  then 1
        when '-' then 1
        else 0
     end as Criticality,
    calendar_year as CalendarYear,
    delivery_date as DeliveryDate,
    @Semantics.amount.currencyCode: 'Amountcurr'
    netamount as Netamount,
    @Semantics.amount.currencyCode: 'Amountcurr'
    grossamount as Grossamount,
    amountcurr as Amountcurr,
    busspartner as BusinessPartner,
    busspartner_gr as BusinessPartnerGroup,
    busspartner_n as BusinessPartnerName,
    contry as Country,
    locality as Locality,
    street as Street,
    house as House,
    @Semantics.user.createdBy: true
    case created_by
            when 'CB0000000723' then 'A.Shnip'
            when 'CB0000000740' then 'K.Blagushko'
            else 'Someone else'
        end 
            as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    cast(creation_time as timestamp) as CreationTime,
    @Semantics.user.lastChangedBy: true
    case changed_by
            when 'CB0000000723' then 'A.Shnip'
            when 'CB0000000740' then 'K.Blagushko'
            else 'Someone else'
        end 
            as ChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    cast(change_time as timestamp) as ChangeTime,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true    
    local_last_changed_at as LocalLastChangedAt,
    
    
    _Market.ProdUuid as prdid,
   
    //Association
    _Market,
    _Market._Product,
    _BusinessPartner
}
