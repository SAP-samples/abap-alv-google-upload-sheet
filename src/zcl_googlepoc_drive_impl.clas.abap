"! <p>
"! Invokes the Google Drive REST API. Authentication is done via ABAP OAuth 2.0 Client with Google
"! specific configuration profile.
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
class zcl_googlepoc_drive_impl definition
  public
  create public
  final.


  public section.

    interfaces zif_googlepoc_drive_api.

    aliases has_valid_token
      for zif_googlepoc_drive_api~has_valid_token.
    aliases list_all_files
      for zif_googlepoc_drive_api~list_all_files.
    aliases simple_upload
      for zif_googlepoc_drive_api~simple_upload.
    aliases multipart_upload
      for zif_googlepoc_drive_api~multipart_upload.
    aliases create_file_metadata
      for zif_googlepoc_drive_api~create_file_metadata.
    aliases get_files_metadata
      for zif_googlepoc_drive_api~get_files_metadata.
    aliases get_log
      for zif_googlepoc_drive_api~get_log.

    "! The default OAuth 2.0 profile to use.
    constants default_oauth_20_profile type oa2c_profile value 'Z_GOOGLE_SHEETS' ##NO_TEXT.

    "! Constructs a new Google Drive REST API instance.
    "!
    "! @parameter oa2c_profile_name | The name of the OAuth 2.0 profile to use.
    "! @parameter json_api | The Google Drive JSON API to use for creating and parsing JSON content
    "! sent respectively received using this Google Drive REST API.
    "!
    "! @raising cx_oa2c_config_not_found | In case the OAuth 2.0 client configuration was not found.
    "! @raising cx_oa2c_config_profile_assign | In case the given profile was not assigned to an
    "! OAuth 2.0 client configuration.
    "! @raising cx_oa2c_kernel_too_old | In case the system kernel is too old - meaning that the
    "! OAuth 2.0 backend support does not exist or is not sufficient.
    "! @raising cx_oa2c_missing_authorization | In case the required authorization (S_OA2C_USE) for
    "! creating and using an OAuth 2.0 client were not granted.
    "! @raising cx_oa2c_config_profile_multi | In case the OAuth 2.0 Client Configuration Profile
    "! was assigned multiple times.
    methods constructor
      importing
        oa2c_profile_name type oa2c_profile optional
        json_api          type ref to zif_googlepoc_drive_json_api
      raising
        cx_oa2c_config_not_found
        cx_oa2c_config_profile_assign
        cx_oa2c_kernel_too_old
        cx_oa2c_missing_authorization
        cx_oa2c_config_profile_multi.


  private section.

    types:
      "! Describes a HTTP response.
      begin of http_response,
        "! The status code.
        status_code   type i,

        "! The content type.
        content_type  type string,

        "! The received data.
        data          type string,

        "! The header fields in shape of name/value pairs.
        header_fields type tihttpnvp,
      end of http_response.

    "! The SSL id to use for creating HTTP clients.
    constants default_ssl_id type ssfapplssl value 'ANONYM' ##NO_TEXT.

    "! The <em>UTF-8</em> encoding representation.
    constants utf8_encoding type string value `UTF-8` ##NO_TEXT.

    "! The HTTP status code <em>SUCCESS_OK</em>.
    constants http_status_success_ok type i value 200 ##NO_TEXT.

    constants:
      "! Enumeration of the supported content types.
      begin of supported_content_types,
        "! The <em>JSON</em> content type.
        json      type string value `application/json` ##NO_TEXT,

        "! The <em>multi part</em> content type.
        multipart type string value `multipart/related` ##NO_TEXT,
      end of supported_content_types.

    constants:
      "! Enumeration of the supported available Google Drive query parameters of the <em>Files: list
      "! REST API</em>.
      begin of files_query_parameters,
        "! The name of the Google Drive <em>fields</em> query parameter to request a partial
        "! response.
        "!
        "! <p>
        "! See https://developers.google.com/drive/v3/web/performance#partial
        "! </p>
        fields type string value `fields` ##NO_TEXT,

        "! The name of the parameter to <em>query</em> for filtering the file results.
        "!
        "! <p>
        "! See https://developers.google.com/drive/v3/web/search-parameters
        "! </p>
        query  type string value `q` ##NO_TEXT,
      end of files_query_parameters.

    constants:
      "! Enumeration of the supported available Google Drive query parameters of the <em>Files: list
      "! REST API</em>.
      begin of files_search_fields,
        "! The <em>name</em> of the file.
        name      type string value `name` ##NO_TEXT,

        "! The <em>mime type</em> of the file.
        mime_type type string value `mimeType` ##NO_TEXT,
      end of files_search_fields.

    constants:
      "! Enumeration of the supported available Google Drive REST API target <em>URIs</em>.
      begin of google_drive_rest_api_uris,
        list_files       type string value `https://www.googleapis.com/drive/v3/files` ##NO_TEXT,

        file_metadata    type string value `https://www.googleapis.com/drive/v3/files` ##NO_TEXT,

        simple_upload    type string value
          `https://www.googleapis.com/upload/drive/v3/files?uploadType=media` ##NO_TEXT,

        multipart_upload type string value
          `https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart` ##NO_TEXT,
      end of google_drive_rest_api_uris.

    "! The OAuth 2.0 Client used by this Drive API.
    data oauth_client type ref to if_oauth2_client.

    "! The HTPP Client used by this Drive API.
    data http_client type ref to if_http_client.

    "! The OA2C profile name.
    data oa2c_profile_name type oa2c_profile.

    "! The used Google Drive JSON API.
    data json_api type ref to zif_googlepoc_drive_json_api.

    "! The used Logging API.
    data log_api type ref to zif_googlepoc_drive_log_api.

    "! Determines if the given HTTP(S) request has succeeded.
    "!
    "! @parameter http_status_code | The HTTP status code to verify.
    "! @parameter result | <em>abap_true</em> if the request has succeeded; <em>abap_false</em> if
    "! it has failed.
    class-methods has_request_succeeded
      importing
        http_status_code type i
      returning
        value(result)    type abap_bool.

    "! Creates the OAuth 2.0 Client instance.
    "!
    "! @raising cx_oa2c_config_not_found | In case the OAuth 2.0 client configuration was not found.
    "! @raising cx_oa2c_config_profile_assign | In case the given profile was not assigned to an
    "! OAuth 2.0 client configuration.
    "! @raising cx_oa2c_kernel_too_old | In case the system kernel is too old - meaning that the
    "! OAuth 2.0 backend support does not exist or is not sufficient.
    "! @raising cx_oa2c_missing_authorization | In case the required authorization (S_OA2C_USE) for
    "! creating and using an OAuth 2.0 client were not granted.
    "! @raising cx_oa2c_config_profile_multi | In case the OAuth 2.0 Client Configuration Profile
    "! was assigned multiple times.
    methods create_oauth_client
      raising
        cx_oa2c_config_not_found
        cx_oa2c_config_profile_assign
        cx_oa2c_kernel_too_old
        cx_oa2c_missing_authorization
        cx_oa2c_config_profile_multi .

    "! Gets the OAuth 2.0 profile to use for creating the OAuth 2.0 Client.
    "!
    "! @parameter result | The determined profile.
    methods get_oauth_profile
      returning
        value(result) type oa2c_profile.

    "! Sets the OAuth 2.0 token on the previously established HTTP(S) connection.
    "!
    "! @parameter result | <em>abap_true</em> if the token has been successfully set;
    "! <em>abap_false</em> if the operation failed.
    methods set_oauth_token
      returning
        value(result) type abap_bool.

    "! Opens a HTTP(S) connection to the given URL using the specified method.
    "!
    "! @parameter url | The URL to connect to.
    "! @parameter method | The method (GET, POST, PUT, DELETE, OPTIONS) to use.
    "! @parameter header_fields | The header fields to set on the request.
    "! @parameter form_fields | The form fields to set on the request.
    "! @parameter result | <em>abap_true</em> if the connection has been successfully established;
    "! <em>abap_false</em> if the connection attempt failed.
    methods open_connection
      importing
        url           type string
        method        type string
        header_fields type tihttpnvp optional
        form_fields   type tihttpnvp optional
      returning
        value(result) type abap_bool.

    "! Closes a previously opened HTTP(S) connection.
    methods close_connection.

    "! Prepares a request for the previously opened HTTP(S) connection.
    "!
    "! @parameter method | The method (GET, POST, PUT, DELETE, OPTIONS) to use.
    "! @parameter header_fields | The header fields to set on the request.
    "! @parameter form_fields | The form fields to set on the request.
    methods prepare_request
      importing
        method        type string
        header_fields type tihttpnvp optional
        form_fields   type tihttpnvp optional.

    "! Sends the HTTP(S) request and receives the response.
    "!
    "! @parameter response | The received response.
    methods send_receive
      returning
        value(response) type http_response.


endclass.


class zcl_googlepoc_drive_impl implementation.


  method constructor.
    me->oa2c_profile_name = oa2c_profile_name.
    me->json_api = json_api.

    me->log_api = new zcl_googlepoc_drive_log_impl( ).
    me->json_api->set_log_api( me->log_api ).

    me->create_oauth_client( ).
  endmethod.


  method zif_googlepoc_drive_api~create_file_metadata.
    data metadata type string.
    data response type http_response.

    data(is_connection_open) =
      me->open_connection(
        url    = google_drive_rest_api_uris-file_metadata
              && |?{ files_query_parameters-fields }=|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-id },|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-web_view_link }|
        method = if_http_entity=>co_request_method_post ).
    if is_connection_open = abap_true.
      me->http_client->request->set_content_type(
        |{ supported_content_types-json };charset={ utf8_encoding }| ) ##NO_TEXT.
      metadata = me->json_api->create_file_resource( name      = name
                                                     mime_type = mime_type ).
      me->http_client->request->set_cdata( metadata ).

      response = me->send_receive( ).
      me->close_connection( ).

      if has_request_succeeded( response-status_code ) = abap_true.
        result = me->json_api->parse_file_resource( response-data ).
        if result is not initial.
          result-name = name.
          result-mime_type = mime_type.
        endif.
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~get_files_metadata.
    data search_parameters type string.
    if name is not initial.
      search_parameters = escape( val    = |{ files_search_fields-name }='{ name }'|
                                  format = cl_abap_format=>e_url_full ) ##NO_TEXT.
    endif.

    if mime_type is not initial.
      if search_parameters is not initial.
        search_parameters = search_parameters && ` and ` ##NO_TEXT.
      endif.
      search_parameters = search_parameters
        && escape( val    = |{ files_search_fields-mime_type }='{ mime_type }'|
                   format = cl_abap_format=>e_url_full ) ##NO_TEXT.
    endif.

    data(url) = google_drive_rest_api_uris-list_files
             && |?{ files_query_parameters-fields }=|
             && |{ zif_googlepoc_drive_json_api=>file_resource_list_fields-files }(|
             && |{ zif_googlepoc_drive_json_api=>file_resource_fields-id },|
             && |{ zif_googlepoc_drive_json_api=>file_resource_fields-name },|
             && |{ zif_googlepoc_drive_json_api=>file_resource_fields-mime_type },|
             && |{ zif_googlepoc_drive_json_api=>file_resource_fields-web_view_link },|
             && |{ zif_googlepoc_drive_json_api=>file_resource_fields-parents })| ##NO_TEXT.

    if search_parameters is not initial.
      url = |{ url }&{ files_query_parameters-query }={ search_parameters }| ##NO_TEXT.
    endif.

    data response type http_response.
    data(is_connection_open) = me->open_connection(
                                 url    = url
                                 method = if_http_entity=>co_request_method_get ).
    if is_connection_open = abap_true.
      response = me->send_receive( ).
      me->close_connection( ).

      if has_request_succeeded( response-status_code ) = abap_true.
        me->json_api->parse_file_resource_list(
          exporting
            file_resource_list_json = response-data
          importing
            result                  = result
        ).
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~get_log.
    clear result.
    result = me->log_api->entries.
  endmethod.


  method zif_googlepoc_drive_api~has_valid_token.
    result = me->open_connection(
      url    = google_drive_rest_api_uris-list_files
            && |?{ files_query_parameters-fields }=|
            && |{ zif_googlepoc_drive_json_api=>file_resource_list_fields-files }(|
            && |{ zif_googlepoc_drive_json_api=>file_resource_fields-id },|
            && |{ zif_googlepoc_drive_json_api=>file_resource_fields-name })|
      method = if_http_entity=>co_request_method_get ) ##NO_TEXT.
    me->close_connection( ).
  endmethod.


  method zif_googlepoc_drive_api~list_all_files.
    data response type http_response.

    data(is_connection_open) =
      me->open_connection(
        url    = google_drive_rest_api_uris-list_files
              && |?{ files_query_parameters-fields }=|
              && |{ zif_googlepoc_drive_json_api=>file_resource_list_fields-files }(|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-id },|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-name },|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-mime_type },|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-web_view_link },|
              && |{ zif_googlepoc_drive_json_api=>file_resource_fields-parents })|
        method = if_http_entity=>co_request_method_get ) ##NO_TEXT.
    if is_connection_open = abap_true.
      response = me->send_receive( ).
      me->close_connection( ).

      if has_request_succeeded( response-status_code ) = abap_true.
        me->json_api->parse_file_resource_list(
          exporting
            file_resource_list_json = response-data
          importing
            result                  = result
        ).
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~multipart_upload.
    data metadata type string.
    data response type http_response.

    data(is_connection_open) =
      me->open_connection(
         url = google_drive_rest_api_uris-multipart_upload
           && |&{ files_query_parameters-fields }=|
           && |{ zif_googlepoc_drive_json_api=>file_resource_fields-id },|
           && |{ zif_googlepoc_drive_json_api=>file_resource_fields-web_view_link }|
      method = if_http_entity=>co_request_method_post ) ##NO_TEXT.
    if is_connection_open = abap_true.
      me->http_client->request->set_content_type( supported_content_types-multipart ).

      data(lo_entity) = me->http_client->request->add_multipart( ).
      lo_entity->set_content_type(
        |{ supported_content_types-json };charset={ utf8_encoding }| ) ##NO_TEXT.
      metadata = me->json_api->create_file_resource( name      = name
                                                     mime_type = mime_type
                                                     parents   = parents ).
      lo_entity->set_cdata( metadata ).

      lo_entity = me->http_client->request->add_multipart( ).
      lo_entity->set_content_type( content_type ).
      lo_entity->set_data( data = data->* ).

      response = me->send_receive( ).
      me->close_connection( ).

      if has_request_succeeded( response-status_code ) = abap_true.
        result = me->json_api->parse_file_resource( response-data ).
        if result is not initial.
          result-name = name.
          result-mime_type = mime_type.
          result-parents = parents.
        endif.
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~simple_upload.
    data response type http_response.

    data(is_connection_open) = me->open_connection(
                                 url    = google_drive_rest_api_uris-simple_upload
                                 method = if_http_entity=>co_request_method_post ).
    if is_connection_open = abap_true.
      me->http_client->request->set_content_type( content_type ).
      me->http_client->request->set_data( data->* ).

      response = me->send_receive( ).
      me->close_connection( ).

      result = has_request_succeeded( response-status_code ).
    endif.
  endmethod.


  method close_connection.
    if me->http_client is bound.
      me->http_client->close(
        exceptions
          http_invalid_state = 1
          others             = 2 ).
      if sy-subrc <> 0.
        me->log_api->log( |Error closing HTTP connection: Error Code ({ sy-subrc })| ) ##NO_TEXT.
      endif.
    endif.

    clear: me->http_client.
  endmethod.


  method create_oauth_client.
    data(profile) = me->get_oauth_profile( ).
    me->oauth_client = cl_oauth2_client=>create( profile ).
  endmethod.


  method get_oauth_profile.
    result = me->oa2c_profile_name.

    if result is initial.
      result = default_oauth_20_profile.
    endif.
  endmethod.


  method has_request_succeeded.
    result = cond #( when http_status_code = http_status_success_ok
                     then abap_true
                     else abap_false ).
  endmethod.


  method open_connection.
    cl_http_client=>create_by_url(
      exporting
        url                = url
        ssl_id             = default_ssl_id
      importing
        client             = me->http_client
      exceptions
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        others             = 4 ).
    if sy-subrc = 0.
      me->prepare_request( method        = method
                           header_fields = header_fields
                           form_fields   = form_fields ).
      result = me->set_oauth_token( ).
    else.
      me->log_api->log( |Error creating HTTP connection: Error Code ({ sy-subrc })| ) ##NO_TEXT.
      result = abap_false.
    endif.
  endmethod.


  method prepare_request.
    "Turn off logon popup. Detect authentication errors.
    me->http_client->propertytype_logon_popup = 0.
    me->http_client->request->set_method( method ).

    if  header_fields is supplied
    and header_fields is not initial.
      me->http_client->request->set_header_fields( header_fields ).
    endif.

    if  form_fields is supplied
    and form_fields is not initial.
      me->http_client->request->set_form_fields( form_fields ).
    endif.
  endmethod.


  method send_receive.
    clear response.

    me->http_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        others                     = 5 ).
    if sy-subrc <> 0.
      me->log_api->log( |Error sending HTTP request: Error Code ({ sy-subrc })| ) ##NO_TEXT.
    endif.

    me->http_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others                     = 4 ).
    if sy-subrc <> 0.
      me->log_api->log( |Error receiving HTTP request: Error Code ({ sy-subrc })| ) ##NO_TEXT.
    endif.

    "Fill response structure.
    me->http_client->response->get_status(
      importing
        code = response-status_code ).
    response-data = me->http_client->response->get_cdata( ).
    response-content_type = me->http_client->response->get_content_type( ).
    me->http_client->response->get_header_fields(
      changing
        fields = response-header_fields ).

    me->log_api->log( |HTTP request sent: Status Code ({ response-status_code })| ) ##NO_TEXT.
  endmethod.


  method set_oauth_token.
    try.
        me->oauth_client->set_token( io_http_client = me->http_client
                                     i_param_kind   = if_oauth2_client=>c_param_kind_form_field ).
      catch cx_oa2c into data(oauth_exc).
        try.
            me->oauth_client->execute_refresh_flow( ).
          catch cx_oa2c into oauth_exc.
            me->log_api->log( |Error executing OAuth 2.0 refresh flow: |
                           && |{ oauth_exc->get_text( ) }| ) ##NO_TEXT.
            result = abap_false.
            return.
        endtry.

        try.
            me->oauth_client->set_token(
              io_http_client = me->http_client
              i_param_kind   = if_oauth2_client=>c_param_kind_form_field ).
          catch cx_oa2c into oauth_exc.
            me->log_api->log( |Error setting OAuth 2.0 token: |
                           && |{ oauth_exc->get_text( ) }| ) ##NO_TEXT.
            result = abap_false.
            return.
        endtry.
    endtry.

    result = abap_true.
  endmethod.


endclass.
