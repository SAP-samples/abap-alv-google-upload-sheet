"! <p>
"! BAdI implementation of the OAuth 2.0 Google configuration extension.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class zcl_oa2c_ce_zgoogle definition
  public
  final
  create public.


  public section.

    interfaces if_badi_interface.
    interfaces if_oa2c_config_extension.


endclass.


class zcl_oa2c_ce_zgoogle implementation.


  method if_oa2c_config_extension~get_ac_auth_requ_params.
    et_additional_params = value tihttpnvp(
      (
         name  = `access_type`                              "#EC NOTEXT
         value = `offline` "online|offline
      )
      (
         name  = `approval_prompt`                          "#EC NOTEXT
         value = `force` "auto|force
      )
    ).
  endmethod.


  method if_oa2c_config_extension~get_saml20_at_requ_params ##NEEDED.
    "Nothing to do in here.
  endmethod.


endclass.
