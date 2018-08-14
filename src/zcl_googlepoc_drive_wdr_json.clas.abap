"! <p>
"! Implementation of the Google Drive JSON API that leverages the
"! <em>WDR JSON</em> library for producing and parsing content in JSON format.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class zcl_googlepoc_drive_wdr_json definition
  public
  create public
  final.


  public section.

    interfaces zif_googlepoc_drive_json_api.

    aliases create_file_resource
      for zif_googlepoc_drive_json_api~create_file_resource.
    aliases parse_file_resource
      for zif_googlepoc_drive_json_api~parse_file_resource.
    aliases parse_file_resource_list
      for zif_googlepoc_drive_json_api~parse_file_resource_list.
    aliases set_log_api
      for zif_googlepoc_drive_json_api~set_log_api.


    "! Constructs a new Google Drive WDR JSON instance.
    methods constructor.


  private section.

    "! The used JSON Factory.
    data mo_factory type ref to if_wdr_json_factory.

    "! The used logging API.
    data mo_log_api type ref to zif_googlepoc_drive_log_api.

    "! Converts the given Drive File Resource JSON Object to a data file
    "! resource data structure.
    "!
    "! @parameter io_file_resource_json_object | The JSON Object holding the
    "! data of the Drive File Resource.
    "! @parameter rs_file_resource | The converted Drive File Resource data
    "! structure.
    methods convert_json_to_file_resource
      importing
        io_file_resource_json_object type ref to if_wdr_json_object
      returning
        value(rs_file_resource)      type zif_googlepoc_drive_api=>ys_file_resource.


endclass.


class zcl_googlepoc_drive_wdr_json implementation.


  method constructor.
    me->mo_factory = cl_wdr_json_factory=>new_instance( ).
  endmethod.


  method zif_googlepoc_drive_json_api~create_file_resource.
    data(lo_date_time_converter) = new zcl_googlepoc_rfc3339_datetime( ).
    data(lv_create_date_time) = lo_date_time_converter->convert(
      value zcl_googlepoc_rfc3339_datetime=>ys_date_time(
        date                    = sy-datum
        time                    = sy-uzeit
        local_to_utc_difference = sy-tzone div 60
      )
    ).

    data(lt_metadata_values) =
      value if_wdr_json_object=>yt_json_name_value_list(
        (
          name  = zif_googlepoc_drive_json_api=>file_resource_field-name
          value = me->mo_factory->new_json_string( iv_name )
        )
        (
          name  = zif_googlepoc_drive_json_api=>file_resource_field-mime_type
          value = me->mo_factory->new_json_string( iv_mime_type )
        )
        (
          name  = zif_googlepoc_drive_json_api=>file_resource_field-created_time
          value = me->mo_factory->new_json_string( lv_create_date_time )
        )
      ).

    if iv_id is not initial.
      append value if_wdr_json_object=>ys_json_name_value(
        name  = zif_googlepoc_drive_json_api=>file_resource_field-id
        value = me->mo_factory->new_json_string( iv_id )
      ) to lt_metadata_values.
    endif.

    if it_parents is not initial.
      data lt_parents_array_entries type if_wdr_json_value=>yt_json_value.
      loop at it_parents assigning field-symbol(<lv_parent_id>).
        append me->mo_factory->new_json_string( <lv_parent_id> )
          to lt_parents_array_entries.
      endloop.

      append value if_wdr_json_object=>ys_json_name_value(
        name  = zif_googlepoc_drive_json_api=>file_resource_field-parents
        value = me->mo_factory->new_json_array( lt_parents_array_entries )
      ) to lt_metadata_values.
    endif.

    rv_file_resource_json = me->mo_factory->new_json_object(
      lt_metadata_values
    )->to_string( ).
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource.
    try.
        data(lo_root_value) =
          cl_wdr_json_parser=>parse( iv_file_resource_json ).
        if cl_wdr_json_utils=>is_object( lo_root_value ) = abap_true.
          rs_file_resource = me->convert_json_to_file_resource(
            cl_wdr_json_utils=>as_object( lo_root_value )
          ).
        endif.
      catch cx_wdr_json_parser into data(lo_parser_exc).
        me->mo_log_api->log( |Error parsing Google Drive File Resource JSON: |
          && |{ lo_parser_exc->get_text( ) }|
        ).                                                  "#EC NOTEXT
    endtry.
  endmethod.


  method zif_googlepoc_drive_json_api~parse_file_resource_list.
    clear et_file_resources.

    try.
        data(lo_root_value) =
          cl_wdr_json_parser=>parse( iv_file_resource_list_json ).
        if cl_wdr_json_utils=>is_object( lo_root_value ) = abap_true.
          data(lo_files_value) =
            cl_wdr_json_utils=>as_object( lo_root_value )->get_value(
              zif_googlepoc_drive_json_api=>files_resource_list_field-files
            ).
          loop at cl_wdr_json_utils=>get_array_values_safely( lo_files_value )
          into data(lo_array_element).
            if cl_wdr_json_utils=>is_object( lo_array_element ) = abap_true.
              data(ls_file_resource) =
                me->convert_json_to_file_resource(
                  cl_wdr_json_utils=>as_object( lo_array_element )
                ).
              if ls_file_resource is not initial.
                append ls_file_resource to et_file_resources.
              endif.
            endif.
          endloop.
        endif.
      catch cx_wdr_json_parser into data(lo_parser_exc).
        me->mo_log_api->log( |Error parsing Google Drive Files List response: |
          && |{ lo_parser_exc->get_text( ) }|
        ).                                                  "#EC NOTEXT
    endtry.
  endmethod.


  method convert_json_to_file_resource.
    rs_file_resource-id = cl_wdr_json_utils=>get_string_safely(
      io_file_resource_json_object->get_value(
        zif_googlepoc_drive_json_api=>file_resource_field-id
      )
    ).
    rs_file_resource-name = cl_wdr_json_utils=>get_string_safely(
      io_file_resource_json_object->get_value(
        zif_googlepoc_drive_json_api=>file_resource_field-name
      )
    ).
    rs_file_resource-mime_type = cl_wdr_json_utils=>get_string_safely(
      io_file_resource_json_object->get_value(
        zif_googlepoc_drive_json_api=>file_resource_field-mime_type
      )
    ).
    rs_file_resource-web_view_link = cl_wdr_json_utils=>get_string_safely(
      io_file_resource_json_object->get_value(
        zif_googlepoc_drive_json_api=>file_resource_field-web_view_link
      )
    ).

    data(lt_parent_id_values) = cl_wdr_json_utils=>get_array_values_safely(
      io_file_resource_json_object->get_value(
        zif_googlepoc_drive_json_api=>file_resource_field-parents
      )
    ).
    loop at lt_parent_id_values into data(lo_parent_id).
      append cl_wdr_json_utils=>get_string_safely( lo_parent_id )
        to rs_file_resource-parents.
    endloop.
  endmethod.


  method zif_googlepoc_drive_json_api~set_log_api.
    me->mo_log_api = io_log_api.
  endmethod.


endclass.
