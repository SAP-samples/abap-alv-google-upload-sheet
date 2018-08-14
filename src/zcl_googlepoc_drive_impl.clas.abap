"! <p>
"! Invokes the Google Drive REST API. Authentication is done via ABAP OAuth 2.0
"! Client with Google specific configuration profile.
"! </p>
"!
"! <p>
"! Uses the internal <em>WDR JSON Library</em>.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
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
    constants c_default_oauth_20_profile type oa2c_profile
      value 'Z_GOOGLE_SHEETS'.                          "#EC NOTEXT

    "! Constructs a new Google Drive REST API instance.
    "!
    "! @parameter iv_oa2c_profile_name | The name of the OAuth 2.0 profile to
    "! use.
    "! @parameter io_drive_json_api | The Google Drive JSON API to use for
    "! creating and parsing JSOn content sent respectively received using
    "! this Google Drive REST API.
    "!
    "! @raising cx_oa2c_config_not_found | In case the OAuth 2.0 client
    "! configuration was not found.
    "! @raising cx_oa2c_config_profile_assign | In case the given profile was
    "! not assigned to an OAuth 2.0 client configuration.
    "! @raising cx_oa2c_kernel_too_old | In case the system kernel is too old -
    "! meaning that the OAuth 2.0 backend support does not exist or is not
    "! sufficient.
    "! @raising cx_oa2c_missing_authorization | In case the required
    "! authorization (S_OA2C_USE) for creating and using an OAuth 2.0 client
    "! were not granted.
    methods constructor
      importing
        iv_oa2c_profile_name type oa2c_profile optional
        io_drive_json_api    type ref to zif_googlepoc_drive_json_api
      raising
        cx_oa2c_config_not_found
        cx_oa2c_config_profile_assign
        cx_oa2c_kernel_too_old
        cx_oa2c_missing_authorization.


  private section.

    types:
      "! Describes a HTTP response.
      begin of ys_response,
        "! The status code.
        status_code   type i,

        "! The content type.
        content_type  type string,

        "! The received data.
        data          type string,

        "! The header fields in shape of name/value pairs.
        header_fields type tihttpnvp,
      end of ys_response.

    "! The SSL id to use for creating HTTP clients.
    constants c_ssl_id type ssfapplssl value 'ANONYM'.      "#EC NOTEXT

    "! The UTF-8 encoding representation.
    constants c_encoding_utf8 type string value `UTF-8`.    "#EC NOTEXT

    "! The HTTP status code SUCCESS_OK.
    constants c_http_status_success_ok type i value 200 .   "#EC NOTEXT

    constants:
      "! Enumeration of the used content types.
      begin of cs_content_type,
        "! The JSON content type.
        json      type string value `application/json`,     "#EC NOTEXT

        "! The multi part content type.
        multipart type string value `multipart/related`,    "#EC NOTEXT
      end of cs_content_type.

    constants:
      "! Enumeration of the supported available Google Drive query parameters
      "! of the Files: list REST API.
      begin of cs_files_query_parameter,
        "! The name of the Google Drive FIELDS query parameter to request a
        "! partial
        "! response.
        "!
        "! See https://developers.google.com/drive/v3/web/performance#partial
        fields type string value `fields`,                  "#EC NOTEXT

        "! The name of the parameter to query for filtering the file results.
        "! See https://developers.google.com/drive/v3/web/search-parameters
        query  type string value `q`,                       "#EC NOTEXT
      end of cs_files_query_parameter.

    constants:
      "! Enumeration of the supported available Google Drive query parameters
      "! of the Files: list REST API.
      begin of cs_files_search_field,
        "! The name of the file.
        name      type string value `name`,                 "#EC NOTEXT

        "! The MIME type of the file.
        mime_type type string value `mimeType`,             "#EC NOTEXT
      end of cs_files_search_field.

    constants:
      "! Enumeration of the supported available Google Drive REST API
      "! target URIs.
      begin of cs_google_drive_rest_api_uri,
        list_files       type string
          value `https://www.googleapis.com/drive/v3/files`, "#EC NOTEXT

        file_metadata    type string
          value `https://www.googleapis.com/drive/v3/files`, "#EC NOTEXT

        simple_upload    type string
          value `https://www.googleapis.com/upload/drive/v3/files?uploadType=media`, "#EC NOTEXT

        multipart_upload type string
          value `https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart`, "#EC NOTEXT
      end of cs_google_drive_rest_api_uri.

    "! The OAuth 2.0 Client used by this Drive API.
    data mo_oauth_client type ref to if_oauth2_client.

    "! The HTPP Client used by this Drive API.
    data mo_http_client type ref to if_http_client.

    "! The OA2C Profile Name.
    data mv_oa2c_profile_name type oa2c_profile.

    "! The used Google Drive JSON API.
    data mo_json_api type ref to zif_googlepoc_drive_json_api.

    "! The used logging API.
    data mo_log_api type ref to zif_googlepoc_drive_log_api.

    "! Determines if the given HTTP(S) request has succeeded.
    "!
    "! @parameter iv_http_status_code | The HTTP status code to verify.
    "! @parameter rv_has_succeeded | abap_true if the request has succeeded;
    "! abap_false otherwise.
    class-methods has_request_succeeded
      importing
        iv_http_status_code     type i
      returning
        value(rv_has_succeeded) type abap_bool.

    "! Creates the OAuth 2.0 client instance.
    "!
    "! @raising cx_oa2c_config_not_found | In case the OAuth 2.0 client
    "! configuration was not found.
    "! @raising cx_oa2c_config_profile_assign | In case the given profile was
    "! not assigned to an OAuth 2.0 client configuration.
    "! @raising cx_oa2c_kernel_too_old | In case the system kernel is too old -
    "! meaning that the OAuth 2.0 backend support does not exist or is not
    "! sufficient.
    "! @raising cx_oa2c_missing_authorization | In case the required
    "! authorization (S_OA2C_USE) for creating and using an OAuth 2.0 client
    "! were not granted.
    methods create_oauth_client
      raising
        cx_oa2c_config_not_found
        cx_oa2c_config_profile_assign
        cx_oa2c_kernel_too_old
        cx_oa2c_missing_authorization.

    "! Gets the OAuth 2.0 profile to use for creating the OAuth 2.0 client.
    "!
    "! @parameter rv_profile | The determined profile.
    methods get_oauth_profile
      returning
        value(rv_profile) type oa2c_profile.

    "! Sets the OAuth 2.0 token on the previously established HTTP(S)
    "! connection.
    "!
    "! @parameter rv_has_succeeded | abap_true if the token has been
    "! successfully set; abap_false if the operation failed.
    methods set_oauth_token
      returning
        value(rv_has_succeeded) type abap_bool.

    "! Opens a HTTP(S) connection to the given URL using the specified method.
    "!
    "! @parameter iv_url | The URL to connect to.
    "! @parameter iv_method | The method (GET, POST, PUT, DELETE, OPTIONS) to
    "! use.
    "! @parameter it_header_fields | The header fields to set on the request.
    "! @parameter it_form_fields | The form fields to set on the request.
    "! @parameter rv_has_succeeded | abap_true if the connection has been
    "! successfully established; abap_false if the connection attempt failed.
    methods open_connection
      importing
        iv_url                  type string
        iv_method               type string
        it_header_fields        type tihttpnvp optional
        it_form_fields          type tihttpnvp optional
      returning
        value(rv_has_succeeded) type abap_bool.

    "! Closes the previously opened HTTP(S) connection.
    methods close_connection.

    "! Prepares a request for the previously opened HTTP(S) connection.
    "!
    "! @parameter iv_method | The method (GET, POST, PUT, DELETE, OPTIONS) to
    "! use.
    "! @parameter it_header_fields | The header fields to set on the request.
    "! @parameter it_form_fields | The form fields to set on the request.
    methods prepare_request
      importing
        iv_method        type string
        it_header_fields type tihttpnvp optional
        it_form_fields   type tihttpnvp optional.

    "! Sends the HTTP(S) request and receives the response.
    "!
    "! @parameter es_response | The received response.
    methods send_receive
      exporting
        es_response type ys_response.


endclass.


class zcl_googlepoc_drive_impl implementation.


  method close_connection.
    if me->mo_http_client is bound.
      me->mo_http_client->close(
        exceptions
          http_invalid_state = 1
          others             = 2
      ).
      if sy-subrc <> 0.
        me->mo_log_api->log(
          |Error closing HTTP connection: Error Code ({ sy-subrc })|
        ).                                                  "#EC NOTEXT
      endif.
    endif.

    clear: me->mo_http_client.
  endmethod.


  method constructor.
    me->mv_oa2c_profile_name = iv_oa2c_profile_name.
    me->mo_json_api = io_drive_json_api.

    me->mo_log_api = new zcl_googlepoc_drive_log_impl( ).
    me->mo_json_api->set_log_api( me->mo_log_api ).

    me->create_oauth_client( ).
  endmethod.


  method create_oauth_client.
    data(lv_profile) = me->get_oauth_profile( ).
    me->mo_oauth_client = cl_oauth2_client=>create( lv_profile ).
  endmethod.


  method get_oauth_profile.
    rv_profile = me->mv_oa2c_profile_name.

    if rv_profile is initial.
      rv_profile = c_default_oauth_20_profile.
    endif.
  endmethod.


  method has_request_succeeded.
    rv_has_succeeded = cond abap_bool(
      when iv_http_status_code = c_http_status_success_ok
      then abap_true
      else abap_false
    ).
  endmethod.


  method open_connection.
    cl_http_client=>create_by_url(
      exporting
        url                = iv_url
        ssl_id             = c_ssl_id
      importing
        client             = me->mo_http_client
      exceptions
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        others             = 4
    ).
    if sy-subrc = 0.
      me->prepare_request(
        iv_method        = iv_method
        it_header_fields = it_header_fields
        it_form_fields   = it_form_fields
      ).

      rv_has_succeeded = me->set_oauth_token( ).
    else.
      me->mo_log_api->log(
        |Error creating HTTP connection: Error Code ({ sy-subrc })|
      ).                                                    "#EC NOTEXT
      rv_has_succeeded = abap_false.
    endif.
  endmethod.


  method prepare_request.
    "Turn off logon popup. Detect authentication errors.
    me->mo_http_client->propertytype_logon_popup = 0.
    me->mo_http_client->request->set_method( iv_method ).

    if  it_header_fields is supplied
    and it_header_fields is not initial.
      me->mo_http_client->request->set_header_fields( it_header_fields ).
    endif.

    if  it_form_fields is supplied
    and it_form_fields is not initial.
      me->mo_http_client->request->set_form_fields( it_form_fields ).
    endif.
  endmethod.


  method send_receive.
    clear es_response.

    me->mo_http_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        others                     = 5
    ).
    if sy-subrc <> 0.
      me->mo_log_api->log(
        |Error sending HTTP request: Error Code ({ sy-subrc })|
      ).                                                    "#EC NOTEXT
    endif.

    me->mo_http_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others                     = 4
    ).
    if sy-subrc <> 0.
      me->mo_log_api->log(
        |Error receiving HTTP request: Error Code ({ sy-subrc })|
      ).                                                    "#EC NOTEXT
    endif.

    "Fill response structure.
    me->mo_http_client->response->get_status(
      importing
        code = es_response-status_code
    ).
    es_response-data = me->mo_http_client->response->get_cdata( ).
    es_response-content_type =
      me->mo_http_client->response->get_content_type( ).

    me->mo_http_client->response->get_header_fields(
      changing
        fields = es_response-header_fields
    ).

    me->mo_log_api->log(
      |HTTP request sent: Status Code ({ es_response-status_code })|
    ).                                                      "#EC NOTEXT
  endmethod.


  method set_oauth_token.
    try.
        me->mo_oauth_client->set_token(
          io_http_client = me->mo_http_client
          i_param_kind   = if_oauth2_client=>c_param_kind_form_field
        ).
      catch cx_oa2c into data(lo_oauth_exc).
        try.
            me->mo_oauth_client->execute_refresh_flow( ).
          catch cx_oa2c into lo_oauth_exc.
            me->mo_log_api->log( `Error executing OAuth 2.0 refresh flow: `
              && lo_oauth_exc->get_text( )
            ).                                              "#EC NOTEXT

            rv_has_succeeded = abap_false.
            return.
        endtry.

        try.
            me->mo_oauth_client->set_token(
              io_http_client = me->mo_http_client
              i_param_kind   = if_oauth2_client=>c_param_kind_form_field
            ).
          catch cx_oa2c into lo_oauth_exc.
            me->mo_log_api->log( `Error setting OAuth 2.0 token: `
              && lo_oauth_exc->get_text( )
            ).                                              "#EC NOTEXT

            rv_has_succeeded = abap_false.
            return.
        endtry.
    endtry.

    rv_has_succeeded = abap_true.
  endmethod.


  method zif_googlepoc_drive_api~create_file_metadata.
    data(lv_open_connection_succeeded) = me->open_connection(
      iv_url = cs_google_drive_rest_api_uri-file_metadata
                 && |?{ cs_files_query_parameter-fields }=|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-id },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-web_view_link }| "#EC NOTEXT
      iv_method = if_http_entity=>co_request_method_post
    ).

    if lv_open_connection_succeeded = abap_true.
      me->mo_http_client->request->set_content_type(
        |{ cs_content_type-json };charset={ c_encoding_utf8 }| "#EC NOTEXT
      ).
      data(lv_metadata) = me->mo_json_api->create_file_resource(
        iv_name      = iv_name
        iv_mime_type = iv_mime_type
      ).
      me->mo_http_client->request->set_cdata( lv_metadata ).

      me->send_receive(
        importing
          es_response = data(ls_response)
      ).
      me->close_connection( ).

      if has_request_succeeded( ls_response-status_code ) = abap_true.
        rs_file_resource =
          me->mo_json_api->parse_file_resource( ls_response-data ).
        if rs_file_resource is not initial.
          rs_file_resource-name = iv_name.
          rs_file_resource-mime_type = iv_mime_type.
        endif.
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~get_files_metadata.
    if iv_name is not initial.
      data(lv_search_parameters) = escape(
        val    = |{ cs_files_search_field-name }='{ iv_name }'| "#EC NOTEXT
        format = cl_abap_format=>e_url_full
      ).
    endif.

    if iv_mime_type is not initial.
      if lv_search_parameters is not initial.
        lv_search_parameters = lv_search_parameters
          && ` and `.                                       "#EC NOTEXT
      endif.

      lv_search_parameters = lv_search_parameters
        && escape(
             val    = |{ cs_files_search_field-mime_type }='{ iv_mime_type }'| "#EC NOTEXT
             format = cl_abap_format=>e_url_full
           ).
    endif.

    data(lv_url) = cs_google_drive_rest_api_uri-list_files
      && |?{ cs_files_query_parameter-fields }=|
      && |{ zif_googlepoc_drive_json_api=>files_resource_list_field-files }(|
      && |{ zif_googlepoc_drive_json_api=>file_resource_field-id },|
      && |{ zif_googlepoc_drive_json_api=>file_resource_field-name },|
      && |{ zif_googlepoc_drive_json_api=>file_resource_field-mime_type },|
      && |{ zif_googlepoc_drive_json_api=>file_resource_field-web_view_link },|
      && |{ zif_googlepoc_drive_json_api=>file_resource_field-parents })|. "#EC NOTEXT

    if lv_search_parameters is not initial.
      lv_url = lv_url
        && |&{ cs_files_query_parameter-query }=|
        && |{ lv_search_parameters }|.                      "#EC NOTEXT
    endif.

    data(lv_open_connection_succeeded) = me->open_connection(
      iv_url    = lv_url
      iv_method = if_http_entity=>co_request_method_get
    ).

    if lv_open_connection_succeeded = abap_true.
      me->send_receive(
        importing
          es_response = data(ls_response)
      ).
      me->close_connection( ).

      if has_request_succeeded( ls_response-status_code ) = abap_true.
        me->mo_json_api->parse_file_resource_list(
          exporting
            iv_file_resource_list_json = ls_response-data
          importing
            et_file_resources          = rt_file_resources
        ).
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~get_log.
    clear et_log.
    et_log = me->mo_log_api->mt_log.
  endmethod.


  method zif_googlepoc_drive_api~has_valid_token.
    rv_has_valid_token = me->open_connection(
      iv_url = cs_google_drive_rest_api_uri-list_files
                 && |?{ cs_files_query_parameter-fields }=|
                 && |{ zif_googlepoc_drive_json_api=>files_resource_list_field-files }(|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-id },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-name })| "#EC NOTEXT
      iv_method = if_http_entity=>co_request_method_get
    ).
    me->close_connection( ).
  endmethod.


  method zif_googlepoc_drive_api~list_all_files.
    data(lv_open_connection_succeeded) = me->open_connection(
      iv_url = cs_google_drive_rest_api_uri-list_files
                 && |?{ cs_files_query_parameter-fields }=|
                 && |{ zif_googlepoc_drive_json_api=>files_resource_list_field-files }(|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-id },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-name },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-mime_type },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-web_view_link },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-parents })| "#EC NOTEXT
      iv_method = if_http_entity=>co_request_method_get
    ).

    if lv_open_connection_succeeded = abap_true.
      me->send_receive(
        importing
          es_response = data(ls_response)
      ).
      me->close_connection( ).

      if has_request_succeeded( ls_response-status_code ) = abap_true.
        me->mo_json_api->parse_file_resource_list(
          exporting
            iv_file_resource_list_json = ls_response-data
          importing
            et_file_resources          = rt_file_resources
        ).
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~multipart_upload.
    data(lv_open_connection_succeeded) = me->open_connection(
      iv_url = cs_google_drive_rest_api_uri-multipart_upload
                 && |&{ cs_files_query_parameter-fields }=|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-id },|
                 && |{ zif_googlepoc_drive_json_api=>file_resource_field-web_view_link }| "#EC NOTEXT
      iv_method = if_http_entity=>co_request_method_post
    ).

    if lv_open_connection_succeeded = abap_true.
      me->mo_http_client->request->set_content_type(
        cs_content_type-multipart
      ).

      "Metadata
      data(lo_entity) = me->mo_http_client->request->add_multipart( ).
      lo_entity->set_content_type(
        |{ cs_content_type-json };charset={ c_encoding_utf8 }| "#EC NOTEXT
      ).
      data(lv_metadata) = me->mo_json_api->create_file_resource(
        iv_mime_type = iv_mime_type
        iv_name      = iv_name
        it_parents   = it_parents
      ).
      lo_entity->set_cdata( lv_metadata ).

      "Binary file content
      lo_entity = me->mo_http_client->request->add_multipart( ).
      lo_entity->set_content_type( iv_content_type ).
      lo_entity->set_data( data = ir_data->* ).

      me->send_receive(
        importing
          es_response = data(ls_response)
      ).
      me->close_connection( ).

      if has_request_succeeded( ls_response-status_code ) = abap_true.
        rs_file_resource =
          me->mo_json_api->parse_file_resource( ls_response-data ).
        if rs_file_resource is not initial.
          rs_file_resource-name = iv_name.
          rs_file_resource-mime_type = iv_mime_type.
          rs_file_resource-parents = it_parents.
        endif.
      endif.
    endif.
  endmethod.


  method zif_googlepoc_drive_api~simple_upload.
    data(lv_open_connection_succeeded) = me->open_connection(
      iv_url    = cs_google_drive_rest_api_uri-simple_upload
      iv_method = if_http_entity=>co_request_method_post
    ).
    if lv_open_connection_succeeded = abap_true.
      me->mo_http_client->request->set_content_type( iv_content_type ).
      me->mo_http_client->request->set_data( ir_data->* ).

      me->send_receive(
        importing
          es_response = data(ls_response)
      ).
      me->close_connection( ).

      rv_has_succeeded = has_request_succeeded( ls_response-status_code ).
    endif.
  endmethod.


endclass.
