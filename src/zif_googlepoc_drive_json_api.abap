"! <p>
"! Interface to the logging API in the context of Google Drive.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
interface zif_googlepoc_drive_log_api
  public.


  types:
    "! Describes a log entry.
    begin of ys_log_entry,
      "! The date the entry was created on.
      date    type d,

      "! The time the entry was created at.
      time    type t,

      "! The message of the entry.
      message type string,
    end of ys_log_entry.

  "! Describes a list of log entries.
  types yt_log_enty type standard table
    of ys_log_entry
    with non-unique default key.

  "! The logging entries.
  data mt_log type yt_log_enty read-only.

  "! Logs the given message.
  "!
  "! @parameter iv_message | The message to log.
  methods log
    importing
      iv_message type string.


endinterface.