@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product basic view'

define root view entity ZSA_I_PRODUCT
  as select from zsa_d_product
  composition[0..*] of ZSA_I_PROD_MRKT        as _Market
  association [0..1] to ZSA_I_PHASE           as _Phase       on $projection.Phaseid       = _Phase.Phaseid
  association [0..1] to ZSA_I_CURRENCY        as _Currency    on $projection.PriceCurrency = _Currency.Currency
  association [0..1] to ZSA_I_PG              as _ProductDesc on $projection.Pgname        = _ProductDesc.Pgname
  association [0..*] to ZSA_I_PROD_QAN_CH     as _QuanChart   on $projection.ProdUuid      = _QuanChart.ProdUuid
  association [0..*] to ZSA_I_PROD_AMO_CH     as _AmoChart    on $projection.ProdUuid      = _AmoChart.ProdUuid
  association [0..*] to ZSA_I_LANGUAGE        as _Language    on $projection.TransCode     = _Language.Code  

{
  key prod_uuid      as ProdUuid,
      prodid         as Prodid,
      phaseid        as Phaseid,
      _Phase.Phase   as Phase,
      pgid           as Pgid,
      pgname         as Pgname,
      pgname_tr      as PgnameTr,
      trans_code     as TransCode,
      @Semantics.quantity.unitOfMeasure:'SizeUom'
      height         as Height,
      @Semantics.quantity.unitOfMeasure:'SizeUom'
      depth          as Depth,
      @Semantics.quantity.unitOfMeasure:'SizeUom'
      width          as Width,
      size_uom       as SizeUom,
    -- Currency conversion end       
      @Semantics.amount.currencyCode:'PriceCurrency'
      price          as Price,
      price_currency as PriceCurrency,
      taxrate        as Taxrate,
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
      case created_by
        when 'CB0000000723' then 'A.Shnip'
        when 'CB0000000740' then 'K.Blagushko'
        else 'Someone else'
      end 
        as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      cast(change_time as timestamp)    as ChangeTime,
      case phaseid
        when 1 then 1
        when 2 then 2
        when 3 then 3
        else 0
      end  
        as Criticality,
      @Semantics.amount.currencyCode:'PriceCurrency'
      external_price  as ExtPrice,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true    
      local_last_changed_at as LocalLastChangedAt,
        
      //  _association_name 
      _Market,
      _Phase,
      _Currency,
      _ProductDesc,
      _QuanChart,
      _AmoChart,
      _Language
}
