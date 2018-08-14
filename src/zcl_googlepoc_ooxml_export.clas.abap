"! <p>
"! Exports test data to the Office Open XML (Microsoft Excel) format.
"! </p>
"!
"! <p>
"! Author:  Sebastian Machhausen, SAP SE <br/>
"! Version: 0.0.4<br/>
"! </p>
class zcl_googlepoc_ooxml_export definition
  public
  create public
  final.


  public section.

    "! Describes a salary.
    types y_salary type p length 16 decimals 2.

    "! Describes a currency.
    types y_currency type c length 5.

    types:
      "! Describes an employee record.
      begin of ys_employee,
        id              type n length 6,
        last_name       type string,
        first_name      type string,
        department      type string,
        department_url  type string,
        department_icon type string,
        salary          type y_salary,
        currency        type y_currency,
        entry_date      type dats,
        leaving_date    type dats,
        hierarchy_level type int4,
      end of ys_employee.

    "! Describes a list of employee records.
    types yt_employee type standard table
      of ys_employee
      with non-unique key last_name first_name.

    types:
      "! Describes a column for an export operation.
      begin of ys_column_description,
        "! The name of the field associated to the column.
        field_name   type if_salv_export_column_conf=>y_field_name,

        "! The display type of the column.
        display_type type if_salv_export_column_conf=>y_display_type,

        "! The text to use as column header.
        header_text  type if_salv_export_column_conf=>y_text,
      end of ys_column_description.

    "! Describes a list of column descriptions.
    types yt_column_description type standard table
      of ys_column_description
      with non-unique default key.

    "! The mime type of an Office Open XML spreadsheet file.
    constants c_xlsx_mime_type type string value
      `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`. "#EC NOTEXT

    "! Constructs a new Office Open XML Export instance.
    methods constructor.

    "! Executes the Export for the EMPLOYEE data.
    "!
    "! @parameter er_data | The exported binary data.
    "! @parameter ev_mime_type | The MIME type of the exported data.
    "!
    "! @raising cx_salv_export_error | In case the export failed.
    methods execute
      exporting
        er_data      type ref to xstring
        ev_mime_type type cl_salv_export_tool=>y_mime_type
      raising
        cx_salv_export_error.


  private section.

    "! The delimiter character separating a file name from its extension.
    constants c_file_extension_delimiter type c value '.' ##NEEDED ##NO_TEXT.

    "! The file extension of an Office Open XML spreadsheet file.
    constants c_xlsx_file_extension type string value `xlsx` ##NEEDED ##NO_TEXT.

    constants:
      "! Enumeration of all column names of an EMPLOYEES table.
      begin of cs_column_name,
        "! The name of the ID column.
        id              type string value `ID`,             "#EC NOTEXT

        "! The name of the LAST_NAME column.
        last_name       type string value `LAST_NAME`,      "#EC NOTEXT

        "! The name of the FIRST_NAME column.
        first_name      type string value `FIRST_NAME`,     "#EC NOTEXT

        "! The name of the DEPARTMENT column.
        department      type string value `DEPARTMENT`,     "#EC NOTEXT

        "! The name of the DEPARTMENT_URL column.
        department_url  type string value `DEPARTMENT_URL`, "#EC NOTEXT

        "! The name of the DEPARTMENT_ICON column.
        department_icon type string value `DEPARTMENT_ICON`, "#EC NOTEXT

        "! The name of the SALARY column.
        salary          type string value `SALARY`,         "#EC NOTEXT

        "! The name of the CURRENCY column.
        currency        type string value `CURRENCY`,       "#EC NOTEXT

        "! The name of the ENTRY_DATE column.
        entry_date      type string value `ENTRY_DATE`,     "#EC NOTEXT

        "! The name of the LEAVING_DATE column.
        leaving_date    type string value `LEAVING_DATE`,   "#EC NOTEXT

        "! The name of the HIERARCHY_LEVEL column.
        hierarchy_level type string value `HIERARCHY_LEVEL`, "#EC NOTEXT
      end of cs_column_name.

    constants:
      "! Enumeration of all department names.
      begin of cs_department,
        "! Research and Development department.
        research_and_development type string value `R&D`,   "#EC NOTEXT

        "! Finance department.
        finance                  type string value `Finance`, "#EC NOTEXT

        "! Marketing department.
        marketing                type string value `Marketing`, "#EC NOTEXT

        "! Sales department.
        sales                    type string value `Sales`, "#EC NOTEXT

        "! Management Accounting department.
        management_accounting    type string value `Management Accounting`, "#EC NOTEXT

        "! Office of the CEO department.
        office_of_ceo            type string value `Office of the CEO`, "#EC NOTEXT

        "! Board Chairman.
        board_chairman           type string value `Board Chairman`, "#EC NOTEXT
      end of cs_department.

    constants:
      "! Enumeration of currency codes.
      begin of cs_currency_value,
        "! The currency code of the Euro.
        euro         type y_currency value `EUR`,           "#EC NOTEXT

        "! The currency code of the US Dollar.
        us_dollar    type y_currency value `USD`,           "#EC NOTEXT

        "! The currency code of the Japanese Yen.
        japanese_yen type y_currency value `JPY`,           "#EC NOTEXT
      end of cs_currency_value.

    constants:
      "! Enumeration of department URLs.
      begin of cs_department_url,
        "! The URL of the Research and Development department.
        research_and_development type string value `https://en.wikipedia.org/wiki/Research_and_development`, "#EC NOTEXT

        "! The URL of the Finance department.
        finance                  type string value `https://en.wikipedia.org/wiki/Finance`, "#EC NOTEXT

        "! The URL of the Marketing department.
        marketing                type string value `https://en.wikipedia.org/wiki/Marketing`, "#EC NOTEXT

        "! The URL of the Sales department.
        sales                    type string value `https://en.wikipedia.org/wiki/Sales`, "#EC NOTEXT

        "! The URL of the Management Accounting department.
        management_accounting    type string value `https://en.wikipedia.org/wiki/Management_accounting`, "#EC NOTEXT

        "! The URL of the Office of the CEO department.
        office_of_ceo            type string value `https://en.wikipedia.org/wiki/Chief_executive_officer`, "#EC NOTEXT

        "! The URL of the Board Chairman.
        board_chairman           type string value `https://en.wikipedia.org/wiki/Board_of_directors`, "#EC NOTEXT
      end of cs_department_url.

    "! The list of employee records.
    data mt_employees type yt_employee.

    "! The columns to export.
    data mt_columns type yt_column_description.

    "! Configures the columns to be exported.
    "!
    "! @parameter io_configuration | The export service configuration instance
    "! to work on.
    methods configure_columns
      importing
        io_configuration type ref to if_salv_export_configuration.

    "! Populates the employee data.
    methods populate_employee_data.

    "! Populates the column descriptions.
    methods populate_column_descriptions.


endclass.


class zcl_googlepoc_ooxml_export implementation.


  method constructor.
    me->populate_column_descriptions( ).
    me->populate_employee_data( ).
  endmethod.


  method populate_column_descriptions.
    me->mt_columns = value yt_column_description(
      (
        field_name   = cs_column_name-id
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `ID`                                 "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-last_name
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `Last Name`                          "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-first_name
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `First Name`                         "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-department
        display_type = if_salv_export_column_conf=>display_types-link_to_url
        header_text  = `Department`                         "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-salary
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `Salary`                             "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-currency
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `Currency`                           "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-entry_date
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `Entry Date`                         "#EC NOTEXT
      )
      (
        field_name   = cs_column_name-leaving_date
        display_type = if_salv_export_column_conf=>display_types-text_view
        header_text  = `Leaving Date`                       "#EC NOTEXT
      )
    ).
  endmethod.


  method execute.
    clear: er_data, ev_mime_type.
    try.
        "Create the export service instance by means of the factory method.
        data(lo_export_service) = cl_salv_export_tool=>create_for_excel(
          provider = cl_salv_export_tool_xls=>cs_export_provider-lean
          r_data   = new yt_employee( me->mt_employees )
        ).

        "Retrieve the export service configuration instance.
        data(lo_configuration) = lo_export_service->configuration( ).

        "Configure the export service according to the EMPLOYEE data.
        me->configure_columns( lo_configuration ).

        "Read the results of the export.
        er_data = new xstring( ).
        lo_export_service->read_result(
          importing
            content   = er_data->*
            mime_type = ev_mime_type
        ).
      catch cx_salv_ill_export_format_path.
        raise exception
          type cx_salv_export_error.
      catch cx_salv_not_index_table.
        raise exception
          type cx_salv_export_error.
    endtry.
  endmethod.


  method configure_columns.
    loop at me->mt_columns assigning field-symbol(<ls_column_description>).
      data(lo_column_configuration) = io_configuration->add_column(
        field_name   = <ls_column_description>-field_name
        header_text  = <ls_column_description>-header_text
        display_type = <ls_column_description>-display_type
      ).

      case <ls_column_description>-field_name.
        when cs_column_name-department.
          lo_column_configuration->set_hyperlink(
            hyperlink_src_field = cs_column_name-department_url
          ).

          lo_column_configuration = io_configuration->add_column(
            header_text  = `Department URL`                 "#EC NOTEXT
            field_name   = cs_column_name-department_url
            display_type = if_salv_export_column_conf=>display_types-link_to_url
          ).
          lo_column_configuration->set_is_technical_column( abap_true ).
        when cs_column_name-salary.
          lo_column_configuration->set_reference_field(
            field_name = cs_column_name-currency
            type       = if_salv_export_column_conf=>reference_type-curr
          ).
      endcase.
    endloop.
  endmethod.


  method populate_employee_data.
    me->mt_employees = value yt_employee(
       (
        department       = cs_department-office_of_ceo
        department_url   = cs_department_url-office_of_ceo
        hierarchy_level  = 1
      )
      (
        department       = cs_department-board_chairman
        department_url   = cs_department_url-board_chairman
        hierarchy_level  = 2
      )
      (
        id              = 99
        first_name      = `Bryan`                           "#EC NOTEXT
        last_name       = `Boomer`                          "#EC NOTEXT
        department      = cs_department-board_chairman
        department_url  = cs_department_url-board_chairman
        entry_date      = `19990101`                        "#EC NOTEXT
        salary          = `5000000.00`                      "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 3
      )
      (
        id              = 1
        first_name      = `Abigail`                         "#EC NOTEXT
        last_name       = `Ascott`                          "#EC NOTEXT
        department      = cs_department-office_of_ceo
        department_url  = cs_department_url-office_of_ceo
        entry_date      = `20090501`                        "#EC NOTEXT
        salary          = `1000000.99`                      "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 2
        first_name      = `Bart`                            "#EC NOTEXT
        last_name       = `Bonson`                          "#EC NOTEXT
        department      = cs_department-office_of_ceo
        department_url  = cs_department_url-office_of_ceo
        entry_date      = `20090101`                        "#EC NOTEXT
        salary          = `999999.99`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 3
        first_name      = `Clarke`                          "#EC NOTEXT
        last_name       = `Coldworth`                       "#EC NOTEXT
        department      = cs_department-office_of_ceo
        department_url  = cs_department_url-office_of_ceo
        entry_date      = `20110301`                        "#EC NOTEXT
        salary          = `720000.00`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        department       = cs_department-finance
        department_url   = cs_department_url-finance
        hierarchy_level  = 1
      )
      (
        id              = 4
        first_name      = `Duncan`                          "#EC NOTEXT
        last_name       = `Danswirth`                       "#EC NOTEXT
        department      = cs_department-finance
        department_url  = cs_department_url-finance
        entry_date      = `20130101`                        "#EC NOTEXT
        leaving_date    = `20150731`                        "#EC NOTEXT
        salary          = `320000.49`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 5
        first_name      = `Esmerald`                        "#EC NOTEXT
        last_name       = `Everanguiz`                      "#EC NOTEXT
        department      = cs_department-finance
        department_url  = cs_department_url-finance
        entry_date      = `20120101`                        "#EC NOTEXT
        salary          = `2500000.00`                      "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 6
        first_name      = `Frank`                           "#EC NOTEXT
        last_name       = `Fowler`                          "#EC NOTEXT
        department      = cs_department-finance
        department_url  = cs_department_url-finance
        entry_date      = `20110201`                        "#EC NOTEXT
        salary          = `178250.50`                       "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 7
        first_name      = `Gale`                            "#EC NOTEXT
        last_name       = `Gathers`                         "#EC NOTEXT
        department      = cs_department-finance
        department_url  = cs_department_url-finance
        entry_date      = `20130601`                        "#EC NOTEXT
        salary          = `123470.20`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        department       = cs_department-marketing
        department_url   = cs_department_url-marketing
        hierarchy_level  = 1
      )
      (
        id              = 8
        first_name      = `Haley`                           "#EC NOTEXT
        last_name       = `Hartmann`                        "#EC NOTEXT
        department      = cs_department-marketing
        department_url  = cs_department_url-marketing
        entry_date      = `20101001`                        "#EC NOTEXT
        salary          = `900000`                          "#EC NOTEXT
        currency        = cs_currency_value-japanese_yen
        hierarchy_level = 2
      )
      (
        id              = 9
        first_name      = `Ivana`                           "#EC NOTEXT
        last_name       = `Irakles`                         "#EC NOTEXT
        department      = cs_department-marketing
        department_url  = cs_department_url-marketing
        entry_date      = `20141101`                        "#EC NOTEXT
        salary          = `80000.00`                        "#EC NOTEXT
        currency        = cs_currency_value-japanese_yen
        hierarchy_level = 2
      )
      (
        id              = 10
        first_name      = `Jacobus`                         "#EC NOTEXT
        last_name       = `Jawlinski`                       "#EC NOTEXT
        department      = cs_department-marketing
        department_url  = cs_department_url-marketing
        entry_date      = `20141201`                        "#EC NOTEXT
        salary          = `120000.78`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 1
      )
      (
        department       = cs_department-sales
        department_url   = cs_department_url-sales
        hierarchy_level  = 1
      )
      (
        id              = 11
        first_name      = `Kate`                            "#EC NOTEXT
        last_name       = `Kamony`                          "#EC NOTEXT
        department      = cs_department-sales
        department_url  = cs_department_url-sales
        entry_date      = `20101201`                        "#EC NOTEXT
        salary          = `230000.23`                       "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 12
        first_name      = `Lisa`                            "#EC NOTEXT
        last_name       = `Lavalle`                         "#EC NOTEXT
        department      = cs_department-sales
        department_url  = cs_department_url-sales
        entry_date      = `20110201`                        "#EC NOTEXT
        salary          = `210000.00`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 13
        first_name      = `Martha`                          "#EC NOTEXT
        last_name       = `Meraska`                         "#EC NOTEXT
        department      = cs_department-sales
        department_url  = cs_department_url-sales
        entry_date      = `20130901`                        "#EC NOTEXT
        salary          = `145000.80`                       "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 14
        first_name      = `Nigel`                           "#EC NOTEXT
        last_name       = `Nevers`                          "#EC NOTEXT
        department      = cs_department-sales
        department_url  = cs_department_url-sales
        entry_date      = `20090801`                        "#EC NOTEXT
        leaving_date    = `20141231`                        "#EC NOTEXT
        salary          = `166289.00`                       "#EC NOTEXT
        currency        = cs_currency_value-japanese_yen
        hierarchy_level = 2
      )
      (
        department       = cs_department-research_and_development
        department_url   = cs_department_url-research_and_development
        hierarchy_level  = 1
      )
      (
        id              = 15
        first_name      = `Oprah`                           "#EC NOTEXT
        last_name       = `Olinc`                           "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20090815`                        "#EC NOTEXT
        salary          = `100000.00`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
       (
        id              = 16
        first_name      = `Peter`                           "#EC NOTEXT
        last_name       = `Parker`                          "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20090601`                        "#EC NOTEXT
        salary          = `100000.00`                       "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 17
        first_name      = `Quintus`                         "#EC NOTEXT
        last_name       = `Quirks`                          "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20150401`                        "#EC NOTEXT
        salary          = `82000.50`                        "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 18
        first_name      = `Rasputin`                        "#EC NOTEXT
        last_name       = `Rajkov`                          "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20130601`                        "#EC NOTEXT
        salary          = `71650.85`                        "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 19
        first_name      = `Svetlana`                        "#EC NOTEXT
        last_name       = `Soblinchech`                     "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20130601`                        "#EC NOTEXT
        leaving_date    = `20150630`                        "#EC NOTEXT
        salary          = `78200.40`                        "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 20
        first_name      = `Tanaka`                          "#EC NOTEXT
        last_name       = `Tayoto`                          "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20140101`                        "#EC NOTEXT
        leaving_date    = `20150228`                        "#EC NOTEXT
        salary          = `65000.20`                        "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 21
        first_name      = `Ulysses`                         "#EC NOTEXT
        last_name       = `Uvinger`                         "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20110101`                        "#EC NOTEXT
        salary          = `98200.70`                        "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 22
        first_name      = `Victor`                          "#EC NOTEXT
        last_name       = `Van Damme`                       "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20100401`                        "#EC NOTEXT
        salary          = `150000.00`                       "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
      (
        id              = 23
        first_name      = `Winston`                         "#EC NOTEXT
        last_name       = `Walters`                         "#EC NOTEXT
        department      = cs_department-research_and_development
        department_url  = cs_department_url-research_and_development
        entry_date      = `20091101`                        "#EC NOTEXT
        salary          = `163772.76`                       "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        department       = cs_department-management_accounting
        department_url   = cs_department_url-management_accounting
        hierarchy_level  = 1
      )
      (
        id              = 24
        first_name      = `Xavier`                          "#EC NOTEXT
        last_name       = `Xamentier`                       "#EC NOTEXT
        department      = cs_department-management_accounting
        department_url  = cs_department_url-management_accounting
        entry_date      = `20120501`                        "#EC NOTEXT
        salary          = `79200.00`                        "#EC NOTEXT
        currency        = cs_currency_value-japanese_yen
        hierarchy_level = 2
      )
      (
        id              = 25
        first_name      = `Yuri`                            "#EC NOTEXT
        last_name       = `Ychevich`                        "#EC NOTEXT
        department      = cs_department-management_accounting
        department_url  = cs_department_url-management_accounting
        entry_date      = `20150301`                        "#EC NOTEXT
        salary          = `42000.00`                        "#EC NOTEXT
        currency        = cs_currency_value-us_dollar
        hierarchy_level = 2
      )
      (
        id              = 26
        first_name      = `Zacharias`                       "#EC NOTEXT
        last_name       = `Zalapeta`                        "#EC NOTEXT
        department      = cs_department-management_accounting
        department_url  = cs_department_url-management_accounting
        entry_date      = `20130201`                        "#EC NOTEXT
        leaving_date    = `20150601`                        "#EC NOTEXT
        salary          = `68124.45`                        "#EC NOTEXT
        currency        = cs_currency_value-euro
        hierarchy_level = 2
      )
    ).
  endmethod.


endclass.
