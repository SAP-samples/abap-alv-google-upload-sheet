"! <p>
"! Default implementation of the logging API in the context of Google Drive,
"! which writes the entries to an internal table buffer.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class zcl_googlepoc_drive_log_impl definition
  public
  create public
  final.


  public section.

    interfaces zif_googlepoc_drive_log_api.

    aliases mt_log
      for zif_googlepoc_drive_log_api~mt_log.
    aliases log
      for zif_googlepoc_drive_log_api~log ##SHADOW[LOG].

endclass.


class zcl_googlepoc_drive_log_impl implementation.


  method zif_googlepoc_drive_log_api~log.
    append value zif_googlepoc_drive_log_api=>ys_log_entry(
      date    = sy-datum
      time    = sy-uzeit
      message = iv_message
    ) to me->mt_log.
  endmethod.


endclass.