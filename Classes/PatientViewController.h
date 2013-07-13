//
//  PatientViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ParentViewDelegate.h"
#import "LongPressEventHandler.h"
#import "ModificationTracker.h"

@class Patient;
@class Visit;
@class Pharmacy;
@class PatientDataSource;
@class EditPatientViewController;
@class EditVisitViewController;
@class VisitViewController;
@class PharmacyViewController;


/**
 This view shows the immutable properties of an existing patient.  It can spawn
 an instance of EditPatientView, which presents the same patient's properties mutably.
 */
@interface PatientViewController : UIViewController <ParentViewDelegate, UIScrollViewDelegate, LongPressEventHandler, MFMailComposeViewControllerDelegate> {
@private
    UITableView *tableView;
    UIScrollView *scrollView;
    UIViewController *parentView;
    PatientDataSource *dataSource;
    Patient *patient;
    EditPatientViewController *editPatientViewController;
    VisitViewController *visitViewController;
    PharmacyViewController *pharmacyView;
    BOOL needsViewRefresh;
    BOOL wasViewPopped;
    //BOOL isNewPatient;
    BOOL isToolbarHidden;
    BOOL canSelectVisits;
    NSInteger numAdditionalRows;
    NSInteger numAdditionalSections;
    UIBarButtonItem *exportVisitsButton;
    UIBarButtonItem *editButton;
    IBOutlet UIToolbar *toolbar;
}

/**
 */
@property (nonatomic, retain) Patient *patient;

@property (nonatomic, assign) UIViewController *parentView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

//@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UIColor *headingTextColor;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *exportVisitsButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;

/**
 This is the data source that provides all of the Patient data for TableViews.
 */
@property (nonatomic, retain) PatientDataSource *dataSource;

@property (nonatomic, retain) IBOutlet EditPatientViewController *editPatientViewController;

@property (nonatomic, assign) BOOL canSelectVisits;

@property (nonatomic, assign, readonly) BOOL showEditButton;

/**
 */
-(id) initWithPatient: (Patient *) existingPatient;

-(void) viewWasPopped;

/**
 */
-(IBAction) editPatientAction: (id)sender;

-(IBAction) emailVisitsReportAction: (id)sender;

@end
