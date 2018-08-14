"! <p>
"! Validates a Google certificate in the Personal Security Environment (PSE).
"! The validation only comprises measures to test the availability of the
"! certificate in the PSE and ensure that it is still valid, i.e. has <em>not
"! expired</em> yet. It does <em>not</em> ensure the trust and acceptance by a
"! Google Server.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
"!
"! See https://developers.google.com/drive/
class zcl_googlepoc_cert_validation definition
  public
  create public
  final.


  public section.

    "! Constructs a new Google certificate validation instance.
    methods constructor.

    "! Determines if a Google certificate is available in the PSE.
    "!
    "! @parameter rv_is_available | abap_true if a Google certificate is
    "! available; abap_false otherwise.
    methods is_available
      returning
        value(rv_is_available) type abap_bool.

    "! Determines if a Google certificate in the PSE is valid, i.e. has
    "! <em>not expired</em>.
    "!
    "! @parameter rv_is_valid | abap_true if a Google certificate is valid;
    "! abap_false otherwise.
    methods is_valid
      returning
        value(rv_is_valid) type abap_bool.


  private section.

    "! The PSE Application to use for validation.
    constants c_pse_application type ssfappl value `ANONYM`. "#EC NOTEXT

    "! The PSE Context to use for validation.
    constants c_pse_context type psecontext value `SSLC`.   "#EC NOTEXT

    "! The common name (cn) of the Google certificate to address.
    constants c_google_cn type string value `CN=Google Internet Authority`. "#EC NOTEXT

    "! The stored certificate.
    data mo_certificate type ref to cl_abap_x509_certificate.

    "! Gets the certificate.
    "!
    "! @parameter ro_certificate | The retrieved certificate.
    methods get_certificate
      returning
        value(ro_certificate) type ref to cl_abap_x509_certificate.

    "! Determines if the Personal Security Environment (PSE) is available.
    "!
    "! @parameter rv_is_available | abap_true if the PSE is available;
    "! abap_false otherwise.
    methods is_pse_available
      returning
        value(rv_is_available) type abap_bool.


endclass.


class zcl_googlepoc_cert_validation implementation.


  method constructor.
    if me->is_pse_available( ) = abap_true.
      me->mo_certificate = me->get_certificate( ).
    endif.
  endmethod.


  method get_certificate.
    try.
        data(lo_pse) = new cl_abap_pse(
          iv_context     = c_pse_context
          iv_application = c_pse_application
        ).
        lo_pse->get_trusted_certificates(
          importing
            et_certificate_list       = data(lt_certificates_binaries)
            et_certificate_list_typed = data(lt_certificates)
        ).

        loop at lt_certificates
        assigning field-symbol(<ls_certificate>)
        where subject cp |*{ c_google_cn }*|.               "#EC NOTEXT
          data(lv_certificate_index) = sy-tabix.
          exit.
        endloop.

        if lv_certificate_index is not initial.
          read table lt_certificates_binaries
            index lv_certificate_index
            assigning field-symbol(<lv_certificate_binary>).
          if  sy-subrc = 0
          and <lv_certificate_binary> is assigned.
            try.
                ro_certificate = cl_abap_x509_certificate=>get_instance(
                  <lv_certificate_binary>
                ).
              catch cx_abap_x509_certificate ##NO_HANDLER.
            endtry.
          endif.
        endif.
      catch cx_abap_pse ##NO_HANDLER.
    endtry.
  endmethod.


  method is_available.
    rv_is_available = cond abap_bool(
      when me->mo_certificate is bound
        then abap_true
        else abap_false
    ).
  endmethod.


  method is_pse_available.
    rv_is_available = abap_false.

    try.
        cl_abap_pse=>get_pse_info(
          exporting
            iv_context     = c_pse_context
            iv_application = c_pse_application
          importing
            ev_profile     = data(lv_profile)
        ).
        rv_is_available = abap_true.
      catch cx_abap_pse ##NO_HANDLER.
    endtry.
  endmethod.


  method is_valid.
    rv_is_valid = abap_false.

    if me->mo_certificate is bound.
      try.
          me->mo_certificate->get_valid_to(
            importing
              ef_date = data(lv_valid_to_date)
              ef_time = data(lv_valid_to_time)
          ).
          if sy-datum <= lv_valid_to_date.
            rv_is_valid = abap_true.
          elseif sy-datum = lv_valid_to_date
          and    sy-uzeit <= lv_valid_to_time.
            rv_is_valid = abap_true.
          endif.
        catch cx_abap_x509_certificate ##NO_HANDLER.
      endtry.
    endif.
  endmethod.


endclass.
