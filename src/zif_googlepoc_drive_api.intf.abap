"! <p>
"! Interface to the <strong>Google Drive REST API</strong>.
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
interface zif_googlepoc_drive_api
  public.


  "! Describes an identifier of a file resource.
  types file_resource_id type string.

  "! Describes a list of file resource identifiers.
  types file_resource_ids type standard table
    of file_resource_id
    with empty key.

  "! Describes a name of a file resource.
  types file_resource_name type string.

  "! Describes a link for opening a file resource.
  types web_view_link type string.

  "! Describes a mime type classifying a file content.
  types mime_type type string.

  "! Describes a content type, i.e. the type of a body.
  types content_type type string.

  types:
    "! Describes a Google Drive file resource.
    begin of file_resource,
      "! The id of the file resource.
      id            type file_resource_id,

      "! The name of the file resource.
      name          type file_resource_name,

      "! The mime type of the file resource.
      mime_type     type mime_type,

      "! A link for opening the file in a relevant Google editor or viewer in a browser.
      web_view_link type web_view_link,

      "! The IDs of the parent folders containing the file.
      parents       type file_resource_ids,
    end of file_resource.

  "! Describes a list of Google File resources.
  types file_resources type standard table
    of file_resource
    with empty key.

  "! The Mime Type of a Google Spreadsheet document.
  "!
  "! <p>
  "! See https://developers.google.com/drive/v3/web/mime-types
  "! </p>
  constants google_spreadsheet_mime_type type mime_type value
    `application/vnd.google-apps.spreadsheet` ##NO_TEXT.

  constants:
    "! The enumeration of mime types supported by Google Drive.
    "!
    "! <p>
    "! See https://developers.google.com/drive/v3/web/mime-types
    "! </p>
    begin of supported_mime_types,
      "! The mime type of a <strong>folder in a Google Drive</strong>.
      folder      type mime_type value `application/vnd.google-apps.folder` ##NO_TEXT,

      "! The mime type of a <strong>Google Spreadsheet document</strong>.
      spreadsheet type mime_type value `application/vnd.google-apps.spreadsheet` ##NO_TEXT,
    end of supported_mime_types.

  "! <p>
  "! Determines if this API has a valid OAuth 2.0 token, i.e. if access is allowed. If a valid
  "! <em>access token</em> exists, this method returns <em>abap_true</em>. Otherwise it tries to
  "! request a refresh token. If a valid <em>refresh token</em> was received, <em>abap_true</em> is
  "! returned.
  "! </p>
  "! <p>
  "! In all other cases <em>abap_false</em> is returned.
  "! </p>
  "! <p>
  "! This method can be utilized prior to any API calls in order to test if an access is allowed at
  "! all.
  "! </p>
  "!
  "! @parameter result | <em>abap_true</em> if a valid OAuth 2.0 exists; <em>abap_false</em>
  "! otherwise.
  methods has_valid_token
    returning
      value(result) type abap_bool.

  "! Lists all files in a Google Drive.
  "!
  "! @parameter result | The retrieved file resources; <em>initial</em> in case the operation failed
  "! or no files were found.
  methods list_all_files
    returning
      value(result) type file_resources.

  "! Performs a simple file upload into a Google Drive.
  "!
  "! @parameter data | The data to upload.
  "! @parameter name | The name of the file.
  "! @parameter content_type | The content type of the message body.
  "! @parameter result | <em>abap_true</em> if the upload succeeded; <em>abap_false</em> if it
  "! failed.
  methods simple_upload
    importing
      data          type ref to xstring
      name          type string
      content_type  type content_type
    returning
      value(result) type abap_bool.

  "! Performs a multi part - including metadata and content - file upload into a Google Drive.
  "!
  "! @parameter data | The data to upload.
  "! @parameter name | The name of the file.
  "! @parameter content_type | The content type of the message body.
  "! @parameter mime_type | The mime type of the file in the message payload.
  "! @parameter parents | The IDs of the parent folders containing the file.
  "! @parameter result | The response data of the file resource; <em>initial</em> in case the
  "! operation failed.
  methods multipart_upload
    importing
      data          type ref to xstring
      name          type string
      content_type  type content_type
      mime_type     type mime_type
      parents       type file_resource_ids optional
    returning
      value(result) type file_resource.

  "! Creates the metadata of a file.
  "!
  "! @parameter name | The name of the file.
  "! @parameter mime_type | The mime type of the file.
  "! @parameter result | The response data of the file resource; <em>initial</em> in case the
  "! operation failed.
  methods create_file_metadata
    importing
      name          type file_resource_name
      mime_type     type mime_type
    returning
      value(result) type file_resource.

  "! Gets the metadata of files matching the given criteria. The given search criteria are -
  "! if populated - combined with the <em>AND</em> operator.
  "!
  "! @parameter name | The name of the file.
  "! @parameter mime_type | The mime type of the file.
  "! @parameter result | The response data of the file resources; <em>initial</em> in case the
  "! operation failed or no matching files were found.
  methods get_files_metadata
    importing
      name          type file_resource_name optional
      mime_type     type mime_type optional
    returning
      value(result) type file_resources.

  "! Gets the log written by this Google Drive API.
  "!
  "! @parameter result | The written log entries.
  methods get_log
    exporting
      result type zif_googlepoc_drive_log_api=>log_entries.


endinterface.
