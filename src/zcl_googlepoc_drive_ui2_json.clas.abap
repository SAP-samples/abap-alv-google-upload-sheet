"! <p>
"! Implementation of the Google Drive JSON API that leverages the
"! <em>UI2 (/UI2/CL_JSON)</em> library for producing and parsing content in
"! JSON format.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
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
    data mo_log_api type ref to zif_googlepoc_drive_log_api. "#EC NEEDED

    types:
      "! Describes a Google File Resource response.
      begin of ys_file_resource_response,
        files type zif_googlepoc_drive_api=>yt_file_resource,
      end of ys_file_resource_response.


endclass.


class zcl_googlepoc_drive_ui2_json implementation.


  method zif_googlepoc_drive_json_api~create_file_resource.
    data(lo_date_time_converter) = new zcl_googlepoc_rfc3339_datetime( ).
    data(lv_create_date_time) = lo_date_time_converter->convert(
      value zcl_googlepoc_rfc3339_datetime=>ys_date_time(
        date                    = sy-datum
        time                    = sy-uzeit
        local_to_utc_difference = sy-tzone div 60
      )
    ).

    data(lv_escaped_name) = escape(
      val    = iv_name
      format = cl_abap_format=>e_json_string
    ).

    data(lv_escaped_mime_type) = escape(
      val    = iv_mime_type
      format = cl_abap_format=>e_json_string
    ).

    data(lv_escaped_create_date_time) = escape(
      val    = lv_create_date_time
      format = cl_abap_format=>e_json_string
    ).

    if it_parents is not initial.
      data(lv_parents_array) = /ui2/cl_json=>serialize(
        data = it_parents
      ).
    endif.

    rv_file_resource_json =
         |\{"name":"{ lv_escaped_name }","mimeType":"{ lv_escaped_mime_type }",|
      && |"createdTime":"{ lv_escaped_create_date_time }"|. "#EC NOTEXT

    if lv_parents_array is not initial.
      rv_file_resource_json = rv_file_resource_json
        && |,"parents":{ lv_parents_array }|.               "#EC NOTEXT
    endif.

    rv_file_resource_json = rv_file_resource_json && |\}|.  "#EC NOTEXT
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource.
    /ui2/cl_json=>deserialize(
      exporting
        json        = iv_file_resource_json
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      changing
        data        = rs_file_resource
    ).
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource_list.
    clear et_file_resources.

    data ls_files_response type ys_file_resource_response.
    /ui2/cl_json=>deserialize(
      exporting
        json        = iv_file_resource_list_json
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      changing
        data        = ls_files_response
    ).

    et_file_resources = ls_files_response-files.
  endmethod.


  method zif_googlepoc_drive_json_api~set_log_api.
    me->mo_log_api = io_log_api.
  endmethod.


endclass.
