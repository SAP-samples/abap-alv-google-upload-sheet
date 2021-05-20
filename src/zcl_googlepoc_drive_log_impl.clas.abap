"! <p>
"! Default implementation of the <strong>Logging API</strong> in the context of the
"! <strong>Google Drive REST API</strong>, which writes the entries to an internal table buffer.
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
class zcl_googlepoc_drive_log_impl definition
  public
  create public
  final.


  public section.

    interfaces zif_googlepoc_drive_log_api.

    aliases entries
      for zif_googlepoc_drive_log_api~entries.
    aliases log
      for zif_googlepoc_drive_log_api~log ##SHADOW[LOG].

endclass.


class zcl_googlepoc_drive_log_impl implementation.


  method zif_googlepoc_drive_log_api~log.
    append value #( date    = sy-datum
                    time    = sy-uzeit
                    message = message ) to me->entries.
  endmethod.


endclass.
