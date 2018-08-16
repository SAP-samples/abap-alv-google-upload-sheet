"! <p>
"! BAdI implementation of the OAuth 2.0 Google specific settings.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class zcl_oa2c_specifics_zgoogle definition
  public
  inheriting from
    cl_oa2c_specifics_abstract
  final
  create public.


  public section.

    methods if_oa2c_specifics~get_config_extension redefinition.
    methods if_oa2c_specifics~get_endpoint_settings redefinition.
    methods if_oa2c_specifics~get_supported_grant_types redefinition.
    methods if_oa2c_specifics~get_ac_auth_requ_param_names redefinition.


endclass.


class zcl_oa2c_specifics_zgoogle implementation.


  method if_oa2c_specifics~get_ac_auth_requ_param_names.
    super->if_oa2c_specifics~get_ac_auth_requ_param_names(
      importing
        e_client_id           = e_client_id
        e_redirect_uri        = e_redirect_uri
        e_response_type       = e_response_type
        e_response_type_value = e_response_type_value
        e_scope               = e_scope
    ).

    et_add_param_names = value if_oa2c_specifics=>ty_t_add_param(
      (
        name = `access_type`                                "#EC NOTEXT
      )
      (
        name = `approval_prompt`                            "#EC NOTEXT
      )
      (
        name = `login_hint`                                 "#EC NOTEXT
      )
    ).
  endmethod.


  method if_oa2c_specifics~get_config_extension.
    r_config_extension = `ZGOOGLE`.                         "#EC NOTEXT
  endmethod.


  method if_oa2c_specifics~get_endpoint_settings.
    e_changeable = abap_false.
    e_authorization_endpoint_path = `accounts.google.com/o/oauth2/auth`. "#EC NOTEXT
    e_token_endpoint_path = `accounts.google.com/o/oauth2/token`. "#EC NOTEXT
    e_revocation_endpoint_path = `accounts.google.com/o/oauth2/revoke`. "#EC NOTEXT
  endmethod.


  method if_oa2c_specifics~get_supported_grant_types.
    e_authorization_code = abap_true.
    e_saml20_assertion = abap_false.
    e_refresh = abap_true.
    e_revocation = abap_true.
  endmethod.


endclass.
