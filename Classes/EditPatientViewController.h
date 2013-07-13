//
//  EditPatientViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ViewControllerBase.h"
#import "ApplicationSupervisor.h"
#import "NotificationArgs.h"
#import "ModificationTracker.h"
#import "LongPressEventHandler.h"
#import "ParentViewDelegate.h"
#import "SetDefaultMenuItem.h"
@class PatientDataSource;
@class EditPharmacyViewController;
@class PharmacyViewController;
@class Patient;
@class Contact;
@class Pharmacy;

//typedef enum {
//    ScrollNone,
//    ScrollRight,
//    ScrollLeft,
//    ScrollUp,
//    ScrollDown
//} ScrollDirection;

/**
 This view shows the mutable properties of an existing patient, or empty properties
 for a new patient.  The user can cancel or save any changes.
 */
@interface EditPatientViewController : ViewControllerBase <ParentViewDelegate, UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate, LongPressEventHandler> {
@private
    id<ParentViewDelegate> parentView;
    EditPharmacyViewController *editPharmacyView;
    //PharmacyViewController *pharmacyView;
    UIScrollView *scrollView;
    UIView *scrollContentView;
    UINavigationBar *navBar;
    UINavigationBar *importBar;
    UITableView *tableView;
    UIDatePicker *pickerView;
    UIBarButtonItem *dismissEditorButton;
    UIBarButtonItem *saveButton;
    UIButton *deletePatientButton;
    PatientDataSource *dataSource;
    Patient *patient;
    BOOL isNewPatient;
    BOOL isAtTopOfScroll;
    BOOL isImportBarHidden;
    BOOL needsViewRefresh;
    NSInteger numAdditionalRows;
    NSInteger lastScrollOffset;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIView *scrollContentView;

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

@property (nonatomic, retain) IBOutlet UINavigationBar *importBar;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissEditorButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, retain) IBOutlet UIButton *deletePatientButton;

@property (nonatomic, retain) EditPharmacyViewController *editPharmacyView;

/// This view's ParentViewDelegate that handles dismissal operations.
@property (nonatomic, assign) id<ParentViewDelegate> parentView;

/// This is the data source that provides all of the Patient data for TableViews.
@property (nonatomic, readonly) PatientDataSource *dataSource;

/**
 */
@property (nonatomic, readonly) BOOL isNewPatient;

/**
 The patient being edited.
 */
@property (nonatomic, retain) Patient *patient;

/**
 */
-(id) initForEditWithPatient: (Patient *) existingPatient;

-(id) initWithNewPatient: (Patient *) newPatient;

/// If this view's NavigationController is a child of another NavigationController, set the state to wasPopped=YES.
-(void) setViewWasPopped;

/**
 */
-(IBAction) cancelAction: (id)sender;

/**
 */
-(IBAction) savePatientAction: (id)sender;

/**
 */
-(IBAction) setDateAction: (id)sender;

/**
 */
-(IBAction) dismissDatePickerAction: (id)sender;

/**
 */
-(IBAction) deletePatientAction: (id)sender;

/**
 */
-(IBAction) importPatientDataAction: (id)sender;

-(IBAction) hideDataImportToolbarAction: (id)sender;

@end
