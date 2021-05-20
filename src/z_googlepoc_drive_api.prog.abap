"! <p>
"! <strong>Example program</strong> that invokes the <strong>Google Drive REST API</strong>. The
"! authentication is done via an ABAP OAuth 2.0 Client with a Google specific configuration profile.
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
report z_googlepoc_drive_api.

parameters profile type oa2c_profile
  default zcl_googlepoc_drive_impl=>default_oauth_20_profile.

"! <p>
"! Sample Google Drive application for demonstration purpose.
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
class lcl_google_drive_app definition
create public
final.


  public section.

    "! The name of the default target Google Drive folder to upload to.
    constants target_folder type zif_googlepoc_drive_api=>file_resource_name
      value `SAP Exports` ##NO_TEXT.

    "! Constructs a new Google Drive App instance.
    "!
    "! @parameter oa2c_profile_name | The name of the OAuth 2.0 profile to use.
    "!
    "! @raising cx_oa2c | In case the internally used OAuth 2.0 client could not be created.
    methods constructor
      importing
        oa2c_profile_name type oa2c_profile optional
      raising
        cx_oa2c.

    "! Application main method.
    methods main.

    "! <p>
    "! Determines if this instance has a valid OAuth 2.0 token, i.e. if access is allowed. If a
    "! valid <em>access token</em> exists, this method returns <em>abap_true</em>. Otherwise it
    "! tries to request a refresh token. If a valid <em>refresh token</em> was received,
    "! <em>abap_true</em> is returned.
    "! </p>
    "! <p>
    "! In all other cases <em>abap_false</em> is returned.
    "! </p>
    "! <p>
    "! This method can be leveraged prior to any REST API calls in order to test if an access is
    "! allowed at all.
    "! </p>
    "!
    "! @parameter result | <em>abap_true</em> if a valid OAuth 2.0 exists; <em>abap_false</em>
    "! otherwise.
    methods has_valid_token
      returning
        value(result) type abap_bool.

    "! Determines if a valid Google certificate in the Personal Security Environment (PSE) exists.
    "!
    "! @parameter is_valid | <em>abap_true</em> if a valid certificate has been found;
    "! <em>abap_false</em> otherwise.
    "! @parameter message | A message describing the validation error in case the validation failed.
    methods validate_certificate
      exporting
        is_valid type abap_bool
        message  type string.

    "! Lists all files in the Google Drive.
    methods list_all_files.

    "! Outputs the log entries of the Google Drive API.
    methods output_log.


  private section.

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


class lcl_google_drive_app implementation.


  method constructor.
    me->drive_api = new zcl_googlepoc_drive_impl(
                      oa2c_profile_name = oa2c_profile_name
                      json_api          = new zcl_googlepoc_drive_ui2_json( ) ).
  endmethod.


  method main.
    write `OAuth Client Access Token` ##NO_TEXT.
    new-line.
    write `-------------------------` ##NO_TEXT.
    new-line.

    data(has_valid_token) = me->has_valid_token( ).
    if has_valid_token = abap_true.
      write `A valid access token exists.` ##NO_TEXT.
      skip 1.

      me->list_all_files( ).
      me->output_log( ).

      skip 1.
      write `Google Certificate Validation` ##NO_TEXT.
      new-line.
      write `-----------------------------` ##NO_TEXT.
      new-line.

      me->validate_certificate(
        importing
          is_valid = data(is_certificate_valid)
          message  = data(validation_message) ).
      write validation_message.
    else.
      write `No valid access token exists.` ##NO_TEXT.
      new-line.
    endif.
  endmethod.


  method has_valid_token.
    result = me->drive_api->has_valid_token( ).
  endmethod.


  method validate_certificate.
    clear: is_valid, message.

    data(certificate_validation) = new zcl_googlepoc_cert_validation( ).
    if certificate_validation->is_available( ) = abap_true.
      message = `Google certificate was found in PSE.` ##NO_TEXT.
      if certificate_validation->is_valid( ) = abap_true.
        is_valid = abap_true.
        message = message && ` Google certificate in PSE is valid.` ##NO_TEXT.
      else.
        message = `Google certificate in PSE has expired and needs to be replaced.` ##NO_TEXT.
      endif.
    else.
      message = `Google certificate was not found in PSE.` ##NO_TEXT.
    endif.
  endmethod.


  method list_all_files.
    write `Listing all files in Google Drive` ##NO_TEXT.
    new-line.
    write `---------------------------------` ##NO_TEXT.
    new-line.

    data(files) = me->drive_api->list_all_files( ).
    loop at files assigning field-symbol(<current_file>).
      write |File # { sy-tabix }| ##NO_TEXT.
      new-line.
      write |ID: { <current_file>-id }| ##NO_TEXT.
      new-line.
      write |Name: { <current_file>-name }| ##NO_TEXT.
      new-line.
      write |Mime Type: { <current_file>-mime_type }| ##NO_TEXT.
      new-line.
      write |Web View Link: { <current_file>-web_view_link }| ##NO_TEXT.
      new-line.

      loop at <current_file>-parents assigning field-symbol(<current_parent_id>).
        write |Parent ID [{ sy-tabix  }]: { <current_parent_id> }| ##NO_TEXT.
        new-line.
      endloop.
      skip.
    endloop.

    new-line.
  endmethod.


  method output_log.
    write `Log entries` ##NO_TEXT.
    new-line.
    write `-----------` ##NO_TEXT.
    new-line.

    me->drive_api->get_log(
      importing
        result = data(log_entries) ).
    loop at log_entries assigning field-symbol(<current_log_entry>).
      write <current_log_entry>-date dd/mm/yyyy.
      write <current_log_entry>-time environment time format.
      write |{ <current_log_entry>-message }|.
      new-line.
    endloop.
  endmethod.


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


endclass.


at selection-screen.

start-of-selection.
  try.
      data(app) = new lcl_google_drive_app( profile ).
      app->main( ).
    catch cx_oa2c into data(oa2c_exc).
      write |Error creating Google Drive client: { oa2c_exc->get_text( ) }| ##NO_TEXT.
      new-line.
  endtry.
