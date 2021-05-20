"! <p>
"! Assistance class of the custom Web Dynpro ABAP Redirect Handler for an OAuth Redirect URI
"! Workflow.
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
class zcl_salv_wd_google_redirect definition
  public
  create public
  inheriting from
    cl_wd_component_assistance
  final.


  public section.

    aliases get_text
      for if_wd_component_assistance~get_text.

    "! Sets the received URL parameters.
    "!
    "! @parameter url_parameters | The list of received URL parameters.
    methods set_url_parameters
      importing
        url_parameters type tihttpnvp.

    "! Evaluates the beforehand set URL parameters and produces a human readable message from it.
    "!
    "! @parameter message | The evaluation message.
    "! @parameter message_icon | A path to either a <em>success</em> or <em>error</em> image.
    methods get_message
      exporting
        message      type string
        message_icon type string.


  private section.

    "! The list of received URL parameters.
    data url_parameters type tihttpnvp.


endclass.


class zcl_salv_wd_google_redirect implementation.


  method get_message.
    clear: message, message_icon.

    loop at me->url_parameters assigning field-symbol(<current_url_parameter>).
      case <current_url_parameter>-name.
        when `ERROR`.
          message = |Error { <current_url_parameter>-value } received. |
                 && `lease contact your system administrator.` ##NO_TEXT.
          message_icon = `~IconLarge/ErrorMessage` ##NO_TEXT.
          exit.
        when others.
          message = `Access token successfully received from Google. Please repeat your Export To `
                 && `Spreadsheet (Google Sheets) action` ##NO_TEXT.
          message_icon = `~IconLarge/SuccessMessage` ##NO_TEXT.
      endcase.
    endloop.
  endmethod.


  method set_url_parameters.
    me->url_parameters = url_parameters.
  endmethod.


endclass.
