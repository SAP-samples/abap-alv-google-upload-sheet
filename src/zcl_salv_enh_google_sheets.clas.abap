"! <p>
"! Example BAdi-Implementation <em>if_salv_jpb_badi_data_publish</em>.
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
class zcl_salv_enh_google_sheets definition
  public
  create public
  final.


  public section.

    interfaces if_badi_interface.
    interfaces if_salv_jpb_badi_data_publish.

    aliases get_authentication_type
      for if_salv_jpb_badi_data_publish~get_authentication_type.
    aliases get_binary_data_to_publish
      for if_salv_jpb_badi_data_publish~get_binary_data_to_publish.
    aliases get_destination_type
      for if_salv_jpb_badi_data_publish~get_destination_type.
    aliases get_executable_location
      for if_salv_jpb_badi_data_publish~get_executable_location.
    aliases get_file_download_info
      for if_salv_jpb_badi_data_publish~get_file_download_info.
    aliases get_item_descriptor
      for if_salv_jpb_badi_data_publish~get_item_descriptor.
    aliases get_oa2c_auth_ingredients
      for if_salv_jpb_badi_data_publish~get_oa2c_auth_ingredients.
    aliases get_target_url_to_launch
      for if_salv_jpb_badi_data_publish~get_target_url_to_launch.
    aliases is_connection_established
      for if_salv_jpb_badi_data_publish~is_connection_established.


  private section.

    "! The name of the default target Google Drive folder to upload to.
    constants target_folder type zif_googlepoc_drive_api=>file_resource_name value
      `SAP Exports` ##NO_TEXT.

    "! The mime type of an <em>Office Open XML Spreadsheet</em> file.
    constants xlsx_mime_type type string value
      `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` ##NO_TEXT.

    "! The default OAuth 2.0 profile to use.
    data oa2c_profile_name type oa2c_profile value 'Z_GOOGLE_SHEETS' ##NO_TEXT.

    "! The OAuth 2.0 authorization grant application URL.
    data oa2c_auth_application type string
      value `https://dev.sap.com:44333/sap/bc/sec/oauth2/client/grant/authorization` ##NO_TEXT.

    "! The binary data to publish.
    data binary_data_to_publish  type ref to xstring.

    "! The Google Drive Client API.
    data drive_api type ref to zif_googlepoc_drive_api.

    "! Gets the ID of the folder with the given name from the Google Drive.
    "!
    "! @parameter folder_name | The name of the folder.
    "! @parameter create_if_not_existing | <em>abap_true</em> to create the folder if it does not
    "! exist yet; <em>abap_false</em> to not create it.
    "! @parameter result | The ID of the folder; <em>initial</em> if no folder with that name
    "! exists.
    methods get_drive_folder_id
      importing
        folder_name            type zif_googlepoc_drive_api=>file_resource_name
          default target_folder
        create_if_not_existing type abap_bool default abap_true
      returning
        value(result)          type zif_googlepoc_drive_api=>file_resource_id.


endclass.


class zcl_salv_enh_google_sheets implementation.


  method get_drive_folder_id.
    data folder type zif_googlepoc_drive_api=>file_resource.
    data(folder_resources) = me->drive_api->get_files_metadata(
                               name      = folder_name
                               mime_type = zif_googlepoc_drive_api=>supported_mime_types-folder ).
    if folder_resources is initial.
      if create_if_not_existing = abap_true.
        folder = me->drive_api->create_file_metadata(
                   name      = folder_name
                   mime_type = zif_googlepoc_drive_api=>supported_mime_types-folder ).
      endif.
    else.
      folder = folder_resources[ 1 ].
    endif.

    result = folder-id.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_binary_data_to_publish.
    me->binary_data_to_publish = r_binary_data_to_publish.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_destination_type.
    destination_type = if_salv_jpb_data_publisher=>cs_destination_type-cloud.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_item_descriptor.
    "Please take branding aspects into account.
    "See https://developers.google.com/drive/v3/web/branding for more information.
    text                  = |Google Sheets| ##NO_TEXT.
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
    data parent_folder_id type zif_googlepoc_drive_api=>file_resource_id.
    data parent_folder_ids type zif_googlepoc_drive_api=>file_resource_ids.
    data file type zif_googlepoc_drive_api=>file_resource.
    data timestamp type timestamp.

    data is_connection_established type abap_bool.
    me->is_connection_established( changing is_connection_established = is_connection_established ).
    if is_connection_established = abap_true.
      parent_folder_id = me->get_drive_folder_id( ).
      if parent_folder_id is not initial.
        append parent_folder_id to parent_folder_ids.
      endif.

      get time stamp field timestamp.
      file = me->drive_api->multipart_upload(
               data         = me->binary_data_to_publish
               name         = |ALV_EXPORT_{ conv string( timestamp ) }|
               mime_type    = zif_googlepoc_drive_api=>supported_mime_types-spreadsheet
               content_type = xlsx_mime_type
               parents      = parent_folder_ids ) ##NO_TEXT.
      target_url_to_launch = file-web_view_link.
    endif.
  endmethod.


  method if_salv_jpb_badi_data_publish~is_connection_established.
    if me->drive_api is initial.
      try.
          me->drive_api = new zcl_googlepoc_drive_impl(
                            oa2c_profile_name = me->oa2c_profile_name
                            json_api          = new zcl_googlepoc_drive_ui2_json( ) ).
        catch cx_oa2c_config_not_found
              cx_oa2c_config_profile_assign
              cx_oa2c_missing_authorization
              cx_oa2c_config_profile_multi
              cx_oa2c_kernel_too_old into data(oa2c_exc).
          raise exception type cx_salv_connection_error
            exporting
              previous = oa2c_exc.
      endtry.
    endif.

    is_connection_established = me->drive_api->has_valid_token( ).
  endmethod.


  method if_salv_jpb_badi_data_publish~get_authentication_type ##NEEDED.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_executable_location ##NEEDED.
  endmethod.


  method if_salv_jpb_badi_data_publish~get_file_download_info ##NEEDED.
  endmethod.


endclass.
