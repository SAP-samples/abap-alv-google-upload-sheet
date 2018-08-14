"! <p>
"! Converts ABAP Date/Time values with optional UTC offset to RFC 3339 compliant
"! Date/Time values.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See RFC 3339 at https://tools.ietf.org/html/rfc3339
class zcl_googlepoc_rfc3339_datetime definition
  public
  create public
  final.


  public section.

    types:
      "! Type describing a <em>Date/Time</em> value.
      begin of ys_date_time,
        "! The date part.
        date                    type d,

        "! The time part.
        time                    type t,

        "! The time difference from the UTC reference time in minutes, e.g.
        "! -90 for a local to UTC difference of -1:30 hours.
        local_to_utc_difference type i,
      end of ys_date_time.

    "! Converts the given ABAP Date/Time value to an RC 3339 Date/Time.
    "!
    "! @parameter is_input_date_time | The input ABAP Date/Time value.
    "! @parameter rv_output_date_time | The output RC 3339 Date/Time value.
    methods convert
      importing
        is_input_date_time         type ys_date_time
      returning
        value(rv_output_date_time) type string.


  private section.

    "! The number of minutes in one hour.
    constants c_minutes_per_hour type i value 60.


endclass.


class zcl_googlepoc_rfc3339_datetime implementation.


  method convert.
    rv_output_date_time =
         |{ is_input_date_time-date(4) }-|
      && |{ is_input_date_time-date+4(2) }-|
      && |{ is_input_date_time-date+6(2) }|.                "#EC NOTEXT

    if is_input_date_time-time is not initial.
      rv_output_date_time = rv_output_date_time
        && |T|
        && |{ is_input_date_time-time(2) }:|
        && |{ is_input_date_time-time+2(2) }:|
        && |{ is_input_date_time-time+4(2) }|.              "#EC NOTEXT

      if is_input_date_time-local_to_utc_difference is initial.
        rv_output_date_time = rv_output_date_time && `Z`.   "#EC NOTEXT
      else.
        data(lv_hours) = |{ abs( is_input_date_time-local_to_utc_difference
                                 div c_minutes_per_hour
                               )
                          }|.
        data(lv_minutes) = |{ abs( is_input_date_time-local_to_utc_difference
                                   mod c_minutes_per_hour
                                 )
                            }|.

        if is_input_date_time-local_to_utc_difference < 0.
          rv_output_date_time = rv_output_date_time
            && `-`
            && |{ lv_hours alpha = in width = 2 }:|
            && |{ lv_minutes alpha = in width = 2 }|.       "#EC NOTEXT
        else.
          rv_output_date_time = rv_output_date_time
            && `+`
            && |{ lv_hours alpha = in width = 2 }:|
            && |{ lv_minutes alpha = in width = 2 }|.       "#EC NOTEXT
        endif.
      endif.
    endif.
  endmethod.


endclass.
