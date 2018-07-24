"! <p>
"! Example BAdi-Implementation <em>if_salv_jpb_badi_data_publish</em>.
"! </p>
"!
"! <p>
"! Author:  Klaus-Dieter Scherer, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
class zcl_salv_enh_google_sheets definition
  public
  create public
  final.


  public section.

    interfaces if_badi_interface.
    interfaces if_salv_jpb_badi_data_publish.


  private section.

    "! The name of the default target Google Drive folder to upload to.
    constants c_target_folder type zif_googlepoc_drive_api=>y_name
      value `SAP Exports`.                                  "#EC NOTEXT

    "! The default OAuth 2.0 profile to use.
    data oa2c_profile_name type oa2c_profile
      value 'Z_GOOGLE_SHEETS'.                              "#EC NOTEXT

    "! The OAuth 2.0 authorization grant application URL.
    data oa2c_auth_application type string.
      "value `https://<<´´server>>:<port>/sap/bc/sec/oauth2/client/grant/authorization`. "#EC NOTEXT

    "! The binary data to publish.
    data mr_binary_data_to_publish  type ref to xstring.

    "! The Google Drive client API.
    data mo_drive_api type ref to zif_googlepoc_drive_api.

    "! Gets the ID of the folder with the given name from the Google Drive.
    "!
    "! @parameter iv_folder_name | The name of the folder.
    "! @parameter iv_create_if_not_existing | abap_true to create the folder
    "! if it does not exist yet; abap_false to not create it.
    "! @parameter rv_folder_id | The ID of the folder; initial if no folder with
    "! that name exists.
    methods get_drive_folder_id
      importing
        iv_folder_name            type zif_googlepoc_drive_api=>y_name default c_target_folder
        iv_create_if_not_existing type abap_bool default abap_true
      returning
        value(rv_folder_id)       type zif_googlepoc_drive_api=>y_id.

endclass.


class zcl_salv_enh_google_sheets implementation.


  method get_drive_folder_id.
    data(lt_folder_resources) = me->mo_drive_api->get_files_metadata(
      iv_name      = iv_folder_name
      iv_mime_type = zif_googlepoc_drive_api=>cs_mime_type-folder
    ).
    if lt_folder_resources is initial.
      if iv_create_if_not_existing = abap_true.
        "Create target folder if not existing yet.
        data(ls_folder_resource) = me->mo_drive_api->create_file_metadata(
          iv_name      = iv_folder_name
          iv_mime_type = zif_googlepoc_drive_api=>cs_mime_type-folder
        ).
      endif.
    else.
      ls_folder_resource = lt_folder_resources[ 1 ].
    endif.

    rv_folder_id = ls_folder_resource-id.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_authentication_type.
    return. "Default
  endmethod.


  method if_salv_jpb_badi_data_publish~get_binary_data_to_publish.
    me->mr_binary_data_to_publish = r_binary_data_to_publish.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_destination_type.
    destination_type = if_salv_jpb_data_publisher=>cs_destination_type-cloud.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_executable_location.
    return.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_file_download_info.
    return.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_item_descriptor.
    "Please take branding aspects into account:
    "https://developers.google.com/drive/v3/web/branding
    text                  = |Google Sheets|.                "#EC NOTEXT
    frontend              = if_salv_jpb_data_publisher=>cs_frontend-google_sheets.
    is_default_for_format = abap_true.
    xml_type              = if_salv_bs_xml=>c_type_xlsx.
    output_format         = if_salv_jpb_data_publisher=>cs_output_format-xlsx.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_oa2c_auth_ingredients.
    profile_name               = me->oa2c_profile_name.
    grant_auth_application_url = me->oa2c_auth_application.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_target_url_to_launch.
    data lv_is_connection_established type abap_bool.
    if_salv_jpb_badi_data_publish~is_connection_established(
      changing
        is_connection_established = lv_is_connection_established
    ).
    if lv_is_connection_established = abap_true.
      data(lv_parent_folder_id) = me->get_drive_folder_id( ).
      data lt_parent_folder_ids type zif_googlepoc_drive_api=>yt_id.
      if lv_parent_folder_id is not initial.
        append lv_parent_folder_id to lt_parent_folder_ids.
      endif.

      get time stamp field data(lv_timestamp).
      data(ls_file_resource) = me->mo_drive_api->multipart_upload(
        ir_data         = me->mr_binary_data_to_publish
        iv_name         = |EXPORT{ conv string( lv_timestamp ) }| "#EC NOTEXT
        iv_mime_type    = zif_googlepoc_drive_api=>c_google_spreadsheet_mime_type
        iv_content_type = cl_salv_bs_lex_format_xlsx=>c_xlsx_mime_type
        it_parents      = lt_parent_folder_ids
      ).

      target_url_to_launch = ls_file_resource-web_view_link.
    endif.
  endmethod.


  method if_salv_jpb_badi_data_publish~is_connection_established.
    if me->mo_drive_api is not bound.
      try.
          me->mo_drive_api = new zcl_googlepoc_drive_impl(
            iv_oa2c_profile_name = me->oa2c_profile_name
            io_drive_json_api    = new zcl_googlepoc_drive_ui2_json( )
          ).
        catch cx_oa2c_config_not_found
              cx_oa2c_config_profile_assign
              cx_oa2c_missing_authorization into data(lo_config_not_found_exc).
          raise exception type cx_salv_connection_error
            exporting
              previous = lo_config_not_found_exc.
        catch cx_oa2c_kernel_too_old into data(lo_kernel_too_old_exc).
          raise exception type cx_salv_connection_error
            exporting
              previous = lo_kernel_too_old_exc.
      endtry.
    endif.

    is_connection_established = me->mo_drive_api->has_valid_token( ).
  endmethod.


endclass.