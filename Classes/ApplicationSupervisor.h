//
//  ApplicationSupervisor.h
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VisualThemeManager.h"
#import "SynthesizeSingleton.h"
#import "NSDataCompressionCategory.h"

@class OrderedMutableDictionary;
@class FileArchiveResult;
@class Patient;
@class Contact;
@class Visit;
@class Pharmacy;
@class Prescription;
@class Medication;


/// The order of values here must match those in Root.plist
typedef enum {
    ORDER_NOT_FOUND,
    ORDER_BY_FIRST_NAME,
    ORDER_BY_LAST_NAME
} NameSortOrder;


/**
 The singleton Supervisor for application-wide data mediation, event handling, etc.
 */
@interface ApplicationSupervisor : NSObject {
    // Dictionary of Patients indexed by the Patient ident
    NSMutableDictionary *patients;
    OrderedMutableDictionary *visits;
    NSMutableDictionary *pharmacies;
    OrderedMutableDictionary *prescriptions;
    VisualThemeManager *themeManager;
    NSString *userEmailAddressSetting;
    NameSortOrder nameSortOrderSetting;
    NSComparisonResult dateSortOrderSetting;
    BOOL autoGenerateVisitReport;
}

/// Get an autoreleased array of all loaded Patient objects.
@property (nonatomic, readonly) NSArray *patients;

/// Get an autoreleased array of all loaded Visit objects.
@property (nonatomic, readonly) NSArray *visits;

/// Get an autoreleased array of all loaded Pharmacy objects.
@property (nonatomic, readonly) NSArray *pharmacies;

/// Get an autoreleased array of all loaded Prescription objects.
@property (nonatomic, readonly) NSArray *prescriptions;

/// The current visual theme.
@property (nonatomic, assign) VisualTheme currentThemeSetting;

@property (nonatomic, readonly) VisualThemeManager *themeManager;

@property (nonatomic, readonly) NSString *releaseVersionString;

@property (nonatomic, retain) NSString *userEmailAddressSetting;

@property (nonatomic, assign) NameSortOrder nameSortOrderSetting;

@property (nonatomic, assign) NSComparisonResult dateSortOrderSetting;

@property (nonatomic, assign) BOOL autoGenerateVisitReport;

+(ApplicationSupervisor *) instance;

-(void) unloadData;

/// Returns a FileArchiveResult of the newly created data archive, or nil on failure.
-(FileArchiveResult *) archiveCurbsideData;

/// Save the given data archive result to a backup file in the app's Documents directory.
-(void) saveArchiveToDisk: (FileArchiveResult *)archiveResult;

/// Open and import data from a Curbside archive specified by the given file name.
-(BOOL) importDataFromFile: (NSString *)fileName;

/// Open and import data from a Curbside archive specified by the given URL.
-(BOOL) importDataFromUrl: (NSURL *)srcUrl;

// Gets a list of all available data archives specified by their name.
-(NSArray *) listArchiveFiles;

-(void) addThemeSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeThemeSettingChangedObserver: (NSObject *)observer;

-(void) addNameSortSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeNameSortSettingChangedObserver: (NSObject *)observer;

-(void) addDateSortSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeDateSortSettingChangedObserver: (NSObject *)observer;

-(void) addPatientCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePatientCreatedObserver: (NSObject *)observer;

-(void) addPatientUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePatientUpdatedObserver: (NSObject *)observer;

-(void) addPatientDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePatientDeletedObserver: (NSObject *)observer;

-(void) addVisitCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeVisitCreatedObserver: (NSObject *)observer;

-(void) addVisitUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeVisitUpdatedObserver: (NSObject *)observer;

-(void) addVisitDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeVisitDeletedObserver: (NSObject *)observer;

-(void) addPrescriptionCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePrescriptionCreatedObserver: (NSObject *)observer;

-(void) addPrescriptionUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePrescriptionUpdatedObserver: (NSObject *)observer;

-(void) addPrescriptionDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePrescriptionDeletedObserver: (NSObject *)observer;

-(void) addPharmacyCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePharmacyCreatedObserver: (NSObject *)observer;

-(void) addPharmacyUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePharmacyUpdatedObserver: (NSObject *)observer;

-(void) addPharmacyDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePharmacyDeletedObserver: (NSObject *)observer;

-(void) addTableViewCellWillUpdateObserver: (NSObject *)observer withHandler: (SEL)notificationHandler forNotificationName: (NSString *)n;
-(void) removeTableViewCellWillUpdateObserver: (NSObject *)observer forNotificationName: (NSString *)n;

-(void) savePatientData;
-(void) createPatient: (Patient *)p;
-(void) updatePatient: (Patient *)p;
-(void) deletePatient: (Patient *)p;
-(BOOL) hasEquivalentPatient: (Patient *)p;
-(BOOL) hasIdenticalPatient: (Patient *)p;

-(void) savePharmacyData;
-(Pharmacy *) pharmacyWithIdent: (NSString *)ident;
-(void) createPharmacy: (Pharmacy *)p;
-(void) createPharmacies: (NSArray *)pharms;
-(void) updatePharmacy: (Pharmacy *)p;
-(void) deletePharmacy: (Pharmacy *)p;
-(void) deletePharmacies: (NSArray *)pharms;

-(void) savePrescriptionData;
-(Prescription *) prescriptionWithIdent: (NSString *)ident;
-(void) createPrescription: (Prescription *)p;
-(void) createPrescriptions: (NSArray *)rxs;
-(void) updatePrescription: (Prescription *)p;
-(void) deletePrescription: (Prescription *)p;
-(void) deletePrescriptions: (NSArray *)rxs;

-(void) saveVisitData;
-(Visit *) visitWithIdent: (NSString *)ident;
-(void) createVisit: (Visit *)v;
-(void) updateVisit: (Visit *)v;
-(void) deleteVisit: (Visit *)v;
-(void) deleteVisits: (NSArray *)vizits;


@end