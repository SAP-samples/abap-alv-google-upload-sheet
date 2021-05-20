"! <p>
"! BAdI implementation of the OAuth 2.0 Google configuration extension.
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
class zcl_oa2c_ce_zgoogle definition
  public
  create public
  final.


  public section.

    interfaces if_badi_interface.
    interfaces if_oa2c_config_extension.


endclass.


class zcl_oa2c_ce_zgoogle implementation.


  method if_oa2c_config_extension~get_ac_auth_requ_params.
    clear et_additional_params.
    et_additional_params = value #( ( name  = `access_type`
                                      value = `offline` )
                                    ( name  = `approval_prompt`
                                      value = `force` ) ) ##NO_TEXT.
  endmethod.


  method if_oa2c_config_extension~get_saml20_at_requ_params ##NEEDED.
    "Nothing to do in here.
  endmethod.


endclass.
