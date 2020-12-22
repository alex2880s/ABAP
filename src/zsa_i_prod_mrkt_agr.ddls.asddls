@AbapCatalog.sqlViewName: 'ZSA_V_MRK_AGR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analytical view'

define view ZSA_I_PROD_MRKT_AGR as select from zsa_d_mrkt_order {
    key prod_uuid    as ProdUuid,
    key mrkt_uuid    as MrktUuid,
    sum(quantity)    as Quantity,
    @Semantics.amount.currencyCode: 'amountcurr'
    sum(netamount)   as Netamount,
    @Semantics.amount.currencyCode: 'amountcurr'
    sum(grossamount) as Grossamount,
    amountcurr
}
group by prod_uuid, mrkt_uuid, amountcurr
