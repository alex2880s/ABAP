@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product group view'
@Search.searchable: true

 
define view entity ZSA_I_PG as select from zsa_d_prod_group as ProductDesc {
    @Search.defaultSearchElement: true
    @ObjectModel.text.element: ['Pgname']
    key pgid as Pgid,
    @Semantics.text: true
    pgname as Pgname,
    imageurl as Imageurl
}
