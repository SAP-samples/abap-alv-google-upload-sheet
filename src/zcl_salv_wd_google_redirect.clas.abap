"! <p>
"! Assistance class of the custom WDA Redirect Handler for an OAuth Redirect
"! URI Workflow.
"! </p>
"!
"! <p>
"! Author:  Klaus-Dieter Scherer, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
class zcl_salv_wd_google_redirect definition
  public
  create public
  inheriting from
    cl_wd_component_assistance
  final.


  public section.

    "! Sets the received URL parameters.
    "!
    "! @parameter t_url_parameter | The list of received URL parameters.
    methods set_url_parameters
      importing
        t_url_parameter type tihttpnvp.

    "! Evaluates the beforehand set URL parameters and produces a human readable
    "! message from it.
    "!
    "! @parameter message | The evaluation message.
    "! @parameter message_icon | A path to either a success or error image.
    methods get_message
      exporting
        message      type string
        message_icon type string.


  private section.

    "! The list of received URL parameters.
    data mt_url_parameter type tihttpnvp.


endclass.


class zcl_salv_wd_google_redirect implementation.


  method get_message.
    loop at me->mt_url_parameter assigning field-symbol(<ls_url_parameter>).
      case <ls_url_parameter>-name.
        when 'ERROR'.
          message = |Error { <ls_url_parameter>-value } received. |
                 && |Please contact your system administrator|. "#EC NOTEXT
          message_icon = |~IconLarge/ErrorMessage|.         "#EC NOTEXT
          exit.
        when others.
          "Token successfully provided, please start again with the Export.
          message = |Access token successfully received from Google. Please |
                 && |repeat your Export To Spreadsheet (Google Sheets) action|. "#EC NOTEXT
          message_icon = |~IconLarge/SuccessMessage|.       "#EC NOTEXT
      endcase.
    endloop.
  endmethod.


  method set_url_parameters.
    me->mt_url_parameter = t_url_parameter.
  endmethod.


endclass.
