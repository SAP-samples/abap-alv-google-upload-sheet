"! <p>
"! Interface to the Google Drive REST API.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
interface zif_googlepoc_drive_api
  public.


  "! The type describing a file resource ID.
  types y_id type string.

  "! The type describing a list of file resource IDs.
  types yt_id type standard table
    of y_id
    with non-unique default key.

  "! The type describing the name of a file resource.
  types y_name type string.

  "! The type describing a link for opening a file resource.
  types y_web_view_link type string.

  "! The type describing a mime type classifying a file content.
  types y_mime_type type string.

  "! The type describing a content type, i.e. the type of a body.
  types y_content_type type string.

  types:
    "! Describes a Google Drive file resource.
    begin of ys_file_resource,
      "! The id of the file resource.
      id            type y_id,

      "! The name of the file resource.
      name          type y_name,

      "! The mime type of the file resource.
      mime_type     type y_mime_type,

      "! A link for opening the file in a relevant Google editor or viewer in
      "! a browser.
      web_view_link type y_web_view_link,

      "! The IDs of the parent folders containing the file.
      parents       type yt_id,
    end of ys_file_resource.

  "! Describes a list of Google File resources.
  types yt_file_resource type standard table
    of ys_file_resource
    with non-unique default key.

  "! The Mime Type of a Google Spreadsheet document.
  "!
  "! See https://developers.google.com/drive/v3/web/mime-types
  constants c_google_spreadsheet_mime_type type y_mime_type
    value `application/vnd.google-apps.spreadsheet`.        "#EC NOTEXT

  constants:
    "! The enumeration of mime types supported by Google Drive.
    "!
    "! See https://developers.google.com/drive/v3/web/mime-types
    begin of cs_mime_type,
      "! The Mime Type of a folder in a Google Drive.
      folder      type y_mime_type value `application/vnd.google-apps.folder`, "#EC NOTEXT

      "! The Mime Type of a Google Spreadsheet document.
      spreadsheet type y_mime_type value `application/vnd.google-apps.spreadsheet`, "#EC NOTEXT
    end of cs_mime_type.

  "! <p>
  "! Determines if this API has a valid OAuth 2.0 token, i.e. if access is
  "! allowed. If a valid <em>access token</em> exists, this method returns
  "! <em>abap_true</em>. Otherwise it tries to request a refresh token.
  "! If a valid <em>refresh token</em> was received, <em>abap_true</em> is
  "! returned.
  "! </p>
  "! <p>
  "! In all other cases <em>abap_false</em> is returned.
  "! </p>
  "! <p>
  "! This method can be leveraged prior to any API calls in order to test if an
  "! access is allowed at all.
  "! </p>
  "!
  "! @parameter rv_has_valid_token | abap_true if a valid OAuth 2.0 exists;
  "! abap_false otherwise.
  methods has_valid_token
    returning
      value(rv_has_valid_token) type abap_bool.

  "! Lists all files in a Google Drive.
  "!
  "! @parameter rt_file_resources | The retrieved file resources; initial in
  "! case the operation failed or no files were found.
  methods list_all_files
    returning
      value(rt_file_resources) type yt_file_resource.

  "! Performs a simple file upload into a Google Drive.
  "!
  "! @parameter ir_data | The data to upload.
  "! @parameter iv_name | The name of the file.
  "! @parameter iv_content_type | The content type of the message body.
  "! @parameter rv_has_succeeded | abap_true if the upload succeeded;
  "! abap_false if it failed.
  methods simple_upload
    importing
      ir_data                 type ref to xstring
      iv_name                 type string
      iv_content_type         type y_content_type
    returning
      value(rv_has_succeeded) type abap_bool.

  "! Performs a multi part - including metadata and content - file upload
  "! into a Google Drive.
  "!
  "! @parameter ir_data | The data to upload.
  "! @parameter iv_name | The name of the file.
  "! @parameter iv_content_type | The content type of the message body.
  "! @parameter iv_mime_type | The mime type of the file in the message
  "! payload.
  "! @parameter it_parents | The IDs of the parent folders containing the file.
  "! @parameter rs_file_resource | The response data of the file resource;
  "! initial in case the operation failed.
  methods multipart_upload
    importing
      ir_data                 type ref to xstring
      iv_name                 type string
      iv_content_type         type y_content_type
      iv_mime_type            type y_mime_type
      it_parents              type yt_id optional
    returning
      value(rs_file_resource) type ys_file_resource.

  "! Creates the metadata of a file.
  "!
  "! @parameter iv_name | The name of the file.
  "! @parameter iv_mime_type | The mime type of the file.
  "! @parameter rs_file_resource | The response data of the file resource;
  "! initial in case the operation failed.
  methods create_file_metadata
    importing
      iv_name                 type y_name
      iv_mime_type            type y_mime_type
    returning
      value(rs_file_resource) type ys_file_resource.

  "! Gets the metadata of files matching the given criteria. The given
  "! search criteria are - if populated - combined with the <em>AND</em>
  "! operator.
  "!
  "! @parameter iv_name | The name of the file.
  "! @parameter iv_mime_type | The mime type of the file.
  "! @parameter rt_file_resources | The response data of the file resources;
  "! initial in case the operation failed or no matching files were found.
  methods get_files_metadata
    importing
      iv_name                  type y_name optional
      iv_mime_type             type y_mime_type optional
    returning
      value(rt_file_resources) type yt_file_resource.

  "! Gets the log written by this Google Drive API.
  "!
  "! @parameter et_log | The written log entries.
  methods get_log
    exporting
      et_log type zif_googlepoc_drive_log_api=>yt_log_enty.


endinterface.