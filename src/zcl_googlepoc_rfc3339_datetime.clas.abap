"! <p>
"! Converts <strong>ABAP Date/Time</strong> values with optional UTC offset to <strong>RFC 3339
"! compliant Date/Time</strong> values.
"! </p>
"!
"! <p>
"! See RFC 3339 at https://tools.ietf.org/html/rfc3339
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
class zcl_googlepoc_rfc3339_datetime definition
  public
  create public
  final.


  public section.

    types:
      "! Type describing a <em>Date/Time</em> value.
      begin of date_time,
        "! The date part.
        date                    type d,

        "! The time part.
        time                    type t,

        "! The time difference from the UTC reference time in minutes, e.g. -90 for a local to UTC
        "! difference of -1:30 hours.
        local_to_utc_difference type i,
      end of date_time.

    "! Converts the given <strong>ABAP Date/Time</strong> to an <strong>RFC 3339 Date/Time</strong>
    "! value.
    "!
    "! @parameter input | The input <strong>ABAP Date/Time</strong> value.
    "! @parameter result | The output <strong>RFC 3339 Date/Time</strong> value.
    methods convert
      importing
        input         type date_time
      returning
        value(result) type string.


  private section.

    "! The number of minutes in one hour.
    constants minutes_per_hour type i value 60.


endclass.


class zcl_googlepoc_rfc3339_datetime implementation.


  method convert.
    data hours type string.
    data minutes type string.

    result = |{ input-date(4) }-{ input-date+4(2) }-{ input-date+6(2) }| ##NO_TEXT.

    if input-time is not initial.
      result = result
            && |T{ input-time(2) }:{ input-time+2(2) }:{ input-time+4(2) }| ##NO_TEXT.

      if input-local_to_utc_difference is initial.
        result = result && `Z` ##NO_TEXT.
      else.
        hours = |{ abs( input-local_to_utc_difference div minutes_per_hour ) }|.
        minutes = |{ abs( input-local_to_utc_difference mod minutes_per_hour ) }|.

        if input-local_to_utc_difference < 0.
          result = result
                && |-{ hours alpha = in width = 2 }:{ minutes alpha = in width = 2 }| ##NO_TEXT.
        else.
          result = result
                && |+{ hours alpha = in width = 2 }:{ minutes alpha = in width = 2 }| ##NO_TEXT.
        endif.
      endif.
    endif.
  endmethod.


endclass.
