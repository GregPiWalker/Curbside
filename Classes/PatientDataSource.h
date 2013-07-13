//
//  PatientDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "LongPressEventHandler.h"
@class ModificationTracker;
@class Patient;
@class Prescription;
@class Visit;
@class Pharmacy;
@class Contact;


static NSString *const personalInfoLabel = @"Personal Info";
static NSString *const contactInfoLabel = @"Contact Info";
static NSString *const allergiesLabel = @"Allergies";
static NSString *const medicationsLabel = @"Current Medications";
static NSString *const pharmaciesLabel = @"Pharmacies";
static NSString *const visitHistoryLabel = @"Visit History";
static NSString *const isEditingKey = @"isEditing";
static NSString *const isReloadNeededKey = @"isReloadNeeded";


/**
 */
@interface PatientDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    @public
    //NSString *const personalInfoLabel;
    @private
    Patient *patient;
    id<LongPressEventHandler> longPressHandler;
    UITableView *tableView;
    //
    NSMutableArray *orderedSectionTitles;
                                                                    //
    NSArray *groupedPropertyNames;
                                                                    //
    NSMutableDictionary *sectionedData;
    // Dictionary of Property name keys and Property value values.
    NSMutableDictionary *changedProperties;
                                                                    //
    UITextField *fieldBeingEdited;
    
    BOOL isEditEnabled;
    BOOL isEditing;
    BOOL isObservingPatient;
    BOOL isReloadNeeded;
    BOOL canSelectVisits;
    NSInteger extraRowCount;
    NSIndexPath *lastAddedIndexPath;
    
    NSMutableArray *allergies;
    NSMutableArray *pharmacies;
    NSMutableArray *visits;
    NSMutableArray *medications;
}


///
@property (nonatomic, assign) id<LongPressEventHandler> longPressHandler;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly) NSString *personalInfoLabel;
@property (nonatomic, readonly) NSString *allergiesLabel;
@property (nonatomic, readonly) NSString *pharmaciesLabel;
@property (nonatomic, readonly) NSString *medicationsLabel;
@property (nonatomic, readonly) NSString *visitHistoryLabel;

@property (nonatomic, assign) NSInteger extraRowCount;

@property (nonatomic, readonly) NSInteger extraSectionCount;

@property (nonatomic, assign) BOOL isReloadNeeded;
@property (nonatomic, assign) BOOL canSelectVisits;
/**
 */
@property (nonatomic, retain) Patient *patient;

/**
 */
@property (nonatomic, retain) NSString *firstName;

/**
 */
@property (nonatomic, retain) NSString *lastName;

/*
 */
@property (nonatomic, retain) NSString *dateOfBirth;

/*
 */
@property (nonatomic, readonly, assign) NSString *age;

/*
 */
@property (nonatomic, retain) NSString *address;

/*
 */
@property (nonatomic, retain) NSString *city;

/*
 */
@property (nonatomic, retain) NSString *state;

/*
 */
@property (nonatomic, retain) NSString *phone;

/*
 */
@property (nonatomic, retain) NSString *email;

/*
 */
@property (nonatomic, retain) NSString *zip;

/*
 */
@property (nonatomic, retain/*readonly*/) NSMutableArray *allergies;

/*
 */
@property (nonatomic, retain/*readonly*/) NSMutableArray *pharmacies;

/*
 */
@property (nonatomic, retain/*readonly*/) NSMutableArray *priorVisits;

/*
 */
@property (nonatomic, retain/*readonly*/) NSMutableArray *medications;

/**
 */
@property (nonatomic, retain) NSMutableDictionary *sectionedData;

/**
 */
@property (nonatomic, retain) NSMutableArray *orderedSectionTitles;

/**
 */
@property (nonatomic, assign) BOOL isEditEnabled;

/**
 */
@property (nonatomic, assign) BOOL isEditing;

/**
 */
@property (nonatomic, assign) BOOL isObservingPatient;

/**
 */
@property (nonatomic, retain) UITextField *fieldBeingEdited;

@property (nonatomic, readonly) NSIndexPath *lastAddedIndexPath;

/**
 Initialize a PatientDataSource using the given Patient.  TableCell editability is set to isEditable value.
 */
-(id) initWithPatient: (Patient *)p allowCellEdit: (BOOL)isEditable ;

/**
 Get the IndexPath of the TableCell that holds the Date of Birth.
 */
-(NSIndexPath *) indexPathOfBirthdayCell;
-(NSIndexPath *) indexPathOfStateCell;
-(NSIndexPath *) indexPathOfZipCell;
-(NSIndexPath *) indexPathOfEmailCell;
-(NSIndexPath *) indexPathOfPhoneCell;

-(NSInteger) sectionNumberForSectionTitle: (NSString *)sectionTitle;
-(id) dataItemForIndexPath: (NSIndexPath *)indexPath;
-(void) purgeUnfinishedRow;

///
-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void) insertRowForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath;
-(void) removeRowForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath;

/**
 */
-(ModificationTracker *) applyChanges;

-(void) refreshSectionHeadings;

/**
 */
-(void) forgetChanges;

-(void) dismissKeyboard;

-(void) reset;

-(void) reloadTableData;

/**
 */
-(void) stopObservingPatientNotifications;

-(void) addPropertyChangeObserver: (NSObject *)observer;
-(void) removePropertyChangeObserver: (NSObject *)observer;
-(void) addTableRowInsertedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeTableRowInsertedObserver: (NSObject *)observer;
-(void) addTableRowRemovedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeTableRowRemovedObserver: (NSObject *)observer;
-(void) addShowPharmacyViewRequestObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeShowPharmacyViewRequestObserver: (NSObject *)observer;

@end