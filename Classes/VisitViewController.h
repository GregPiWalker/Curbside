//
//  NewVisitViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NotificationArgs.h"
#import "ParentViewDelegate.h"
@class Visit;
@class Patient;
@class EditVisitViewController;
@class PatientViewController;
@class RxViewController;
@class RxListDataSource;


@interface VisitViewController : UIViewController <MFMailComposeViewControllerDelegate, ParentViewDelegate> {
@private
    Visit *visit;
    //id data;
    EditVisitViewController *editVisitView;
    PatientViewController *patientViewController;
    RxViewController *rxView;
    UIViewController *parentView;
    NSInteger initialTimeLabelsViewHeight;
    NSInteger initialTableViewHeight;
    NSInteger numAdditionalRows;
    RxListDataSource *rxDataSource;
    BOOL wasViewPopped;
    BOOL needsViewRefresh;
    BOOL isEditButtonHidden;
    BOOL isObservingVisit;
    BOOL isShowPatientButtonHidden;
    BOOL isCallinButtonHidden;
    IBOutlet UITableView *rxTableView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollContentView;
    IBOutlet UIView *timeLabelsView;
    IBOutlet UITextField *patientTextField;
    IBOutlet UITextField *ccTextField;
    IBOutlet UITextView *hpiTextArea;
    IBOutlet UITextView *impressionTextArea;
    IBOutlet UITextView *planTextArea;
    IBOutlet UITextView *physExamTextArea;
    IBOutlet UIToolbar *toolbar;
    UIBarButtonItem *callDefaultPharmacyButton;
    UIBarButtonItem *emailReportButton;
    UIBarButtonItem *editButton;
    UIButton *showPatientButton;
    UILabel *creationLabel;
    UILabel *creationTimeLabel;
    UILabel *callinLabel;
    UILabel *callinTimeLabel;
    UILabel *prescriptionsLabel;
    UILabel *nameLabel;
    UILabel *ccLabel;
    UILabel *hpiLabel;
    UILabel *impLabel;
    UILabel *planLabel;
    UILabel *peLabel;
}

@property (nonatomic, retain) Visit *visit;

@property (nonatomic, retain) RxListDataSource *rxDataSource;

@property (nonatomic, assign) UIViewController *parentView;

@property (nonatomic, assign, readonly) UIScrollView *scrollView;

@property (nonatomic, readonly) UITableView *rxTableView;

@property (nonatomic, assign, readonly) UIView *scrollContentView;

@property (nonatomic, assign, readonly) UIView *timeLabelsView;

@property (nonatomic, assign) NSString *patientName;
@property (nonatomic, assign) NSString *chiefComplaint;
@property (nonatomic, assign) NSString *historyPresentIllness;
@property (nonatomic, assign) NSString *impression;
@property (nonatomic, assign) NSString *plan;
@property (nonatomic, assign) NSString *physicalExam;
@property (nonatomic, assign) NSString *creationTime;
@property (nonatomic, assign) NSString *callinTime;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *ccLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpiLabel;
@property (nonatomic, retain) IBOutlet UILabel *impLabel;
@property (nonatomic, retain) IBOutlet UILabel *planLabel;
@property (nonatomic, retain) IBOutlet UILabel *peLabel;
@property (nonatomic, retain) IBOutlet UILabel *callinLabel;
@property (nonatomic, retain) IBOutlet UILabel *callinTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *creationLabel;
@property (nonatomic, retain) IBOutlet UILabel *creationTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *prescriptionsLabel;
@property (nonatomic, retain) IBOutlet UIButton *showPatientButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *callDefaultPharmacyButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *emailReportButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;

@property (nonatomic, retain) EditVisitViewController *editVisitView;
@property (nonatomic, retain) PatientViewController *patientViewController;
@property (nonatomic, retain) RxViewController *rxView;

@property (nonatomic, assign) BOOL isShowPatientButtonHidden;
@property (nonatomic, assign) BOOL isCallinButtonHidden;

-(IBAction) viewPatientAction: (id)sender;
-(IBAction) callDefaultPharmacyAction: (id)sender;
-(IBAction) emailVisitReportAction: (id)sender;
-(IBAction) editVisitAction: (id)sender;

-(id) initWithVisit: (Visit *)v;

-(void) reset;

@end
