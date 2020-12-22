@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phase view'

define view entity ZSA_I_PHASE as select from zsa_d_phase {
    key phaseid as Phaseid,
    phase as Phase
}
