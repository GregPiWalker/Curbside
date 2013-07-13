//
//  NewVisitViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "VisitViewController.h"
#import "Constants.h"
#import "Visit.h"
#import "Patient.h"
#import "Pharmacy.h"
#import "Prescription.h"
#import "EditVisitViewController.h"
#import "RxListDataSource.h"
#import "PatientViewController.h"
#import "RxViewController.h"


static const int prescriptionsLabelSpacer = 15;
static const int contentHeightSpacer = 45;


@interface VisitViewController ()

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

-(void) subscribeToVisitPropertyChanges: (BOOL)yesNo;

-(void) subscribeToDataSourceNotifications: (BOOL)yesNo;

-(void) resizeTimeLabelsView;

-(void) resizeTableViewByNumRows: (NSInteger)rows;

-(void) refreshScrollableHeight;

-(void) handleTableViewRowInserted: (NSNotification *)notification;

-(void) handleTableViewRowRemoved: (NSNotification *)notification;

-(void) handleVisitDeleted: (NSNotification *)notification;

-(void) resizeAll;

-(void) refreshView;

-(void) showDialerFailAlert: (NSString *)errMsg;

-(void) showEmailNotPermittedAlert;

-(void) viewWasPopped;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end


@implementation VisitViewController


#pragma mark - Properties

@synthesize rxTableView;
@synthesize rxDataSource;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize timeLabelsView;
@synthesize creationTimeLabel;
@synthesize creationLabel;
@synthesize callinLabel;
@synthesize callinTimeLabel;
@synthesize prescriptionsLabel;
@synthesize nameLabel;
@synthesize ccLabel;
@synthesize hpiLabel;
@synthesize planLabel;
@synthesize peLabel;
@synthesize impLabel;
@synthesize editButton;
@synthesize showPatientButton;
@synthesize callDefaultPharmacyButton;
@synthesize emailReportButton;
@synthesize editVisitView;
@synthesize patientViewController;
@synthesize parentView;
@synthesize rxView;

@dynamic isCallinButtonHidden;
-(BOOL) isCallinButtonHidden {
    return isCallinButtonHidden;
}
-(void) setIsCallinButtonHidden: (BOOL)value {
    if (isCallinButtonHidden != value) {
        NSMutableArray *buttonItems = [[toolbar.items mutableCopy] autorelease];
        if (value) {
            [buttonItems removeObject: callDefaultPharmacyButton];
        }
        else {
            [buttonItems addObject: callDefaultPharmacyButton];
        }
        toolbar.items = buttonItems;
    }
    isCallinButtonHidden = value;
}

@dynamic isShowPatientButtonHidden;
-(BOOL) isShowPatientButtonHidden {
    return isShowPatientButtonHidden;
}
-(void) setIsShowPatientButtonHidden: (BOOL)isHidden {
    isShowPatientButtonHidden = isHidden;
    [showPatientButton setHidden: isHidden];
}

@dynamic chiefComplaint;
-(NSString *) chiefComplaint {
    return ccTextField.text;
}
-(void) setChiefComplaint: (NSString*)s {
    ccTextField.text = s;
}
@dynamic physicalExam;
-(NSString *) physicalExam {
    return physExamTextArea.text;
}
-(void) setPhysicalExam: (NSString*)s {
    physExamTextArea.text = s;
}
@dynamic plan;
-(NSString *) plan {
    return planTextArea.text;
}
-(void) setPlan: (NSString*)s {
    planTextArea.text = s;
}
@dynamic patientName;
-(NSString *) patientName {
    return patientTextField.text;
}
-(void) setPatientName: (NSString*)s {
    patientTextField.text = s;
}
@dynamic historyPresentIllness;
-(NSString *) historyPresentIllness {
    return hpiTextArea.text;
}
-(void) setHistoryPresentIllness: (NSString*)s {
    hpiTextArea.text = s;
}
@dynamic impression;
-(NSString *) impression {
    return impressionTextArea.text;
}
-(void) setImpression: (NSString*)s {
    impressionTextArea.text = s;
}
@dynamic creationTime;
-(NSString *) creationTime {
    return creationTimeLabel.text;
}
-(void) setCreationTime: (NSString *)s {
    creationTimeLabel.text = s;
}
@dynamic callinTime;
-(NSString *) callinTime {
    return callinTimeLabel.text;
}
-(void) setCallinTime: (NSString *)s {
    callinTimeLabel.text = s;
}
@synthesize visit;
-(void) setVisit:(Visit *)v {
    if (visit == v) {
        return;
    }
    if (visit) {
        [self subscribeToVisitPropertyChanges:NO];
        //[self subscribeToPrescriptionNotifications:NO];
    }
    [visit release];
    visit = [v retain];
    needsViewRefresh = YES;
    
    if (visit != nil) {
        [self subscribeToVisitPropertyChanges:YES];
        //[self subscribeToPrescriptionNotifications:YES];
        rxDataSource.dataOwner = visit;
    }
    else {
        rxDataSource.dataOwner = nil;
    }
}

#pragma mark - Actions

-(IBAction) viewPatientAction: (id)sender {
    if (self.patientViewController == nil) {
        PatientViewController *pvc = [[PatientViewController alloc] initWithPatient: self.visit.patient];
        self.patientViewController = pvc;
        [pvc release];
        // This will allow the child views to pop to this view when necessary.
        self.patientViewController.parentView = self;
    }
    else {
        self.patientViewController.patient = self.visit.patient;
    }
    [self.navigationController pushViewController: patientViewController animated:YES];
}

-(IBAction) editVisitAction: (id)sender {
    if (self.editVisitView == nil) {
        EditVisitViewController *evvc = [[EditVisitViewController alloc] initForEditWithVisit: visit];
        self.editVisitView = evvc;
        [evvc release];
        // This will allow the child views to pop to this view when necessary.
        //TODO: check if this is used, remove if not.
        self.editVisitView.parentView = self;
    }
    else {
        self.editVisitView.visit = visit;
    }
    
    [self.navigationController pushViewController: self.editVisitView animated: YES];
}

-(IBAction) callDefaultPharmacyAction: (id)sender {
    Pharmacy *defPharm = visit.patient.defaultPharmacy;
    if (!defPharm || ![defPharm tryPlaceCallForVisit: visit]) {
        [self showDialerFailAlert: @"Unable to open the phone dialer for this device."];
    }
}

-(IBAction) emailVisitReportAction: (id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        @try {
            MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init]; 
            mailer.mailComposeDelegate = self;
            NSString *emailAddr = [ApplicationSupervisor instance].userEmailAddressSetting;
            if (emailAddr && [emailAddr length] > 0) {
                // Configure message using the user-defined destination email address.
                [mailer setToRecipients: [NSArray arrayWithObject: emailAddr]];
            }
            NSString *subject = [NSString stringWithFormat: @"%@%@ on %@", kVisitSubjectPrefix, visit.patient.fullName, [visit getCreationDateTimeAsString]];
            NSString *message = [visit toHtmlReportStringWithTitle: subject];
            NSString *fileName = [NSString stringWithFormat: @"%@_%@_%@.html", visit.patient.firstName, 
                                                                               visit.patient.lastName, 
                                                                               [[visit getCreationDateTimeAsString] stringByReplacingOccurrencesOfString: @":" withString: @"."]];
            fileName = [fileName stringByReplacingOccurrencesOfString: @" " withString: @"_"];
            // Also attach the message as an HTML file.
            [mailer addAttachmentData: [message dataUsingEncoding: NSUTF8StringEncoding] mimeType: kHtmlMimeType fileName: fileName];
            [mailer setSubject: subject];
            [mailer setMessageBody: message isHTML: YES];
            [self presentModalViewController: mailer animated: YES];
            [mailer release];
        }
        @catch (NSException *ex) {
            NSLog(@"Open Email Failed: %@", ex); 
        }
    }
    else {
        [self showEmailNotPermittedAlert];
    }
}

#pragma mark - Methods

/** initWithVisit
 * This is the designated initializer. 
 */
-(id) init {
    self = [super initWithNibName: @"VisitView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Visit";
        numAdditionalRows = 0;
        isShowPatientButtonHidden = NO;
        isEditButtonHidden = NO;
        isCallinButtonHidden = NO;
        rxDataSource = [[RxListDataSource alloc] init];
        rxDataSource.isEditEnabled = NO;
        [self subscribeToDataSourceNotifications: YES];
    }
    return self;
}

///Don't think this is used.
-(id) initWithVisit: (Visit *)v {
    self = [super initWithNibName: @"VisitView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Visit";
        numAdditionalRows = 0;
        isShowPatientButtonHidden = NO;
        isEditButtonHidden = NO;
        isCallinButtonHidden = NO;
        rxDataSource = [[RxListDataSource alloc] init];
        rxDataSource.isEditEnabled = NO;
        [self subscribeToDataSourceNotifications: YES];
        // make sure to do this last as it will trigger event subscriptions.
        self.visit = v;
    }
    return self;
}

-(void) reset {
    [self.rxDataSource reset];
    
    self.patientName = @"";
    self.historyPresentIllness = @"";
    self.plan = @"";
    self.physicalExam = @"";
    self.impression = @"";
    self.chiefComplaint = @"";
    
    //self.isToolbarHidden = NO;
    numAdditionalRows = 0;
    
    // Scroll to top
    [self.scrollView setContentOffset: CGPointMake(0.0, 0.0)];
    
    needsViewRefresh = YES;
}

/// refreshView
///
/// Do everything needed to make the UI components reflect the current state
/// of the supporting data.
-(void) refreshView {
    if (self.visit != nil) {
        // Copy values to the data bindings.
        self.patientName = self.visit.patient.fullName;
        self.physicalExam = self.visit.physicalExam;
        self.chiefComplaint = self.visit.chiefComplaint;
        self.historyPresentIllness = self.visit.historyPresentIllness;
        self.impression = self.visit.impression;
        self.plan = self.visit.plan;
        self.creationTime = [self.visit getCreationDateTimeAsString];
        if (self.visit.wasCalledIn) {
            self.callinTime = [self.visit getCallInDateTimeAsString];
        }
        if (self.visit.patient.defaultPharmacy) {
            [self setIsCallinButtonHidden: NO];
        }
        else {
            [self setIsCallinButtonHidden: YES];
        }
    }
    else {
        self.patientName = @"";
        self.historyPresentIllness = @"";
        self.plan = @"";
        self.physicalExam = @"";
        self.impression = @"";
        self.chiefComplaint = @"";
        self.creationTime = @"";
        self.callinTime = @"";
        
        [self setIsCallinButtonHidden: YES];
    }
    
    if (isEditButtonHidden) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    numAdditionalRows = rxDataSource.extraRowCount;
    
    if (numAdditionalRows == 0) {
        prescriptionsLabel.hidden = YES;
    }
    else {
        prescriptionsLabel.hidden = NO;
    }
    
    [self resizeAll];
    
    [self.rxDataSource reloadTableData];
    needsViewRefresh = NO;
}

-(void) resizeAll {
    // Resize the timeLabels view.
    [self resizeTimeLabelsView];
    
    [self resizeTableViewByNumRows: numAdditionalRows];
    
    // After the two views are sized, set the scrollable area.
    [self refreshScrollableHeight];
}

/// Resize the timeLabelsView to be bigger or smaller based on whether the
/// callin label is visible or not.
-(void) resizeTimeLabelsView {
    if (self.visit) {
        // If not called in, shrink the TimeLabelsView by Callin label height.
        if (!self.visit.wasCalledIn) {
            CGRect labelFrame = timeLabelsView.frame;
#ifdef DEBUG
            int h1 = labelFrame.size.height;
            int h2 = callinLabel.frame.size.height;
            NSLog(@"Shrinking VisitView's TimeLabelView from %i to %i", h1, h2);
#endif
            labelFrame.size.height -= callinLabel.frame.size.height;
            timeLabelsView.frame = labelFrame;
        }
        // If it was called in, make labels visible.
        else if (self.callinTimeLabel.hidden) {
            self.callinTimeLabel.text = [self.visit getCallInDateTimeAsString];
            // Need to show labels and expand view.
            callinTimeLabel.hidden = NO;
            callinLabel.hidden = NO;
        }
        // Position the scrollContent view appropriately.
        CGRect contentFrame = scrollContentView.frame;
#ifdef DEBUG
        int o = contentFrame.origin.y;
        int h = timeLabelsView.frame.size.height;
        NSLog(@"Repositioning VisitView's content origin from %i to %i", o, h);
#endif
        contentFrame.origin.y = timeLabelsView.frame.size.height;
        scrollContentView.frame = contentFrame;
    }
    else if (!self.callinTimeLabel.hidden) {
        // Need to hide labels and grow the timeLabelsView back to original size.
        callinTimeLabel.hidden = YES;
        callinLabel.hidden = YES;
        // Reduce the TimeLabelsView size by height of CalledIn labels.
        CGRect labelFrame = timeLabelsView.frame;
#ifdef DEBUG
        int h = labelFrame.size.height;
        NSLog(@"Resizing VisitView's TimeLabelView from %i to %i", h, initialTimeLabelsViewHeight);
#endif
        labelFrame.size.height = initialTimeLabelsViewHeight;
        timeLabelsView.frame = labelFrame;
        // Move scroll view up a bit.
        CGRect contentFrame = scrollContentView.frame;
        contentFrame.origin.y = timeLabelsView.frame.size.height;
        scrollContentView.frame = contentFrame;
    }
}

/// Resize the scroll content view size by the number of given TableView rows.
-(void) resizeTableViewByNumRows: (NSInteger)numRows {
    // NOTE: The tableView's height fudge factor is set in the .XIB
    CGRect tableFrame = rxTableView.frame;
    NSInteger difference = numRows * [rxTableView rowHeight];
    
//#ifdef DEBUG
//    int h = tableFrame.size.height;
//    NSLog(@"Resizing VisitView's TableView from %i to %i", h, h + difference);
//#endif
    // The tableView needs to grow or shrink along with the content view.
    tableFrame.size.height += difference;
    // Before applying the new tableView height, determine whether the content size needs to use the spacer value.
    CGRect contentFrame = scrollContentView.frame;
    // ContentView size needs to grow or shrink extra tableView size, possibly plus some extra fudge factor.
    if (numRows > 0 && rxTableView.bounds.size.height == initialTableViewHeight) {
        // Only add the content spacer when the tableView has left its initial size.
        difference += contentHeightSpacer;
        // Also make sure the label is visible.
        prescriptionsLabel.hidden = NO;
    }
    else if (numRows < 0 && tableFrame.size.height == initialTableViewHeight) {
        // Only remove the content spacer when the tableView is about to return to its initial size.
        difference -= contentHeightSpacer;
        // Also make sure the label is hidden.
        prescriptionsLabel.hidden = YES;
    }
    // Now apply the new table size.
    rxTableView.frame = tableFrame;
//#ifdef DEBUG
//    h = contentFrame.size.height;
//    NSLog(@"Resizing VisitView from %i to %i", h, h + difference);
//#endif
    contentFrame.size.height += difference;
    scrollContentView.frame = contentFrame;
}

-(void) refreshScrollableHeight {
    // Resize the scrollable view area using the two sub-views.
    CGSize scrollSize = scrollContentView.frame.size;
    scrollSize.height += timeLabelsView.frame.size.height;
    scrollView.contentSize = scrollSize;
}

-(void) showDialerFailAlert: (NSString *)errMsg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                        message:errMsg 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) showEmailNotPermittedAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Cannot send email on this device." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) applyTheme {    
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_B];
    
    // Set the color for the labels and TableView heading font, something to match the view background.
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: creationTimeLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: creationLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: callinTimeLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: callinLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: nameLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: ccLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: hpiLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: impLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: planLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: peLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: prescriptionsLabel];
    
    // (not used yet. Go to the .XIB)
    self.rxDataSource.headingTextColor = [[ApplicationSupervisor instance] themeManager].labelFontColor;
}


#pragma mark UIView Methods

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/** viewDidLoad
 */
-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self applyTheme];
    self.rxTableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    // Set the DataSource's table reference.  This also set's the table's dataSource.
    self.rxDataSource.tableView = self.rxTableView;
    
    // Set button visibility in sync with property value.
    [self.showPatientButton setHidden: isShowPatientButtonHidden];
    
    if (!isEditButtonHidden) {
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    initialTimeLabelsViewHeight = timeLabelsView.bounds.size.height;
    initialTableViewHeight = rxTableView.bounds.size.height;
    
    needsViewRefresh = YES;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (needsViewRefresh) {
        // This refreshes everything including view size.
        [self refreshView];
    }
}

/// viewDidDisappear
///
-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Resize to original size if this view was popped off the navigation controller.
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    
    if ([self.navigationController topViewController] != patientViewController
        && [self.navigationController topViewController] != rxView
        && [self.navigationController topViewController] != editVisitView
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

/// viewWasPopped
///
-(void) viewWasPopped {
    // Undo all view resizing that was done for additional rows and labels. Must be done before a reset.
    if (numAdditionalRows > 0) {
        [self resizeTableViewByNumRows: -numAdditionalRows];
    }
    
    // Set the timeLabels view back to initial size and state.
    CGRect labelFrame = timeLabelsView.frame;
    labelFrame.size.height = initialTimeLabelsViewHeight;
    timeLabelsView.frame = labelFrame;
    
    // Put these back to their initial state.
    // Must set visit to nil so that the resize for Time labels works correctly.
    self.visit = nil;
    [self resizeTimeLabelsView];
    
    [self reset];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark Memory Management

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //TODO:
    //[self subscribeToAppNotifications:NO];
    //self.rxView = nil;
}


- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [self subscribeToDataSourceNotifications: NO];
    self.visit = nil;
    self.rxDataSource = nil;
    self.editVisitView = nil;
    self.patientViewController = nil;
    self.rxView = nil;
    self.callDefaultPharmacyButton = nil;
    self.editButton = nil;
    self.emailReportButton = nil;
    self.creationLabel = nil;
    self.creationTimeLabel = nil;
    self.callinTimeLabel = nil;
    self.callinLabel = nil;
    self.showPatientButton = nil;
    self.nameLabel = nil;
    self.ccLabel = nil;
    self.hpiLabel = nil;
    self.impLabel = nil;
    self.planLabel = nil;
    self.peLabel = nil;
    
    [super dealloc];
}


#pragma mark ParentViewDelegate Methods

-(void) dismissChildView: (UIViewController *)child {
    [self.navigationController popViewControllerAnimated: YES];
}

//-(void) childViewWillDisappear: (UIViewController *)child {
//    // nothing
//}


#pragma mark MFMailComposeViewControllerDelegate Methods

-(void) mailComposeController: (MFMailComposeViewController*)mailer  
          didFinishWithResult: (MFMailComposeResult)result 
                        error: (NSError *)error {
    if (result == MFMailComposeResultFailed) {
        NSLog(@"Failed to send visit via email.");
    }
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark Event Handling

-(void) handleTableViewRowInserted: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == rxDataSource) {
            //RxListDataSource *source = (RxListDataSource *)[notification object];
            //if (source == rxDataSource) {
            numAdditionalRows += 1;
                
            [self resizeTableViewByNumRows: 1];
            // After the view is sized, set the scrollable area.
            [self refreshScrollableHeight];
                
            // Now reload the table to show data changes.
            [rxTableView reloadData];
            //}
        }
    }
}

-(void) handleTableViewRowRemoved: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == rxDataSource) {
            numAdditionalRows -= 1;
            
            [self resizeTableViewByNumRows: -1];
            // After the view is sized, set the scrollable area.
            [self refreshScrollableHeight];
            
            // Now reload the table to show data changes.
            [rxTableView reloadData];
        }
    }
}

/// Sets the "CallItIn" button visibility depending on a change in default pharmacy status.
-(void) handlePharmacyCreated: (NSNotification *)notification {
    // The notification object will be non-nil.
    if ([notification object] && self.visit.patient.defaultPharmacy == [notification object]) {
        [self setIsCallinButtonHidden: NO];
    }
}

-(void) handlePrescriptionSelected: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == self.rxDataSource
            && [args.notificationData isKindOfClass: [Prescription class]]) {
            Prescription *selectedRx = (Prescription *)args.notificationData;
            
            // Show the view for an existing Prescription.
            if (!rxView) {
                self.rxView = [[[RxViewController alloc] initWithPrescription:selectedRx] autorelease];
            }
            else {
                rxView.prescription = selectedRx;
            }
            
            if (self.navigationController) {
                [self.navigationController pushViewController: rxView animated:YES];
            }
            else {
                rxView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController: rxView animated: YES];
            }
        }
    }
}

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

-(void) handleVisitDeleted: (NSNotification *)notification {
    Visit *v = [notification object];
    if (v == visit) {
        // The displayed visit was deleted, so reset and pop to parent view.
        [self reset];
        if (self.parentView && self.navigationController) {
            // Not sure what will happen if this view has already been popped by the user.  Just wrap in Try/Catch incase.
            @try {
                // Need to dismiss this view (or any child).
                [self.navigationController popToViewController:self.parentView animated:YES];
            }
            @catch (NSException *ex) {
                // Nothing needed.
            }
        }
    }
}

///
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Visit *v = (Visit *)object;
    if (v != self.visit) {
        return;
    }
    
    if ([keyPath isEqualToString: wasCalledInKey]) {
        // If the displayed Visit's called-in status has changed, resize view.
        [self resizeTimeLabelsView];
        //[self resizeScrollContentHeight];
    }
    else if ([keyPath isEqualToString: chiefComplaintKey]) {
        self.chiefComplaint = visit.chiefComplaint;
    }
    else if ([keyPath isEqualToString: physicalExamKey]) {
        self.physicalExam = visit.physicalExam;
    }
    else if ([keyPath isEqualToString: impressionKey]) {
        self.impression = visit.impression;
    }
    else if ([keyPath isEqualToString: planKey]) {
        self.plan = visit.plan;
    }
    else if ([keyPath isEqualToString: historyPresentIllnessKey]) {
        self.historyPresentIllness = visit.historyPresentIllness;
    }
    else if ([keyPath isEqualToString: createdDateTimeKey]) {
        self.creationTime = [visit getCreationDateTimeAsString];
    }
}

-(void) subscribeToVisitPropertyChanges: (BOOL)yesNo {
    if (yesNo && !isObservingVisit) {
        isObservingVisit = YES;
        [self.visit addPropertyChangeObserver:self];
        //NSLog(@"Added VisitViewController as observer of new Visit.");
    }
    else if (!yesNo && isObservingVisit) {
        isObservingVisit = NO;
        [self.visit removePropertyChangeObserver:self];
        //NSLog(@"Removed VisitViewController as observer of old Visit.");
    }
}

///
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo {
    if (yesNo) {
        [self.rxDataSource addTableRowInsertedObserver:self withHandler:@selector(handleTableViewRowInserted:)];
        [self.rxDataSource addTableRowRemovedObserver:self withHandler:@selector(handleTableViewRowRemoved:)];
        [self.rxDataSource addPrescriptionSelectedObserver:self withHandler:@selector(handlePrescriptionSelected:)];
    }
    else {
        [self.rxDataSource removeTableRowInsertedObserver:self];
        [self.rxDataSource removeTableRowRemovedObserver:self];
        [self.rxDataSource removePrescriptionSelectedObserver:self];
    }
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addThemeSettingChangedObserver:self withHandler:@selector(handleThemeChanged:)];
        [[ApplicationSupervisor instance] addVisitDeletedObserver:self withHandler:@selector(handleVisitDeleted:)];
        [[ApplicationSupervisor instance] addPharmacyCreatedObserver:self withHandler:@selector(handlePharmacyCreated:)];
    }
    else {
        [[ApplicationSupervisor instance] removeThemeSettingChangedObserver:self];
        [[ApplicationSupervisor instance] removeVisitDeletedObserver:self];
        [[ApplicationSupervisor instance] removePharmacyCreatedObserver:self];
    }
}

@end
