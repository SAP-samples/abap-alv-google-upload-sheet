"! <p>
"! BAdI implementation of the OAuth 2.0 Google specific settings.
"! </p>
"!
"! <p>
"! See https://developers.google.com/drive/
"! </p>
"!
"! <p>
"! Copyright (c) 2021 SAP SE or an SAP affiliate company. All rights reserved.
"! <br>
"! This file is licensed under the SAP SAMPLE CODE LICENSE AGREEMENT except as noted otherwise in
"! the LICENSE FILE
"! (https://github.com/SAP-samples/abap-alv-google-upload-sheet/blob/master/LICENSES/Apache-2.0.txt).
"! <br>
"! <br>
"! Note that the sample code includes calls to the Google Drive APIs which calls are licensed under
"! the Creative Commons Attribution 3.0 License (https://creativecommons.org/licenses/by/3.0/) in
"! accordance with Google's Developer Site Policies
"! (https://developers.google.com/terms/site-policies). Furthermore, the use of the Google Drive
"! service is subject to applicable agreements with Google Inc.
"! </p>
class zcl_oa2c_specifics_zgoogle definition
  public
  create public
  inheriting from
    cl_oa2c_specifics_abstract
  final.


  public section.

    methods if_oa2c_specifics~get_config_extension redefinition.
    methods if_oa2c_specifics~get_endpoint_settings redefinition.
    methods if_oa2c_specifics~get_supported_grant_types redefinition.
    methods if_oa2c_specifics~get_ac_auth_requ_param_names redefinition.


endclass.


class zcl_oa2c_specifics_zgoogle implementation.


  method if_oa2c_specifics~get_ac_auth_requ_param_names.
    clear: et_add_param_names, e_client_id, e_redirect_uri, e_response_type, e_response_type_value,
           e_scope.

    super->if_oa2c_specifics~get_ac_auth_requ_param_names(
      importing
        e_client_id           = e_client_id
        e_redirect_uri        = e_redirect_uri
        e_response_type       = e_response_type
        e_response_type_value = e_response_type_value
        e_scope               = e_scope ).

    et_add_param_names = value #( ( name = `access_type`     )
                                  ( name = `approval_prompt` )
                                  ( name = `login_hint`      ) ) ##NO_TEXT.
  endmethod.


  method if_oa2c_specifics~get_config_extension.
    r_config_extension = `ZGOOGLE` ##NO_TEXT.
  endmethod.


  method if_oa2c_specifics~get_endpoint_settings.
    clear: e_authorization_endpoint_path, e_changeable, e_revocation_endpoint_path,
           e_token_endpoint_path.

    e_changeable                  = abap_false.
    e_authorization_endpoint_path = `accounts.google.com/o/oauth2/v2/auth` ##NO_TEXT.
    e_token_endpoint_path         = `oauth2.googleapis.com/token` ##NO_TEXT.
    e_revocation_endpoint_path    = `oauth2.googleapis.com/revoke` ##NO_TEXT.
  endmethod.


  method if_oa2c_specifics~get_supported_grant_types.
    clear: e_authorization_code, e_refresh, e_revocation, e_saml20_assertion.

    e_authorization_code = abap_true.
    e_saml20_assertion   = abap_false.
    e_refresh            = abap_true.
    e_revocation         = abap_true.
  endmethod.


endclass.
