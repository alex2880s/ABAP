@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Market view'


define view entity ZSA_I_MARKET
  as select from zsa_d_market
{
  key mrktid   as Mrktid,
      mrktname as Mrktname,
      imageurl as Imageurl
}
