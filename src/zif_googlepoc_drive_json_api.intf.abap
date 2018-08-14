"! <p>
"! Interface to the JSON API to deal with requests and responses sent
"! respectively received from the Google Drive REST API.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
interface zif_googlepoc_drive_json_api
  public.


  constants:
    "! Enumeration of the field names in a Google Drive File Resource.
    "!
    "! See https://developers.google.com/drive/v3/reference/files?hl=de#resource
    begin of file_resource_field,
      "! The id of the file.
      id            type string value `id`,                 "#EC NOTEXT

      "! The name of the file. This is not necessarily unique within a folder.
      "! Note that for immutable items such as the top level folders of Team
      "! Drives, My Drive root folder, and Application Data folder the name
      "! is constant.
      name          type string value `name`,               "#EC NOTEXT

      "! The MIME type of the file. Drive will attempt to automatically detect
      "! an appropriate value from uploaded content if no value is provided.
      "! The value cannot be changed unless a new revision is uploaded. If a
      "! file is created with a Google Doc MIME type, the uploaded content
      "! will be imported if possible. The supported import formats are
      "! published in the About resource.
      mime_type     type string value `mimeType`,           "#EC NOTEXT

      "! The time at which the file was created (RFC 3339 date-time).
      created_time  type string value `createdTime`,        "#EC NOTEXT

      "! A link for opening the file in a relevant Google editor or viewer in
      "! a browser.
      web_view_link type string value `webViewLink`,        "#EC NOTEXT

      "! The IDs of the parent folders which contain the file.
      parents       type string value `parents`,            "#EC NOTEXT
    end of file_resource_field.

  constants:
    "! Enumeration of the field names in a Google Drive Files Resource List
    "!
    "! See https://developers.google.com/drive/v3/reference/files?hl=de#resource
    begin of files_resource_list_field,
      "! Identifies what kind of resource this is. Value: the fixed string
      "! "drive#fileList".
      kind              type string value `kind`,           "#EC NOTEXT

      "! The page token for the next page of files. This will be absent if
      "! the end of the files list has been reached. If the token is rejected
      "! for any reason, it should be discarded, and pagination should be
      "! restarted from the first page of results.
      next_page_token   type string value `nextPageToken`,  "#EC NOTEXT

      "! Whether the search process was incomplete. If true, then some search
      "! results may be missing, since all documents were not searched. This
      "! may occur when searching multiple Team Drives with the "user,
      "! allTeamDrives" corpora, but all corpora could not be searched. When
      "! this happens, it is suggested that clients narrow their query by
      "! choosing a different corpus such as "user" or "teamDrive".
      incomplete_search type string value `incompleteSearch`, "#EC NOTEXT

      "! The list of files. If nextPageToken is populated, then this list may
      "! be incomplete and an additional page of results should be fetched.
      files             type string value `files`,          "#EC NOTEXT
    end of files_resource_list_field.

  "! Creates a Drive File Resource meta data in JSON format.
  "!
  "! @parameter iv_id | The ID of the file resource.
  "! @parameter iv_name | The name of the file resource.
  "! @parameter iv_mime_type | The MIME type of the file resource.
  "! @parameter it_parents | The IDs of the parent folders containing the
  "! file.
  "! @parameter rv_metadata_json | The created meta data in JSON format.
  methods create_file_resource
    importing
      iv_id                        type zif_googlepoc_drive_api=>y_id optional
      iv_name                      type zif_googlepoc_drive_api=>y_name
      iv_mime_type                 type zif_googlepoc_drive_api=>y_mime_type
      it_parents                   type zif_googlepoc_drive_api=>yt_id optional
    returning
      value(rv_file_resource_json) type string.

  "! Parses a Drive File Resource response in JSON format.
  "!
  "! @parameter iv_file_resource_json | The response to parse.
  "! @parameter rs_file_resource | The parsed file resource.
  methods parse_file_resource
    importing
      iv_file_resource_json   type string
    returning
      value(rs_file_resource) type zif_googlepoc_drive_api=>ys_file_resource.

  "! Parses a Drive File Resource List response in JSON format.
  "!
  "! @parameter iv_file_resource_list_json | The response to parse.
  "! @parameter et_file_resources | The parsed list of file resources.
  methods parse_file_resource_list
    importing
      iv_file_resource_list_json type string
    exporting
      et_file_resources          type zif_googlepoc_drive_api=>yt_file_resource.

  "! Sets the logging API.
  "!
  "! @parameter io_log_api | The logging API to use.
  methods set_log_api
    importing
      io_log_api type ref to zif_googlepoc_drive_log_api.


endinterface.
