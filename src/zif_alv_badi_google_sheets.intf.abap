interface zif_alv_badi_google_sheets
  public.


  interfaces if_badi_interface.

  methods get_binary_4_google_sheets
    importing
      s_xml_choice              type if_salv_bs_xml=>s_type_xml_choice
      result_file               type xstring
      is_oauth_client_available type abap_bool
      is_filedownload_possible  type abap_bool.


endinterface.
