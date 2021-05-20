"! <p>
"! Interface to the <strong>Logging API</strong> in the context of the
"! <strong>Google Drive REST API</strong>.
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
interface zif_googlepoc_drive_log_api
  public.


  types:
    "! Describes a log entry.
    begin of log_entry,
      "! The date the entry was created on.
      date    type d,

      "! The time the entry was created at.
      time    type t,

      "! The message of the entry.
      message type string,
    end of log_entry.

  "! Describes a list of log entries.
  types log_entries type standard table
    of log_entry
    with empty key.

  "! The logging entries.
  data entries type log_entries read-only.

  "! Logs the given message.
  "!
  "! @parameter message | The message to log.
  methods log
    importing
      message type string.


endinterface.
