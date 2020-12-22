@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product market basic view'
@Analytics.dataCategory: #CUBE


define view entity ZSA_I_PROD_MRKT as select from zsa_d_prod_mrkt
    association       to parent ZSA_I_PRODUCT as _Product      on $projection.ProdUuid = _Product.ProdUuid
    association[0..1] to ZSA_I_MARKET         as _MarketDesc   on $projection.Mrktid   = _MarketDesc.Mrktid
    association[0..*] to ZSA_I_ORDER_QAN_CH   as _OrderQantity on $projection.MrktUuid = _OrderQantity.MrktUuid
    association[0..*] to ZSA_I_ORDER_AMO_CH   as _OrderAmount  on $projection.MrktUuid = _OrderAmount.MrktUuid
    association[0..1] to ZSA_I_PROD_MRKT_AGR  as _MarketAgr    on $projection.MrktUuid = _MarketAgr.MrktUuid
    composition[0..*] of ZSA_I_MRKT_ORDER     as _Order
 {
    key prod_uuid as ProdUuid,
    key mrkt_uuid as MrktUuid,
        mrktid as Mrktid,
        status as Status,
        startdate as Startdate,
        enddate as Enddate,
        @Semantics.user.createdBy: true
        created_by as CreatedBy,
        @Semantics.systemDateTime.createdAt: true
        creation_time as CreationTime,
        @Semantics.user.lastChangedBy: true
        changed_by as ChangedBy,
        @Semantics.systemDateTime.lastChangedAt: true
        change_time as ChangeTime, 
        tstmp_to_dats( creation_time,
                   abap_system_timezone( $session.client,'NULL' ),
                   $session.client,
                   'NULL' ) as CreationTime_Date,
        tstmp_to_dats( change_time,
                   abap_system_timezone( $session.client,'NULL' ),
                   $session.client,
                   'NULL' ) as ChangeTime_Date,               
    case status 
        when 'X' then 3
        when ''  then 1
        else 0
     end as Criticality,
     
     @Semantics.amount.currencyCode: 'amountcurr'
     _MarketAgr.Grossamount as TotalGrossamount,
     _MarketAgr.Netamount   as TotalNetamount,
     _MarketAgr.Quantity    as TotalQuantity,
     _MarketAgr.amountcurr  as amountcurr,
       
    /* associations */
    _Product,
    _MarketDesc,
    _Order,
    _OrderQantity,
    _OrderAmount,
    _MarketAgr
}
