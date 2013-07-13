/*
 *  Constants.h
 *  CurbSide
 *
 *  Created by Greg Walker on 3/9/11.
 *  Copyright 2011 Home. All rights reserved.
 *
 */


/// Common Property Keys
static NSString *const identKey = @"ident";
static NSString *const nameKey = @"name";
static NSString *const allergiesKey = @"allergies";
static NSString *const medicationsKey = @"medications";
static NSString *const priorVisitsKey = @"priorVisits";
static NSString *const visitsKey = @"visits";
static NSString *const visitKey = @"visit";
static NSString *const pharmaciesKey = @"pharmacies";
static NSString *const dateOfBirthKey = @"dateOfBirth";
static NSString *const patientsKey = @"patients";
static NSString *const contactsKey = @"contacts";
static NSString *const patientKey = @"patient";
static NSString *const prescriptionsKey = @"prescriptions";
static NSString *const fieldBeingEditedKey = @"fieldBeingEdited";

/// Data Keys
static NSString *const kDataGroupKeys = @"keysKey";
static NSString *const kDataGroupValues = @"valuesKey";
static NSString *const kPreferenceKey = @"Key";
static NSString *const kPreferenceValue = @"DefaultValue";
static NSString *const kPreferenceContainerKey = @"PreferenceSpecifiers";

// Application Setting Keys (changing these will result in lost user settings)
static NSString *const kThemeSetting = @"themeSelectorKey";
static NSString *const kNameSortSetting = @"nameSortSelectorKey";
static NSString *const kDateSortSetting = @"dateSortSelectorKey";
static NSString *const kReportEmailSetting = @"reportDestinationKey";
static NSString *const kAutoGenerateReportSetting = @"autogenReportKey";

/// Event Notifications
static NSString *const kTableRowInsertedNotification = @"cTableRow";
static NSString *const kTableRowRemovedNotification = @"dTableRow";
static NSString *const kPatientTableCellTextWillUpdateNotification = @"wuPatientTableCell";
static NSString *const kPharmacyTableCellTextWillUpdateNotification = @"wuPharmacyTableCell";

static NSString *const kPatientCreatedNotification = @"cPatient";
static NSString *const kPatientUpdatedNotification = @"uPatient";
static NSString *const kPatientDeletedNotification = @"dPatient";

static NSString *const kContactCreatedNotification = @"cContact";
static NSString *const kContactUpdatedNotification = @"uContact";
static NSString *const kContactDeletedNotification = @"dContact";

static NSString *const kPharmacyCreatedNotification = @"cPharmacy";
static NSString *const kPharmacySavedNotification = @"sPharmacy";
static NSString *const kPharmacyReferencedNotification = @"rPharmacy";
static NSString *const kPharmacyUpdatedNotification = @"uPharmacy";
static NSString *const kPharmacyDeletedNotification = @"dPharmacy";
static NSString *const kShowPharmacyViewNotification = @"vPharmacy";

static NSString *const kPrescriptionCreatedNotification = @"cPrescription";
static NSString *const kPrescriptionUpdatedNotification = @"uPrescription";
static NSString *const kPrescriptionDeletedNotification = @"dPrescription";
static NSString *const kPrescriptionSelectedNotification = @"vPrescription";

static NSString *const kVisitCreatedNotification = @"cVisit";
static NSString *const kVisitUpdatedNotification = @"uVisit";
static NSString *const kVisitDeletedNotification = @"dVisit";

static NSString *const kThemeSettingChangedNotification = @"uTheme";
static NSString *const kNameSortSettingChangedNotification = @"uNameSort";
static NSString *const kDateSortSettingChangedNotification = @"uDateSort";

/// Shared Strings
static NSString *const kDateFormatterFormat = @"MM/dd/yyyy";
static NSString *const kTimeFormatterFormat = @"h:mma";
static NSString *const kDayFormatterFormat = @"EEEE";
static NSString *const kMonthFormatterFormat = @"MMMM";
static NSString *const kYearFormatterFormat = @"yyyy";
static NSString *const kDateTimeFormatterFormat = @"hh:mm MM/dd/yyyy";
static NSString *const kMonthYearDateFormat = @"MMMM yyyy"; // Date format with long month name followed by all 4 year digits.
static NSString *const kDateTimeAmPmFormatterFormat = @"h:mma  MM/dd/yyyy";
static NSString *const kDateTimeAmPmEscapedFormatterFormat = @"h.mma_MM-dd-yyyy";
static NSString *const kHtmlMimeType = @"text/html";
static NSString *const kCurbsideMimeType = @"application/curbside-data";
static NSString *const kCurbsideCompressedMimeType = @"application/curbside-compressed-data";
static NSString *const kReportTitlePattern = @"${report.title}";
static NSString *const kPatientNamePattern = @"${patient.fullName}";
static NSString *const kFieldNamePattern = @"${field.name}";
static NSString *const kFieldValuePattern = @"${field.value}";
static NSString *const kItemCountPattern = @"${item.count}";
static NSString *const feedbackRecipientAddress = @"codewhisperers@gmail.com";
static NSString *const kVisitSubjectPrefix = @"Curbside Visit Report: ";
static NSString *const kPatientSubjectPrefix = @"Curbside Patient Report: ";
static NSString *const kExportSubjectPrefix = @"Curbside Data Backup: ";

/// Background Images
static NSString *const imgScrubsBackground2 = @"Scrubs02.png";
static NSString *const imgScrubsBackground1 = @"Scrubs01.png";
static NSString *const imgScrubsBackground3 = @"Scrubs03.png";
static NSString *const imgScrubsBackground4 = @"Scrubs04.png";
static NSString *const imgLeatherBackground1 = @"Leather.png";
static NSString *const imgPillsBackground1 = @"Pills01.png";
static NSString *const imgPillsBackground2 = @"Pills02.png";
static NSString *const imgPillsBackground3 = @"Pills03.png";
static NSString *const imgPillsBackground4 = @"Pills04.png";
static NSString *const imgWoodBackground1 = @"Wood1.png";
static NSString *const imgWoodBackground2 = @"Wood2.png";
static NSString *const imgXrayBackground1 = @"X-Ray01.png";
static NSString *const imgXrayBackground2 = @"X-Ray02.png";
static NSString *const imgXrayBackground3 = @"X-Ray03.png";
static NSString *const imgXrayBackground4 = @"X-Ray04.png";

/// Button Images
static NSString *const imgRedButtonGradient = @"red_gradient.png";
static NSString *const imgLightBlueButtonGradient = @"light_blue_grad_160x37.png";
static NSString *const imgWhiteButtonGradient = @"white_grad_160x37.png";
static NSString *const imgBrownButtonGradient = @"brown_grad_160x37.png";
static NSString *const imgTanButtonGradient = @"tan_grad_160x37.png";
static NSString *const imgBlackButtonGradient = @"black_grad_160x37.png";
static NSString *const imgLogoBag = @"LogoBag_232x170.png";
static NSString *const imgBorderedLogoBag = @"LogoBagBordered_232x170.png";

/// Resources
static NSString *const rsrcBlueCheckmarkImage = @"blueCheckmark_15x15";
static NSString *const rsrcUsageTipsHtml = @"UsageTips";
static NSString *const rsrcHtmlReportHeader = @"HtmlReportHeader";
static NSString *const rsrcHtmlReportFooter = @"HtmlReportFooter";
static NSString *const rsrcHtmlVisitHeader = @"HtmlVisitHeader";
static NSString *const rsrcHtmlVisitBody1 = @"HtmlVisitBody1";
static NSString *const rsrcHtmlVisitBody2 = @"HtmlVisitBody2";
static NSString *const rsrcHtmlVisitFooter = @"HtmlVisitFooter";
static NSString *const rsrcHtmlPrescriptionHeader = @"HtmlPrescriptionHeader";
static NSString *const rsrcHtmlPrescriptionBody1 = @"HtmlPrescriptionBody1";
static NSString *const rsrcHtmlPrescriptionBody2 = @"HtmlPrescriptionBody2";
static NSString *const rsrcHtmlPrescriptionBody3 = @"HtmlPrescriptionBody3";
static NSString *const rsrcHtmlPrescriptionFooter = @"HtmlPrescriptionFooter";

/// File Names and Extensions
static NSString *const dirSettingsBundle = @"Settings.bundle";
static NSString *const fileSettingsPlist = @"Root.plist";
static NSString *const extHtml = @"html";
static NSString *const extTxt = @"txt";
static NSString *const extPng = @"png";
static NSString *const kPatientsFileName = @"patients.dar";
static NSString *const kVisitsFileName = @"visits.dar";
static NSString *const kPharmaciesFileName = @"pharmacies.dar";
static NSString *const kPrescriptionsFileName = @"prescriptions.dar";
static NSString *const kTmpFileMarker = @"~";
static NSString *const kCurbsideDocsDir = @"Curbside";
static NSString *const kCurbsideDataDir = @"data";
static NSString *const kArchiveContainerName = @"CurbsideBackup";
//static NSString *const kArchiveFilePrefix = @"backup";
static NSString *const extArchive = @"csd";
static NSString *const extCompressedArchive = @"csdz";


static const int AdditionalVerticalSpace = 176;
