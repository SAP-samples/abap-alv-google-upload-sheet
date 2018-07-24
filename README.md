## **README**

### **Description**

This project comprises an archive containing sample source code for the integration of Google Sheets into the ABAP List Viewer (ALV) component. Thus, this sample code helps you to implement and configure the export of ALV grid data from SAP GUI directly to Google Drive and display exported data snapshots automatically in Google Sheets.

### **Requirements**

- To be able to use the sample code, you need SAP NetWeaver 7.40 SP20 or SAP NetWeaver 7.50 SP12.
- After installation of the corresponding Support Package, it is **mandatory** to implement [note 2624404](http://service.sap.com/sap/support/notes/2624404) (ALV GUI: BAdi Export Integration Corrections).

### **Download and Installation**

### Proceed as follows to make best use of the sample code:

1. Download the sample code to your local machine.
2. Create an ABAP interface for each file starting with prefix ZIF\_, copy the file&#39;s source code into it via source editor and activate the interface.
3. Create an ABAP class for each file starting with prefix ZCL\_, copy the file&#39;s source code into it via source editor and activate the class.
4. Create an ABAP program for each file starting with prefix Z\_, copy the file&#39;s source code into it via source editor and activate the program.
5. The program Z\_GOOGLEPOC\_DRIVE\_API invokes the Google Drive API using the ABAP OAuth 2.0 client for authentication. Launch it to show the demonstration of the Google Drive REST API invocation. It tests the connection and gives hints wherever a failure might occur.

### **Configuration**

After download and installation, proceed as described in the documentation [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html) available in the SAP Community.

### **Known Issues**

None.

### **How to obtain support**

You can ask your questions concerning this functionality in the [SAP Community](https://www.sap.com/community.html). Please, use _ABAP Development_ as primary tag and choose _alv_ as additional user tag.

You find an overview of all ALV questions under: [https://answers.sap.com/topics/alv.html](https://answers.sap.com/topics/alv.html).

### **License**
Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved.

This file is licensed under the SAP SAMPLE CODE LICENSE AGREEMENT except as noted otherwise in the [LICENSE](LICENSE) file.

Note that the sample code includes calls to the Google Drive APIs which calls are licensed under the Creative Commons Attribution 3.0 License _(_[_https://creativecommons.org/licenses/by/3.0/_](https://creativecommons.org/licenses/by/3.0/)_)_ in accordance with Google&#39;s Developer Site Policies _(_[_https://developers.google.com/terms/site-policies_](https://developers.google.com/terms/site-policies)_)._ Furthermore, the use of the Google Drive service is subject to applicable agreements with Google Inc.