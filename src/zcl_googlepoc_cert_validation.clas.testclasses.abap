class ltc_google_cert_validation definition
  create public
  final
  for testing
  duration short
  risk level harmless.


  private section.

    "! The certificate validation instance to put under test.
    data validation type ref to zcl_googlepoc_cert_validation.


    "----- TEST FIXTURE LIFECYCLE METHODS
    "! Sets up a unit test fixture.
    methods setup.


    "----- TEST METHODS
    methods is_available for testing.
    methods is_valid for testing.


endclass.


class ltc_google_cert_validation implementation.


  method setup.
    me->validation = new zcl_googlepoc_cert_validation( ).
  endmethod.


  method is_available.
    data(act_is_available) = me->validation->is_available( ).
    cl_abap_unit_assert=>assert_true(
      act   = act_is_available
      msg   = `Expected the Google Certificate to be available, but was not` ##NO_TEXT
      level = if_aunit_constants=>tolerable ).
  endmethod.


  method is_valid.
    data(act_is_valid) = me->validation->is_valid( ).
    cl_abap_unit_assert=>assert_true(
      act   = act_is_valid
      msg   = `Expected the Google Certificate to be valid, but was not` ##NO_TEXT
      level = if_aunit_constants=>tolerable ).
  endmethod.


endclass.
