"! <p>
"! Validates a Google certificate in the Personal Security Environment (PSE). The validation only
"! comprises measures to test the availability of the certificate in the PSE and ensure that it is
"! still valid, i.e. has <em>not expired</em> yet. It does <em>not</em> ensure the trust and
"! acceptance by a Google Server.
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
class zcl_googlepoc_cert_validation definition
  public
  final
  create public.


  public section.

    "! Constructs a new Google certificate validation instance.
    methods constructor.

    "! Determines if a Google certificate is available in the PSE.
    "!
    "! @parameter result | <em>abap_true</em> if a Google certificate is available;
    "! <em>abap_false</em> otherwise.
    methods is_available
      returning
        value(result) type abap_bool.

    "! Determines if a Google certificate in the PSE is valid, i.e. has <em>not expired</em>.
    "!
    "! @parameter result | <em>abap_true</em> if a Google certificate is valid; <em>abap_false</em>
    "! otherwise.
    methods is_valid
      returning
        value(result) type abap_bool.


  private section.

    "! The PSE Application to use for validation.
    constants default_pse_application type ssfappl value `ANONYM` ##NO_TEXT.

    "! The PSE Context to use for validation.
    constants default_pse_context type psecontext value `SSLC` ##NO_TEXT.

    "! The common name (cn) of the Google certificate to address.
    constants google_cn type string value `Google` ##NO_TEXT.

    "! The stored certificate.
    data certificate type ref to cl_abap_x509_certificate.

    "! Gets the certificate.
    "!
    "! @parameter result | The retrieved certificate.
    methods get_certificate
      returning
        value(result) type ref to cl_abap_x509_certificate.

    "! Determines if the Personal Security Environment (PSE) is available.
    "!
    "! @parameter result | <em>abap_true</em> if the PSE is available; <em>abap_false</em>
    "! otherwise.
    methods is_pse_available
      returning
        value(result) type abap_bool.


endclass.


class zcl_googlepoc_cert_validation implementation.


  method constructor.
    if me->is_pse_available( ) = abap_true.
      me->certificate = me->get_certificate( ).
    endif.
  endmethod.


  method get_certificate.
    try.
        data(pse) = new cl_abap_pse( iv_context     = default_pse_context
                                     iv_application = default_pse_application ).
        pse->get_trusted_certificates(
          importing
            et_certificate_list       = data(certificate_binaries)
            et_certificate_list_typed = data(certificates) ).

        data certificate_index type syst_tabix.
        loop at certificates assigning field-symbol(<current_certificate>)
        where subject cp |CN=*{ google_cn }*| ##NO_TEXT.
          certificate_index = sy-tabix.
          exit.
        endloop.

        field-symbols <certificate_binary> type xstring.
        if certificate_index is not initial.
          try.
              result = cl_abap_x509_certificate=>get_instance(
                         certificate_binaries[ certificate_index ] ).
            catch cx_abap_x509_certificate ##NO_HANDLER.
          endtry.
        endif.
      catch cx_abap_pse ##NO_HANDLER.
    endtry.
  endmethod.


  method is_available.
    result = cond #( when me->certificate is bound
                     then abap_true
                     else abap_false ).
  endmethod.


  method is_pse_available.
    result = abap_false.

    try.
        cl_abap_pse=>get_pse_info(
          exporting
            iv_context     = default_pse_context
            iv_application = default_pse_application ).
        result = abap_true.
      catch cx_abap_pse ##NO_HANDLER.
    endtry.
  endmethod.


  method is_valid.
    result = abap_false.

    data valid_to_date type d.
    data valid_to_time type t.
    if me->certificate is bound.
      try.
          me->certificate->get_valid_to(
            importing
              ef_date = valid_to_date
              ef_time = valid_to_time ).
          if sy-datum <= valid_to_date.
            result = abap_true.
          elseif sy-datum = valid_to_date
          and    sy-uzeit <= valid_to_time.
            result = abap_true.
          endif.
        catch cx_abap_x509_certificate ##NO_HANDLER.
      endtry.
    endif.
  endmethod.


endclass.
