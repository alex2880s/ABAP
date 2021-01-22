@EndUserText.label: 'Business Partner view'
@ObjectModel.query.implementedBy: 'ABAP:ZSA_CL_BP_QUERY_PROVIDER'
@Metadata.allowExtensions: true
define custom entity ZSA_I_BUSSPARTNER_C
{     
      @EndUserText.label: 'BusinessPartner'
      @UI.lineItem: [{label: 'BusinessPartner' }]  
  key BusinessPartner            : abap.char( 10 );
      @EndUserText.label: 'Customer'
      @OData.property.valueControl: 'Customer_vc'
      @UI.lineItem: [{label: 'Customer' }] 
      Customer                   : abap.char( 10 );
      @UI.hidden: true
      Customer_vc                : rap_cp_odata_value_control;
      @EndUserText.label: 'Business Partner Category'
      @OData.property.valueControl: 'BusinessPartnerCategory_vc'
      @UI.lineItem: [{label: 'BusinessPartnerCategory' }] 
      BusinessPartnerCategory    : abap.char( 1 );
      @UI.hidden: true
      BusinessPartnerCategory_vc : rap_cp_odata_value_control;
      @EndUserText.label: 'Business Partner Grouping'
      @OData.property.valueControl: 'BusinessPartnerGrouping_vc'
      @UI.lineItem: [{label: 'BusinessPartnerGrouping' }]
      BusinessPartnerGrouping    : abap.char( 4 );
      @UI.hidden: true
      BusinessPartnerGrouping_vc : rap_cp_odata_value_control;
      @EndUserText.label: 'Business Partner Name'
      @OData.property.valueControl: 'BusinessPartnerName_vc'
      @UI.lineItem: [{label: 'BusinessPartnerName' }]
      BusinessPartnerName        : abap.char( 81 );
      @UI.hidden: true
      BusinessPartnerName_vc     : rap_cp_odata_value_control;
}
