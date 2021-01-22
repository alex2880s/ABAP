@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For language drop-down list'
@ObjectModel.resultSet:{sizeCategory: #XS}

define view entity ZSA_I_LANGUAGE as select from zsa_d_langu {
    key code    as Code,
        country as Country
}
