@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Currency view'

define view entity ZSA_I_CURRENCY as select from I_Currency {
    key Currency,
    Decimals,
    CurrencyISOCode,
    AlternativeCurrencyKey,
    IsPrimaryCurrencyForISOCrcy,
    /* Associations */
    _Text
}
