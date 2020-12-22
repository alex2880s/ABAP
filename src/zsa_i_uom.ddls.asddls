@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UOM view'

define view entity ZSA_I_UOM as select from zsa_d_uom {
    key msehi as Msehi,
    dimid as Dimid,
    isocode as Isocode
}
