"! <p>
"! Interface to the <strong>JSON API</strong> to deal with requests and responses sent respectively
"! received from the <strong>Google Drive REST API</strong>.
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
interface zif_googlepoc_drive_json_api
  public.


  constants:
    "! Enumeration of the <strong>field names</strong> in a Google Drive <em>File Resource</em>.
    "!
    "! <p>
    "! See https://developers.google.com/drive/v3/reference/files?hl=de#resource
    "! </p>
    begin of file_resource_fields,
      "! The id of the file.
      id            type string value `id` ##NO_TEXT,

      "! The name of the file. This is not necessarily unique within a folder. Note that for
      "! immutable items such as the top level folders of Team Drives, My Drive root folder, and
      "! Application Data folder the name is constant.
      name          type string value `name` ##NO_TEXT,

      "! The MIME type of the file. Drive will attempt to automatically detect an appropriate value
      "! from uploaded content if no value is provided. The value cannot be changed unless a new
      "! revision is uploaded. If a file is created with a Google Doc MIME type, the uploaded
      "! content will be imported if possible. The supported import formats are published in the
      "! About resource.
      mime_type     type string value `mimeType` ##NO_TEXT,

      "! The time at which the file was created (RFC 3339 date-time).
      created_time  type string value `createdTime` ##NO_TEXT,

      "! A link for opening the file in a relevant Google editor or viewer in a browser.
      web_view_link type string value `webViewLink` ##NO_TEXT,

      "! The IDs of the parent folders which contain the file.
      parents       type string value `parents` ##NO_TEXT,
    end of file_resource_fields.

  constants:
    "! Enumeration of the <strong>field names</strong> in a Google Drive <em>Files Resource
    "! List</em>.
    "!
    "! <p>
    "! See https://developers.google.com/drive/v3/reference/files?hl=de#resource
    "! </p>
    begin of file_resource_list_fields,
      "! Identifies what kind of resource this is. Value: the fixed string "drive#fileList".
      kind              type string value `kind` ##NO_TEXT,

      "! The page token for the next page of files. This will be absent if the end of the files list
      "! has been reached. If the token is rejected for any reason, it should be discarded, and
      "! pagination should be restarted from the first page of results.
      next_page_token   type string value `nextPageToken` ##NO_TEXT,

      "! Whether the search process was incomplete. If true, then some search results may be
      "! missing, since all documents were not searched. This may occur when searching multiple Team
      "! Drives with the "user, allTeamDrives" corpora, but all corpora could not be searched. When
      "! this happens, it is suggested that clients narrow their query by choosing a different
      "! corpus such as "user" or "teamDrive".
      incomplete_search type string value `incompleteSearch` ##NO_TEXT,

      "! The list of files. If nextPageToken is populated, then this list may be incomplete and an
      "! additional page of results should be fetched.
      files             type string value `files` ##NO_TEXT,
    end of file_resource_list_fields.

  "! Creates a Drive File Resource meta data in JSON format.
  "!
  "! @parameter id | The ID of the file resource.
  "! @parameter name | The name of the file resource.
  "! @parameter mime_type | The mime type of the file resource.
  "! @parameter parents | The IDs of the parent folders containing the file.
  "! @parameter result | The created meta data in JSON format.
  methods create_file_resource
    importing
      id            type zif_googlepoc_drive_api=>file_resource_id optional
      name          type zif_googlepoc_drive_api=>file_resource_name
      mime_type     type zif_googlepoc_drive_api=>mime_type
      parents       type zif_googlepoc_drive_api=>file_resource_ids optional
    returning
      value(result) type string.

  "! Parses a Drive File Resource response in JSON format.
  "!
  "! @parameter file_resource_json | The response to parse.
  "! @parameter result | The parsed file resource.
  methods parse_file_resource
    importing
      file_resource_json type string
    returning
      value(result)      type zif_googlepoc_drive_api=>file_resource.

  "! Parses a Drive File Resource List response in JSON format.
  "!
  "! @parameter file_resource_list_json | The response to parse.
  "! @parameter result | The parsed list of file resources.
  methods parse_file_resource_list
    importing
      file_resource_list_json type string
    exporting
      result                  type zif_googlepoc_drive_api=>file_resources.

  "! Sets the logging API.
  "!
  "! @parameter api | The logging API to use.
  methods set_log_api
    importing
      api type ref to zif_googlepoc_drive_log_api.


endinterface.
