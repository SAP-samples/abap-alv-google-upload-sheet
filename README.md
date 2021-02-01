![](https://img.shields.io/badge/STATUS-NOT%20CURRENTLY%20MAINTAINED-red.svg?longCache=true&style=flat)

# Important Notice
This public repository is read-only and no longer maintained.

# Description

This project comprises an archive containing sample source code for the integration of Google Sheets into the ABAP List Viewer (ALV) component. Thus, this sample code helps you to implement and configure the export of ALV grid data from SAP GUI directly to Google Drive and display exported data snapshots automatically in Google Sheets.

## Minimum Requirements

- This functionality is only available for certain SAP NetWeaver support packages, see [note 2592115](http://service.sap.com/sap/support/notes/2592115).
- After installation of the corresponding Support Package, it is **mandatory** to implement [note 2624404](http://service.sap.com/sap/support/notes/2624404) (ALV GUI: BAdi Export Integration Corrections).

# Download and Installation

## Proceed as follows to make best use of the sample code:

1. Clone the repository or use the [abapGit client](https://docs.abapgit.org/) to [import](https://docs.abapgit.org/guide-import-zip.html) the sources into your SAP system.
2. Setup the Google API Endpoint (see chapter 2.2 in [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html) )
3. Create a Service Provider Type for Google (see chapter 2.3.1 [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html))
4. Create an OAuth 2.0 Client Profile (see chapter 2.3.6 [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html))
5. Configure the Access to Google APIs (see chapter 2.4 [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html))
6. Check the Connection (see chapter 2.5. [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html))
7. ALV ABAP administration (see chapter 3.2 [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html))


# Configuration Guide

See the full documentation [Export of ALV Grid Data to Google Sheets](https://www.sap.com/documents/2018/07/56e0dd6d-0f7d-0010-87a3-c30de2ffd8ff.html) available in the SAP Community.

# Known Issues

None.

# How to obtain support

You can ask your questions concerning this functionality in the [SAP Community](https://www.sap.com/community.html). Please, use _ABAP Development_ as primary tag and choose _alv_ as additional user tag.

You find an overview of all ALV questions under: [https://answers.sap.com/topics/alv.html](https://answers.sap.com/topics/alv.html).

# License
Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved.

This file is licensed under the SAP SAMPLE CODE LICENSE AGREEMENT except as noted otherwise in the [LICENSE](LICENSE) file.

Note that the sample code includes calls to the Google Drive APIs which calls are licensed under the Creative Commons Attribution 3.0 License _(_[_https://creativecommons.org/licenses/by/3.0/_](https://creativecommons.org/licenses/by/3.0/)_)_ in accordance with Google&#39;s Developer Site Policies _(_[_https://developers.google.com/terms/site-policies_](https://developers.google.com/terms/site-policies)_)._ Furthermore, the use of the Google Drive service is subject to applicable agreements with Google Inc.
