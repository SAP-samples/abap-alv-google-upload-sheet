"! <p>
"! Implementation of the <strong>Google Drive JSON API</strong> that utilizes the
"! <em>UI2 (/UI2/CL_JSON)</em> library for parsing and producing content in JSON format.
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
class zcl_googlepoc_drive_ui2_json definition
  public
  create public
  final.


  public section.

    interfaces zif_googlepoc_drive_json_api.

    aliases create_file_resource
      for zif_googlepoc_drive_json_api~create_file_resource.
    aliases parse_file_resource
      for zif_googlepoc_drive_json_api~parse_file_resource.
    aliases parse_file_resource_list
      for zif_googlepoc_drive_json_api~parse_file_resource_list.
    aliases set_log_api
      for zif_googlepoc_drive_json_api~set_log_api.


  private section.

    "! The used logging API.
    data log_api type ref to zif_googlepoc_drive_log_api.   "#EC NEEDED

    types:
      "! Describes a Google File Resource response.
      begin of file_resource_response,
        files type zif_googlepoc_drive_api=>file_resources,
      end of file_resource_response.


endclass.


class zcl_googlepoc_drive_ui2_json implementation.


  method zif_googlepoc_drive_json_api~create_file_resource.
    data(date_time_converter) = new zcl_googlepoc_rfc3339_datetime( ).
    data(create_date_time) = date_time_converter->convert(
                               value #( date                    = sy-datum
                                        time                    = sy-uzeit
                                        local_to_utc_difference = sy-tzone div 60 ) ).

    data(escaped_name) = escape( val    = name
                                 format = cl_abap_format=>e_json_string ).
    data(escaped_mime_type) = escape( val    = mime_type
                                      format = cl_abap_format=>e_json_string ).
    data(escaped_create_date_time) = escape( val    = create_date_time
                                             format = cl_abap_format=>e_json_string ).

    result = |\{"name":"{ escaped_name }","mimeType":"{ escaped_mime_type }",|
          && |"createdTime":"{ escaped_create_date_time }"| ##NO_TEXT.

    data lv_parents_array type /ui2/cl_json=>json.
    if parents is not initial.
      lv_parents_array = /ui2/cl_json=>serialize( data = parents ).
      if lv_parents_array is not initial.
        result = result && |,"parents":{ lv_parents_array }| ##NO_TEXT.
      endif.
    endif.

    result = result && |\}| ##NO_TEXT.
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource.
    /ui2/cl_json=>deserialize(
      exporting
        json        = file_resource_json
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      changing
        data        = result ).
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource_list.
    clear result.

    data response type file_resource_response.
    /ui2/cl_json=>deserialize(
      exporting
        json        = file_resource_list_json
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      changing
        data        = response
    ).

    result = response-files.
  endmethod.


  method zif_googlepoc_drive_json_api~set_log_api.
    me->log_api = api.
  endmethod.


endclass.
