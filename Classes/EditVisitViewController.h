//
//  NewVisitViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ViewControllerBase.h"
#import "NotificationArgs.h"
#import "ModificationTracker.h"
#import "ParentViewDelegate.h"

@class Visit;
@class RxListDataSource;
@class PatientLookupDataSource;
@class EditRxViewController;
@class EditPatientViewController;
@class PatientViewController;
@class VisitViewController;


typedef enum {
    PatientControlTag = 0,
    ChiefComplaintControlTag = 1,
    HistoryPresentIllnessControlTag = 2,
    PhysicalExamControlTag = 3,
    ImpressionControlTag = 4,
    PlanControlTag = 5,
    PrescriptionsTableControlTag = 6
} TextViewTagMap;


@interface EditVisitViewController : ViewControllerBase <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
@private
    Visit *visit;
    Visit *tempVisit;
    RxListDataSource *rxDataSource;
    id<ParentViewDelegate> parentView;
    PatientLookupDataSource *lookupTableDataSource;
    PatientViewController *patientViewController;
    EditRxViewController *editRxViewController;
    EditPatientViewController *editPatientViewController;
    MFMailComposeViewController* autoGenMailer;
    NSInteger numAdditionalRows;
    NSInteger maxLookupTableRows;
    NSInteger initialTableViewHeight;
    BOOL useNewPatient;
    BOOL persistViewUntilMailerFinshes;
    UIView *controlBeingEdited;
    UILabel *prescriptionsLabel;
    UILabel *nameLabel;
    UILabel *ccLabel;
    UILabel *hpiLabel;
    UILabel *impLabel;
    UILabel *planLabel;
    UILabel *peLabel;
    UIDatePicker *datePickerView;
    IBOutlet UIButton *showPatientButton;
    IBOutlet UIToolbar *callinToolBar;
    IBOutlet UITextField *patientTextField;
    IBOutlet UITextField *creationDateTextField;
    UITableView *autocompleteTableView;
    IBOutlet UITableView *prescriptionsTableView;
    UIBarButtonItem *saveButton;
    UIBarButtonItem *dismissEditorButton;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollContentView;
    IBOutlet UITextField *ccTextView;
    IBOutlet UITextView *hpiTextView;
    IBOutlet UITextView *peTextView;
    IBOutlet UITextView *impTextView;
    IBOutlet UITextView *planTextView;
    IBOutlet UIToolbar *toolbar;
    BOOL isToolbarHidden;
    BOOL isNewVisit;
    BOOL allowEditPatientField;
    BOOL needsViewRefresh;
}

@property (nonatomic, retain) Visit *visit;

@property (nonatomic, retain) RxListDataSource *rxDataSource;

@property (nonatomic, retain) EditRxViewController *editRxViewController;

@property (nonatomic, assign) NSInteger lastSelectedRxIndex;

@property (nonatomic, readonly) BOOL isNewVisit;

@property (nonatomic, assign) BOOL isToolbarHidden;

@property (nonatomic, assign) BOOL isPatientButtonHidden;

@property (nonatomic, readonly) BOOL allowEditPatientField;

@property (nonatomic, assign) BOOL useNewPatient;

@property (nonatomic, retain) IBOutlet PatientLookupDataSource *lookupTableDataSource;

@property (nonatomic, retain) IBOutlet UITableView *autocompleteTableView;

@property (nonatomic, retain, readonly) UITextField *patientTextField;

@property (nonatomic, retain, readonly) UITableView *prescriptionsTableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissEditorButton;

@property (nonatomic, assign, readonly) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) UIView *scrollContentView;

@property (nonatomic, retain) IBOutlet UIDatePicker *datePickerView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *ccLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpiLabel;
@property (nonatomic, retain) IBOutlet UILabel *impLabel;
@property (nonatomic, retain) IBOutlet UILabel *planLabel;
@property (nonatomic, retain) IBOutlet UILabel *peLabel;
@property (nonatomic, retain) IBOutlet UILabel *prescriptionsLabel;

@property (nonatomic, retain) PatientViewController *patientViewController;

@property (nonatomic, retain) EditPatientViewController *editPatientViewController;

/// This view's ParentViewDelegate that handles dismissal operations.
@property (nonatomic, assign) id<ParentViewDelegate> parentView;

@property (nonatomic, retain) NSString *creationDate;
@property (nonatomic, retain) NSString *patientName;
@property (nonatomic, retain) NSString *historyPresentIllness;
@property (nonatomic, retain) NSString *chiefComplaint;
@property (nonatomic, retain) NSString *impression;
@property (nonatomic, retain) NSString *plan;
@property (nonatomic, retain) NSString *physicalExam;

-(IBAction) viewPatientAction: (id)sender;
-(IBAction) saveVisitAction: (id)sender;
-(IBAction) updateVisitAction: (id)sender;
-(IBAction) setChiefComplaintAction: (id)sender;
-(IBAction) dismissKeyboardAction: (id)sender;
-(IBAction) setCreationDateAction: (id)sender;
-(IBAction) dismissDatePickerAction: (id)sender;

-(id) initForEditWithVisit: (Visit *)v;

-(id) initWithNewVisit: (Visit *)v;

-(void) dismissKeyboard;

@end
