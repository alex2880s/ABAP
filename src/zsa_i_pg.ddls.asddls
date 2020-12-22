@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product group view'
define view entity ZSA_I_PG as select from zsa_d_prod_group {
    key pgid as Pgid,
    pgname as Pgname,
    imageurl as Imageurl
}
