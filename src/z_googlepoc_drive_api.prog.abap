"! <p>
"! Invokes the Google Drive REST API. Authentication is done via ABAP OAuth 2.0
"! Client with Google specific configuration profile.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
report z_googlepoc_drive_api.

parameters profile type oa2c_profile
  default zcl_googlepoc_drive_impl=>c_default_oauth_20_profile.

"! <p>
"! Sample Google Drive application for demonstration purpose.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class lcl_google_drive_app definition
create public
final.


  public section.

    "! The name of the default target Google Drive folder to upload to.
    constants c_target_folder type zif_googlepoc_drive_api=>y_name
      value `SAP Exports`.                                  "#EC NOTEXT

    "! Constructs a new Google Drive App instance.
    "!
    "! @parameter iv_oa2c_profile_name | The name of the OAuth 2.0 profile to
    "! use.
    "!
    "! @raising cx_oa2c | In case the internally used OAuth 2.0 client could
    "! not be created.
    methods constructor
      importing
        iv_oa2c_profile_name type oa2c_profile optional
      raising
        cx_oa2c.

    "! Application main method.
    methods main.

    "! <p>
    "! Determines if this instance has a valid OAuth 2.0 token, i.e. if access
    "! is allowed. If a valid <em>access token</em> exists, this method returns
    "! <em>abap_true</em>. Otherwise it tries to request a refresh token.
    "! If a valid <em>refresh token</em> was received, <em>abap_true</em> is
    "! returned.
    "! </p>
    "! <p>
    "! In all other cases <em>abap_false</em> is returned.
    "! </p>
    "! <p>
    "! This method can be leveraged prior to any REST API calls in order to
    "! test if an access is allowed at all.
    "! </p>
    "!
    "! @parameter rv_has_valid_token | abap_true if a valid OAuth 2.0 exists;
    "! abap_false otherwise.
    methods has_valid_token
      returning
        value(rv_has_valid_token) type abap_bool.

    "! Determines if a valid Google certificate in the Personal Security
    "! Environment (PSE) exists.
    "!
    "! @parameter ev_is_valid | abap_true if a valid certificate has been found;
    "! abap_false otherwise.
    "! @parameter ev_message | A message describing the validation error in case
    "! the validation failed.
    methods valid_certificate_exists
      exporting
        ev_is_valid type abap_bool
        ev_message  type string.

    "! Lists all files in the Google Drive.
    methods list_all_files.

    "! Outputs the log entries of the Google Drive API.
    methods output_log.


  private section.

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


class lcl_google_drive_app implementation.


  method constructor.
    me->mo_drive_api = new zcl_googlepoc_drive_impl(
      iv_oa2c_profile_name = iv_oa2c_profile_name
      io_drive_json_api    = new zcl_googlepoc_drive_ui2_json( )
    ).
  endmethod.


  method main.
    write `Google Certificate Validation`.                  "#EC NOTEXT
    new-line.
    write `-----------------------------`.                  "#EC NOTEXT
    new-line.
    me->valid_certificate_exists(
      importing
        ev_is_valid = data(lv_is_certificate_valid)
        ev_message  = data(lv_validation_message)
     ).
    write lv_validation_message.
    skip 1.

    if lv_is_certificate_valid = abap_true.
      write `OAuth Client Access Token`.                    "#EC NOTEXT
      new-line.
      write `-------------------------`.                    "#EC NOTEXT
      new-line.

      data(lv_has_valid_token) = me->has_valid_token( ).
      if lv_has_valid_token = abap_true.
        write `Valid access token exists.`.                 "#EC NOTEXT
        skip 1.

        me->list_all_files( ).
        me->output_log( ).
      else.
        write `No valid access token exists.`.              "#EC NOTEXT
        new-line.
      endif.
    endif.
  endmethod.


  method has_valid_token.
    rv_has_valid_token = me->mo_drive_api->has_valid_token( ).
  endmethod.


  method valid_certificate_exists.
    clear: ev_is_valid, ev_message.

    data(lo_cert_validation) = new zcl_googlepoc_cert_validation( ).
    if lo_cert_validation->is_available( ) = abap_true.
      ev_message = `Google certificate was found in PSE.`.  "#EC NOTEXT
      if lo_cert_validation->is_valid( ) = abap_true.
        ev_is_valid = abap_true.
        ev_message = ev_message
          && ` Google certificate in PSE is valid.`.        "#EC NOTEXT
      else.
        ev_message = `Google certificate in PSE has expired and `
          && `needs to be replaced.`.                       "#EC NOTEXT
      endif.
    else.
      ev_message = `Google certificate was not found in PSE.`. "#EC NOTEXT
    endif.
  endmethod.


  method list_all_files.
    write `Listing all files in Google Drive`.              "#EC NOTEXT
    new-line.
    write `---------------------------------`.              "#EC NOTEXT
    new-line.

    data(lt_file_resources) = me->mo_drive_api->list_all_files( ).
    loop at lt_file_resources assigning field-symbol(<ls_file_resource>).
      write |File # { sy-tabix }|.
      new-line.
      write |ID: { <ls_file_resource>-id }|.
      new-line.
      write |Name: { <ls_file_resource>-name }|.
      new-line.
      write |Mime Type: { <ls_file_resource>-mime_type }|.
      new-line.
      write |Web View Link: { <ls_file_resource>-web_view_link }|.
      new-line.

      loop at <ls_file_resource>-parents
      assigning field-symbol(<lv_parent_id>).
        write |Parent ID [{ sy-tabix  }]: { <lv_parent_id> }|. "#EC NOTEXT
        new-line.
      endloop.
      skip.
    endloop.

    new-line.
  endmethod.


  method output_log.
    write `Log entries`.                                    "#EC NOTEXT
    new-line.
    write `-----------`.                                    "#EC NOTEXT
    new-line.

    me->mo_drive_api->get_log(
      importing
        et_log = data(lt_log_entries)
    ).
    loop at lt_log_entries assigning field-symbol(<ls_log_entry>).
      write <ls_log_entry>-date dd/mm/yyyy.
      write <ls_log_entry>-time environment time format.
      write |{ <ls_log_entry>-message }|.
      new-line.
    endloop.
  endmethod.


  method get_drive_folder_id.
    data(lt_folder_resources) = me->mo_drive_api->get_files_metadata(
      iv_name      = iv_folder_name
      iv_mime_type = zif_googlepoc_drive_api=>cs_mime_type-folder
    ).
    if lt_folder_resources is initial.
      if iv_create_if_not_existing = abap_true.
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


endclass.


at selection-screen.

start-of-selection.
  try.
      data(lo_drive_app) = new lcl_google_drive_app( profile ).
      lo_drive_app->main( ).
    catch cx_oa2c into data(lo_oa2c_exc).
      write |Error creating Google Drive client: { lo_oa2c_exc->get_text( ) }|. "#EC NOTEXT
      new-line.
  endtry.
