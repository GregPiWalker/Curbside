//
//  NewVisitViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditVisitViewController.h"
#import "Constants.h"
#import "Visit.h"
#import "Prescription.h"
#import "PatientLookupDataSource.h"
#import "PatientViewController.h"
#import "EditPatientViewController.h"
#import "RxListDataSource.h"
#import "EditRxViewController.h"
#import "VisitViewController.h"

static const int contentHeightSpacer = 0;

@interface EditVisitViewController ()

-(void) applyTheme;

-(void) showInvalidVisitAlert: (NSString *)message;

-(void) showEmailNotPermittedAlert;

-(void) emailVisitReportFor: (Patient *)patient;

-(BOOL) validateVisit;

-(void) reset;

-(void) refreshView;

//-(void) resizeViewByHeight: (NSInteger)height;
//
//-(void) resizeRxTableViewByHeight: (NSInteger)height;

-(void) resizeTableViewByNumRows: (NSInteger)rows;

-(void) showCallinToolbar;

-(void) hideCallinToolbar;

-(void) slideDownDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context;
-(void) slideUpDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context;
-(void) dismissDatePicker;
-(void) showDatePicker;

-(void) handleTableRowAdded: (NSNotification *)notification;

-(void) handleTableRowRemoved: (NSNotification *)notification;

-(void) handleThemeChanged: (NSNotification *)n;

-(void) handlePatientDeleted: (NSNotification *)notification;

-(void) subscribeToLookupTablePropertyChanges: (BOOL)yesNo;

-(void) subscribeToPrescriptionNotifications: (BOOL)yesNo;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@property (nonatomic, retain) Visit *tempVisit;

@end


@implementation EditVisitViewController

#pragma mark - Properties

@synthesize dismissEditorButton;
@synthesize saveButton;
@synthesize datePickerView;
@synthesize lastSelectedRxIndex;
@synthesize lookupTableDataSource;
@synthesize rxDataSource;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize autocompleteTableView;
@synthesize prescriptionsTableView;
@synthesize prescriptionsLabel;
@synthesize nameLabel;
@synthesize ccLabel;
@synthesize hpiLabel;
@synthesize planLabel;
@synthesize peLabel;
@synthesize impLabel;
@synthesize patientViewController;
@synthesize editPatientViewController;
@synthesize parentView;
@synthesize patientTextField;
@synthesize isNewVisit;
@synthesize allowEditPatientField;
@synthesize editRxViewController;
@synthesize useNewPatient;

@dynamic isPatientButtonHidden;
-(BOOL) isPatientButtonHidden {
    return showPatientButton.hidden;
}
-(void) setIsPatientButtonHidden: (BOOL)value {
    [showPatientButton setHidden: value];
    if (value) {
        // TODO: resize patient text field.
    }
    else {
        // TODO: resize patient text field.
    }
}

@dynamic isToolbarHidden;
-(BOOL) isToolbarHidden {
    return toolbar.hidden;
}
-(void) setIsToolbarHidden:(BOOL)value {
//    if (isToolbarHidden != value) {
//        CGRect toolbarFrame = toolbar.frame;
//        CGRect scrollFrame = scrollView.frame;
//        if (value) {
//            scrollFrame.size.height += toolbarFrame.size.height;
//            toolbarFrame.origin.y += toolbarFrame.size.height;
//            // Do I need to reset the scrollContentFrame too?
//        }
//        else {
//            scrollFrame.size.height -= toolbarFrame.size.height;
//            toolbarFrame.origin.y -= toolbarFrame.size.height;
//            // Do I need to reset the scrollContentFrame too?
//        }
//        toolbar.frame = toolbarFrame;
//        scrollView.frame = scrollFrame;
//    }
//    isToolbarHidden = value;
    if (value) {
        [self hideCallinToolbar];
    }
    else {
        [self showCallinToolbar];
    }
}

@dynamic visit;
-(Visit *) visit {
    // if editing a New Visit, only mutableVisit is required.
    if (isNewVisit) {
        return tempVisit;
    }
    else {
        // Otherwise, both visit and mutableVisit are used.
        return visit;
    }
}
-(void) setVisit: (Visit *)v {
    // if editing a New Visit, only mutableVisit is required, so redirect operation.
    if (isNewVisit) {
        self.tempVisit = v;
        return;
    }
    // Otherwise, both visit and mutableVisit are used to edit an existing visit.
    if (visit == v) {
        return;
    }
    [visit autorelease];
    visit = [v retain];
    
    // If visit property is set and this is in edit mode, a fresh mutable visit is required. 
    if (visit) {
        Visit *copy = [v copy];
        // Visit copy method does not copy the patient.
        copy.patient = v.patient;
        self.tempVisit = copy;
        [copy release];
    }
}

/// The UI view is bound to tempVisit.
@synthesize tempVisit;
-(void) setTempVisit: (Visit *)v {
    if (tempVisit == v) {
        return;
    }
    [tempVisit autorelease];
    tempVisit = [v retain];
    needsViewRefresh = YES;
    
    if (tempVisit) {
        rxDataSource.dataOwner = tempVisit;
        // Determine whether to show or hide the Toolbar.
        if (tempVisit.patient && tempVisit.patient.defaultPharmacy) {
            self.isToolbarHidden = NO;
        }
        else {
            self.isToolbarHidden = YES;
        }
    }
    else {
        rxDataSource.dataOwner = nil;
        self.isToolbarHidden = YES;
    }
}

@dynamic creationDate;
-(NSString *) creationDate {
    return creationDateTextField.text;
}
-(void) setCreationDate: (NSString *)value {
    creationDateTextField.text = value;
}

@dynamic patientName;
-(NSString *) patientName {
    return patientTextField.text;
}
-(void) setPatientName: (NSString *)value {
    patientTextField.text = value;
}

@dynamic historyPresentIllness;
-(NSString *) historyPresentIllness {
    return hpiTextView.text;
}
-(void) setHistoryPresentIllness: (NSString *)value {
    hpiTextView.text = value;
    //self.visit.historyPresentIllness = value;
}

@dynamic chiefComplaint;
-(NSString *) chiefComplaint {
    return ccTextView.text;
}
-(void) setChiefComplaint: (NSString *)value {
    ccTextView.text = value;
    //self.visit.chiefComplaint = value;
}

@dynamic impression;
-(NSString *) impression {
    return impTextView.text;
}
-(void) setImpression: (NSString *)value {
    impTextView.text = value;
    //self.visit.impression = value;
}

@dynamic plan;
-(NSString *) plan {
    return planTextView.text;
}
-(void) setPlan: (NSString *)value {
    planTextView.text = value;
    //self.visit.plan = value;
}

@dynamic physicalExam;
-(NSString *) physicalExam {
    return peTextView.text;
}
-(void) setPhysicalExam: (NSString *)value {
    peTextView.text = value;
    //self.visit.physicalExam = value;
}

#pragma mark - Actions

-(IBAction) dismissKeyboardAction: (id)sender {
    [self dismissKeyboard];
}
    
-(IBAction) viewPatientAction: (id)sender {
    [self dismissKeyboard];
    [self dismissDatePicker];
    
    Patient *selectedPatient = nil;
    if (!isNewVisit) {
        selectedPatient = self.tempVisit.patient;
    }
    else if (!useNewPatient && self.lookupTableDataSource.selectedPatient){
        selectedPatient = self.lookupTableDataSource.selectedPatient;
    }
    
    // For existing patients only.
    if (selectedPatient) {
        UIViewController *patientController;
        if (self.patientViewController == nil) {
            PatientViewController *pvc = [[PatientViewController alloc] initWithPatient: selectedPatient];
            self.patientViewController = pvc;
            patientController = pvc;
            [pvc release];
            // This allows the child views to pop to this view if necessary.
            self.patientViewController.parentView = self;
        }
        else {
            patientController = self.patientViewController;
            self.patientViewController.patient = selectedPatient;
        }
        [self.navigationController pushViewController: patientController animated:YES];
    }
}

-(IBAction) saveVisitAction: (id)sender {
    [self dismissKeyboard];
    [self dismissDatePicker];
    
    if ([self validateVisit]) {
        Patient *patient = self.lookupTableDataSource.selectedPatient;
        // This will also issue a notification that the collection changed.
        [patient addVisit: tempVisit];
        
        // Apply outstanding changes of the dataSource to the temporary visit.
        [self.rxDataSource applyChanges];
        // Propagate the additions to the the AppSuper.
        [[ApplicationSupervisor instance] createPrescriptions: tempVisit.prescriptions];
        // The tempVisit & AppSuper now have the current prescription collection.
        
        // Create or update the Patient.
        if (self.useNewPatient) {
            [[ApplicationSupervisor instance] createPatient:patient];
        }
        else {
            [[ApplicationSupervisor instance] updatePatient:patient];
        }
        
        // Only after changes are applied can the Visit be created.
        [[ApplicationSupervisor instance] createVisit: self.tempVisit];

        
        // If the configuration supports it, auto-generate a report now.
        if ([ApplicationSupervisor instance].autoGenerateVisitReport) {
            persistViewUntilMailerFinshes = YES;
            // send email.
            [self emailVisitReportFor: patient];
        }
        
        // Finally, clear all of the existing data out.
        self.tempVisit = nil;
        self.visit = nil;
        needsViewRefresh = YES;
        
        // Only self-dismiss here if the mailer is not still open or working. Otherwise, pop after mailer delegate called.
        if (!persistViewUntilMailerFinshes) {
            // Pop view directly to NavigationController since this view will always show under its control.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self showInvalidVisitAlert: @"A new visit requires a patient and a chief complaint."];
    }
}

-(IBAction) updateVisitAction: (id)sender {
    [self dismissKeyboard];
    [self dismissDatePicker];
    
    if ([self validateVisit]) {        
        // Apply outstanding changes of the dataSource to the temporary visit.
        ModificationTracker *mods = [self.rxDataSource applyChanges];
        // Propagate the deletions to the real visit and the AppSuper.
        [[ApplicationSupervisor instance] deletePrescriptions: [mods deletionsForClass: [Prescription class]]];
        // Propagate the additions to the real visit and the AppSuper.
        [[ApplicationSupervisor instance] createPrescriptions: [mods additionsForClass: [Prescription class]]];

        // The real Visit and AppSuper both now have a current set of prescriptions.  Time to copy flat values over.
        [self.tempVisit copyOnto: self.visit];
        
        // Only after changes are applied can the Visit be updated.
        [[ApplicationSupervisor instance] updateVisit: self.visit];
        
        // If the configuration supports it, auto-generate a report now.
        //NOTE: for now, this always fails.
        if (isNewVisit && [ApplicationSupervisor instance].autoGenerateVisitReport) {
            persistViewUntilMailerFinshes = YES;
            // send email.
            [self emailVisitReportFor: visit.patient];
        }
        
        // Finally, clear all of the existing data out.
        self.tempVisit = nil;
        self.visit = nil;
        needsViewRefresh = YES;
        
        // Only self-dismiss here if the mailer is not still open or working. Otherwise, pop after mailer delegate called.
        if (!persistViewUntilMailerFinshes) {
            // Pop view directly to NavigationController since this view will always show under its control.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self showInvalidVisitAlert: @"A visit must have a chief complaint."];
    }
}

-(IBAction) setChiefComplaintAction: (id)sender {
    self.tempVisit.chiefComplaint = ((UITextField*)sender).text;
}

-(IBAction) setCreationDateAction: (id)sender {
    self.tempVisit.createdDateTime = datePickerView.date;
    self.creationDate = [tempVisit getCreationDateTimeAsString];
}

-(IBAction) dismissDatePickerAction: (id)sender {
    [self dismissDatePicker];
}


#pragma mark - Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

/// Just redirect to initWithNewVisit.
-(id) init {
    return [self initWithNewVisit: [[[Visit alloc] init] autorelease]];
}

-(id) initWithNewVisit: (Visit *)v {
    self = [super initWithNibName: @"EditVisitView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"New Visit";
        numAdditionalRows = 0;
        wasViewPopped = NO;
        // Show up to 3 patient names in the autocomplete table.
        maxLookupTableRows = 3;
        isNewVisit = YES;
        allowEditPatientField = YES;
        persistViewUntilMailerFinshes = NO;
        rxDataSource = [[RxListDataSource alloc] init];
        rxDataSource.isEditEnabled = YES;
        rxDataSource.canSelectPrescriptions = NO;
        visit = nil;
        // make sure to do this last as it will trigger event subscriptions.
        self.tempVisit = v;
    }
    return self;
}

-(id) initForEditWithVisit: (Visit *)v {
    self = [super initWithNibName: @"EditVisitView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Edit Visit";
        numAdditionalRows = 0;
        maxLookupTableRows = 0;
        wasViewPopped = NO;
        isNewVisit = NO;
        allowEditPatientField = NO;
        persistViewUntilMailerFinshes = NO;
        rxDataSource = [[RxListDataSource alloc] init];
        rxDataSource.isEditEnabled = YES;
        rxDataSource.canSelectPrescriptions = NO;
        // make sure to do this last as it will trigger event subscriptions.
        self.visit = v;
    }
    return self;
}

-(BOOL) validateVisit {
    // If it's an existing visit, the patient is set.
    if ((self.lookupTableDataSource.selectedPatient || !isNewVisit)
        && [self.tempVisit.chiefComplaint length] > 0) {
        return YES;
    }
    return NO;
}

-(void) showInvalidVisitAlert: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Missing Information" 
                                                        message: message 
                                                       delegate: nil 
                                              cancelButtonTitle: @"Ok" 
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void) showEmailNotPermittedAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Error" 
                                                        message: @"Cannot send email on this device." 
                                                       delegate: nil 
                                              cancelButtonTitle: @"Ok" 
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void) emailVisitReportFor: (Patient *)patient {
    if ([MFMailComposeViewController canSendMail]) {
        @try {
            autoGenMailer = [[MFMailComposeViewController alloc] init]; 
            autoGenMailer.mailComposeDelegate = self;
            NSString *emailAddr = [ApplicationSupervisor instance].userEmailAddressSetting;
            if (emailAddr && [emailAddr length] > 0) {
                // Configure message using the user-defined destination email address.
                [autoGenMailer setToRecipients: [NSArray arrayWithObject: emailAddr]];
            }
            NSString *subject = [NSString stringWithFormat: @"%@%@ on %@", kVisitSubjectPrefix, patient.fullName, [tempVisit getCreationDateTimeAsString]];
            NSString *message = [tempVisit toHtmlReportStringWithTitle: subject];
            NSString *fileName = [NSString stringWithFormat: @"%@_%@_%@.html", tempVisit.patient.firstName, 
                                  tempVisit.patient.lastName, 
                                  [[tempVisit getCreationDateTimeAsString] stringByReplacingOccurrencesOfString: @":" withString: @"."]];
            fileName = [fileName stringByReplacingOccurrencesOfString: @" " withString: @"_"];
            // Also attach the message as an HTML file
            [autoGenMailer addAttachmentData: [message dataUsingEncoding: NSUTF8StringEncoding] mimeType: kHtmlMimeType fileName: fileName];
            [autoGenMailer setSubject: subject];
            [autoGenMailer setMessageBody: message isHTML: YES];
            [self presentModalViewController: autoGenMailer animated: YES];
            [autoGenMailer release];
        }
        @catch (NSException *ex) {
            NSLog(@"Open Email Failed: %@", ex); 
        }
    }
    else {
        [self showEmailNotPermittedAlert];
    }
}

/// Reset the Save button to "save" or "update" function based on edit mode, and make it visible.
-(void) showSaveButton {
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    
    if (isNewVisit) {
        self.saveButton.action = @selector(saveVisitAction:);
    }
    else {
        self.saveButton.action = @selector(updateVisitAction:);
    }
}

/// Make the DismissEditor button visible.
-(void) showDismissEditorButton {
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = dismissEditorButton;
    }
}

-(void) refreshView {
    if (self.tempVisit != nil) {
        if (self.tempVisit.patient != nil) {
            self.patientName = [NSString stringWithFormat:@"%@ %@", self.tempVisit.patient.firstName, self.tempVisit.patient.lastName];
        }
        else {
            self.patientName = @"";
        }
        self.historyPresentIllness = self.tempVisit.historyPresentIllness;
        self.plan = self.tempVisit.plan;
        self.physicalExam = self.tempVisit.physicalExam;
        self.impression = self.tempVisit.impression;
        self.chiefComplaint = self.tempVisit.chiefComplaint;
        self.creationDate = [self.tempVisit getCreationDateTimeAsString];
        datePickerView.date = self.tempVisit.createdDateTime;
        datePickerView.maximumDate = [NSDate date];
    }
    else {
        self.patientName = @"";
        self.historyPresentIllness = @"";
        self.plan = @"";
        self.physicalExam = @"";
        self.impression = @"";
        self.chiefComplaint = @"";
        self.creationDate = @"";
        
        datePickerView.maximumDate = [NSDate date];
        datePickerView.date = datePickerView.maximumDate;
    }
    //persistViewUntilMailerFinshes = NO;
    
    if (isNewVisit) {
        self.patientTextField.enabled = YES;
        self.patientTextField.textColor = [UIColor blackColor];
        self.useNewPatient = YES;
        [self hideCallinToolbar];
        self.isPatientButtonHidden = YES;
    }
    else {
        patientTextField.enabled = NO;
        self.patientTextField.textColor = [UIColor darkGrayColor];
        self.useNewPatient = NO;
        [self hideCallinToolbar];
        self.isPatientButtonHidden = NO;
    }
    
    [self showSaveButton];
    numAdditionalRows = self.rxDataSource.extraRowCount;
    [self resizeTableViewByNumRows: numAdditionalRows];
    [self.rxDataSource reloadTableData];
    
    needsViewRefresh = NO;
}

-(void) reset {
    [self dismissKeyboard];
    self.autocompleteTableView.hidden = YES;
    [self.lookupTableDataSource reset];
    [self.rxDataSource reset];
    numAdditionalRows = 0;
    self.tempVisit = nil;
    self.visit = nil;
    
    // Scroll to top
    [self.scrollView setContentOffset: CGPointMake(0.0, 0.0)];
    
    // Denote that the view needs a refresh so that the size is expanded if necessary on a re-push.
    needsViewRefresh = YES;
}

/// Resize the scroll content view size by the number of given TableView rows.
-(void) resizeTableViewByNumRows: (NSInteger)numRows {
    if (numRows == 0) {
        return;
    }
    
    // NOTE: The tableView's height fudge factor is set in the .XIB
    CGRect tableFrame = prescriptionsTableView.frame;
    NSInteger difference = numRows * [prescriptionsTableView rowHeight];
    
#ifdef DEBUG
    int h = tableFrame.size.height;
    NSLog(@"Resizing EditVisitView's TableView from %i to %i", h, h + difference);
#endif
    // The tableView needs to grow or shrink along with the content view.
    tableFrame.size.height += difference;
    // Now apply the new table size.
    prescriptionsTableView.frame = tableFrame;
    
    // ContentView size needs to grow or shrink extra tableView size.
    CGRect contentFrame = scrollContentView.frame;
#ifdef DEBUG
    h = contentFrame.size.height;
    NSLog(@"Resizing EditVisitView from %i to %i", h, h + difference);
#endif
    contentFrame.size.height += difference;
    scrollContentView.frame = contentFrame;
    
    // Apply the resized scrollable content size.
    self.scrollView.contentSize = contentFrame.size;
}

-(void) showCallinToolbar {
    if (isToolbarHidden) {
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.size.height -= callinToolBar.frame.size.height;
        // Apply the resized ScrollView height.
        self.scrollView.frame = scrollFrame;
        // move the toolbar.
        [callinToolBar setHidden:NO];
        isToolbarHidden = NO;
    }
}

-(void) hideCallinToolbar {
    if (!isToolbarHidden) {
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.size.height += callinToolBar.frame.size.height;
        // Apply the resized ScrollView height.
        self.scrollView.frame = scrollFrame;
        // move the toolbar.
        [callinToolBar setHidden:YES];
        isToolbarHidden = YES;
    }
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_A];
    
    // Set the color for the labels and TableView heading font, something to match the view background.
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

/// When the Date picker stops sliding out of view, remove the Date picker from the view.
-(void) slideDownDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
	// the date picker has finished sliding downwards, so remove it
	[datePickerView removeFromSuperview];
}

/// When the Date picker stops sliding into view, scrooll view as needed.
-(void) slideUpDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
    [self.scrollView scrollRectToVisible: creationDateTextField.bounds animated: YES];
}

-(void) dismissDatePicker {
    if (datePickerView.superview != nil) {
        CGSize pickerSize = [datePickerView sizeThatFits:CGSizeZero];
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = datePickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.size.height += pickerSize.height;
        
        // start the slide down animation
        [UIView beginAnimations:@"ResizeForDatePicker" context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop:finished:context:)];
        datePickerView.frame = endFrame;
        self.scrollView.frame = scrollFrame;
        [UIView commitAnimations];
        
        // Swap the DismissEditor button back to the Save button.
        [self showSaveButton];
    }
}

-(void) showDatePicker {
    // check if our date picker is already on screen
    if (datePickerView.superview == nil) {
        // Make sure the keyboard is not visible
        [self dismissKeyboard];
        
        [self.view.window addSubview: datePickerView];
        
        // Swap the Save button to the DismissEditor button and set its action for the DatePicker.
        [self showDismissEditorButton];
        self.dismissEditorButton.action = @selector(dismissDatePicker);
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [datePickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        datePickerView.frame = startRect;
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.size.height -= pickerSize.height;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width, pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:@"ResizeForDatePicker" context:NULL];
        [UIView setAnimationDuration:0.3];
        // we need to perform some post operations after the animation is complete.
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideUpDidStop:finished:context:)];
        datePickerView.frame = pickerRect;
        self.scrollView.frame = scrollFrame;
        [UIView commitAnimations];
    }
}


#pragma mark ViewControllerBase Methods

/// dismissKeyboard
///
-(void) dismissKeyboard {
    [controlBeingEdited resignFirstResponder];
    controlBeingEdited = nil;
}

/// animateKeyboardWillShow
///
-(void) animateKeyboardWillShow: (NSNotification *)notification {
    // Display the DismissEditor button and change its action to "dismiss keyboard" function.
    [self showDismissEditorButton];
    self.dismissEditorButton.action = @selector(dismissKeyboard);
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.size.height -= keyboardheight;
//    if (!isToolbarHidden) {
//        scrollFrame.size.height += callinToolBar.frame.size.height;
//    }
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

-(void) animateKeyboardWillHide: (NSNotification *)notification {
    // Display the Save button.
    [self showSaveButton];
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.size.height += keyboardheight;
//    if (!isToolbarHidden) {
//        scrollFrame.size.height -= callinToolBar.frame.size.height;
//    }
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

/// viewWasPopped
///
-(void) viewWasPopped {
    if (numAdditionalRows > 0) {
        // Resize the view to original state.
        [self resizeTableViewByNumRows: -numAdditionalRows];
    }
    [self reset];
}


#pragma mark UIViewController Methods

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/** viewDidLoad
 */
-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Set the DataSource's table reference.  This also set's the table's dataSource.
    self.rxDataSource.tableView = self.prescriptionsTableView;
    initialTableViewHeight = prescriptionsTableView.bounds.size.height;
    
    [self applyTheme];
    self.prescriptionsTableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    // Show 3 1/2 rows to indicate that scrolling is available.
    self.lookupTableDataSource.numberOfVisibleRows = 3.5;
    [self subscribeToLookupTablePropertyChanges:YES];
    
    // This will show the red delete buttons next to removable cells.
    [self.prescriptionsTableView setEditing:YES animated:NO];
    self.prescriptionsTableView.allowsSelectionDuringEditing = YES;
    [self subscribeToPrescriptionNotifications:YES];
    
    // Size the ScrollView's scrollable area.
    scrollView.contentSize = scrollContentView.frame.size;
    
    // Set the 'Save' button to do the create or update action.
    [self showSaveButton];
}

/// viewWillAppear
///
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // It's possible that the Visit has not been instantiated yet.
    // Using the visit property since it redirects as needed based on isNewVisit state.
    if (!self.visit) {
        Visit *v = [[Visit alloc] init];
        self.visit = v;
        [v release];
    }
    
    // Make sure the data member matches the Toolbar's state.
    isToolbarHidden = callinToolBar.hidden;
   
    //numAdditionalRows = self.rxDataSource.extraRowCount;
    
    if (needsViewRefresh) {
        [self refreshView];
    }
    else if (self.lookupTableDataSource.selectedPatient) {
        // Update the patient name, in case it was edited in a different view.
        self.patientTextField.text = self.lookupTableDataSource.selectedPatient.fullName;
    }
    
    [self.rxDataSource reloadTableData];
    
    // If EditRxViewController is cancelled, remove empty table row.
    [self.rxDataSource purgeUnfinishedRow];
}

-(void) viewWillDisappear: (BOOL)animated {
    // Superview calls dismissKeyboard.
    [super viewWillDisappear: animated];
    
    // Get rid of any visible datePicker.
    [self dismissDatePicker];
    
    if ([self.navigationController topViewController] != patientViewController
        && [self.navigationController topViewController] != editPatientViewController
        && [self.navigationController topViewController] != editRxViewController
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

/// viewDidDisappear
///
-(void) viewDidDisappear:(BOOL)animated {    
    [super viewDidDisappear:animated];
    
    // Resize to original size if this view was popped off the navigation controller.
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}


#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //TODO:
//    self.editRxViewController = nil;
//    self.editPatientViewController = nil;
//    self.patientViewController = nil;
}


- (void)dealloc {
    [self subscribeToLookupTablePropertyChanges:NO];
    [self subscribeToPrescriptionNotifications:NO];
    [self subscribeToAppNotifications:NO];
    self.tempVisit = nil;
    self.visit = nil;
    self.patientViewController = nil;
    self.editPatientViewController = nil;
    self.rxDataSource = nil;
    self.editRxViewController = nil;
    self.nameLabel = nil;
    self.ccLabel = nil;
    self.hpiLabel = nil;
    self.impLabel = nil;
    self.planLabel = nil;
    self.peLabel = nil;
    self.datePickerView = nil;
    self.autocompleteTableView = nil;
    self.lookupTableDataSource = nil;
    self.dismissEditorButton = nil;
    self.saveButton = nil;
    [super dealloc];
}


#pragma mark MFMailComposeViewControllerDelegate Methods

-(void) mailComposeController: (MFMailComposeViewController*)mailer  
          didFinishWithResult: (MFMailComposeResult)result 
                        error: (NSError *)error {
    if (result == MFMailComposeResultFailed) {
        NSLog(@"Failed to send visit via email.");
    }
    
    [self dismissModalViewControllerAnimated: NO];
    
    if (persistViewUntilMailerFinshes) {
        persistViewUntilMailerFinshes = NO;
        // The view was not dismissed on save, so do it here now that the mailer is done.
        [self.navigationController popViewControllerAnimated: YES];
    }
}


#pragma mark UITableViewDelegate Methods

/// editingStyleForRowAtIndexPath
///
-(UITableViewCellEditingStyle) tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.rxDataSource tableView:tv editingStyleForRowAtIndexPath:indexPath];
}

-(void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rxDataSource tableView:tv didSelectRowAtIndexPath:indexPath];
}


#pragma mark UITextViewDelegate Methods

-(void) textViewDidBeginEditing: (UITextView *)textView {
    // The date picker might be visible.
    [self dismissDatePicker];
    
    controlBeingEdited = textView;
    // Try to scroll the control into view.
    CGRect frame = textView.frame;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    //[self showDismissEditorButton];
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    controlBeingEdited = nil;
    
    //[self showSaveButton];
    
    // Apply the text changes.
    switch (textView.tag) {            
        case HistoryPresentIllnessControlTag:
            self.tempVisit.historyPresentIllness = textView.text;
            [tempVisit description];
            break;
            
        case PhysicalExamControlTag:
            self.tempVisit.physicalExam = textView.text;
            break;
            
        case ImpressionControlTag:
            self.tempVisit.impression = textView.text;
            break;
            
        case PlanControlTag:
            self.tempVisit.plan = textView.text;
            break;
            
        default:
            break;
    }
}


#pragma mark UITextFieldDelegate Methods

/// textFieldShouldReturn
///
-(BOOL) textFieldShouldReturn: (UITextField *)tf {
    if (tf == patientTextField) {
        // User pressed 'Next" button, so select next field.
        [ccTextView becomeFirstResponder];
        return NO;
    }
    else if (tf == ccTextView) {
        // User pressed 'Next" button, so select next text area.
        [hpiTextView becomeFirstResponder];
        return NO;
    }
    else {
        // the user pressed the "Done" button, so dismiss the keyboard and stop editing.
        [tf resignFirstResponder];
        return YES;
    }
}

/// textFieldShouldBeginEditing
///
/// Mediate between stimulation of the keyboard or the date picker depending on which field is given.
-(BOOL) textFieldShouldBeginEditing: (UITextField *)tf {
    if (tf == creationDateTextField) {
        [self showDatePicker];
        return NO;
    }
    else {
        // It's possible the Date picker is visible, so dismiss in that case.
        [self dismissDatePicker];
        return YES;
    }
}

/// textFieldDidBeginEditing
///
/// Scrolls the given textField into view.
-(void) textFieldDidBeginEditing: (UITextField *)tf {
    controlBeingEdited = tf;
    
    // Try to scroll the control into view.
    CGRect frame = tf.frame;
    //NSLog(@"frame y origin is: %f", frame.origin.y);
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    if (!isNewVisit && tf == self.patientTextField) {
        //TODO: popup confirmation dialog.
    }
}

/// textFieldDidEndEditing
///
/// Handles when a TextField is done being edited.  The new text value is entered into the data source
/// at the appropriate location.
-(void) textFieldDidEndEditing: (UITextField *)tf {
    self.autocompleteTableView.hidden = YES;
    
    // If the Patient text field is done editing, forward the message on to the PatientLookupTableDataSource.
    if (tf == self.patientTextField) {
        // Create a new patient if none was selected.
        if (![tf.text isEqualToString:@""] && self.lookupTableDataSource.selectedPatient == nil) {
            self.autocompleteTableView.hidden = YES;
            Patient *newPatient = [[Patient alloc] init];
            self.lookupTableDataSource.selectedPatient = newPatient;
            [newPatient release];
            
            NSRange range = [tf.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            if (range.length == 1) {
                newPatient.firstName = [tf.text substringToIndex: range.location];
                if (range.location + 1 < [tf.text length]) {
                    newPatient.lastName = [tf.text substringFromIndex: range.location + 1];
                }
            }
            else {
                newPatient.firstName = tf.text;
            }
            self.useNewPatient = YES;
            self.isPatientButtonHidden = YES;
        }
    }
    controlBeingEdited = nil;
}

-(BOOL) textFieldShouldClear: (UITextField *)tf {
    if (tf == self.patientTextField) {
        self.autocompleteTableView.hidden = YES;
        [self.lookupTableDataSource reset];
    }
    return YES;
}

///
-(BOOL) textField: (UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)str {
    // If the Patient text field is changing, forward the message on to the PatientLookupTableDataSource.
    if (tf == self.patientTextField) {
        if (!self.allowEditPatientField) {
            return NO;
        }
        // Assume it's a new patient until a table row is selected.
        self.useNewPatient = YES;
        self.isPatientButtonHidden = YES;
        // Forward the UI message on to the Data Source.
        [self.lookupTableDataSource textField:tf shouldChangeCharactersInRange:range replacementString:str];
        
        // Change table visibility based on its contents
        if (self.lookupTableDataSource.numberOfRows > 0) {
            self.autocompleteTableView.hidden = NO;
            // Reload the table since the data should have changed.
            [self.autocompleteTableView reloadData];
            
            // Resize the autocomplete table.
            NSInteger numRows = self.lookupTableDataSource.numberOfRows;
            CGRect tableFrame = self.autocompleteTableView.frame;
            if (numRows > maxLookupTableRows) {
                tableFrame.size.height = self.autocompleteTableView.rowHeight * maxLookupTableRows;
            }
            else {
                tableFrame.size.height = self.autocompleteTableView.rowHeight * numRows;
            }
            self.autocompleteTableView.frame = tableFrame;
            self.autocompleteTableView.contentSize = CGSizeMake(tableFrame.size.width, self.autocompleteTableView.rowHeight * numRows);
        }
        else {
            self.autocompleteTableView.hidden = YES;
        }
    }
    return YES;
}


#pragma mark Event Handling

/// observeValueForKeyPath
/// Handle changes to Property values.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //NSNumber * kind = (NSNumber *)[change valueForKey:NSKeyValueChangeKindKey];
    //NSIndexSet *indexes = [change valueForKey:NSKeyValueChangeIndexesKey];
    
    if ([keyPath isEqualToString: useExistingItemKey]) {
        self.useNewPatient = !self.lookupTableDataSource.useExistingItem;
        self.isPatientButtonHidden = useNewPatient;
    }
    else if ([keyPath isEqualToString: selectedItemKey]) {
        // Ignore changes when the selected patient is set to nil.
        if (self.lookupTableDataSource.selectedPatient) {
            self.autocompleteTableView.hidden = YES;
        }
    }
}

///
-(void) handleTableRowAdded: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == rxDataSource
            && [args.notificationData isKindOfClass: [Prescription class]]) {
            [self dismissKeyboard];
        
            // make the table grow.
            Prescription *newRx = (Prescription *)args.notificationData;
            // set the parent reference.
            newRx.visit = self.tempVisit;
            
            // Show the view for a new prescription.
            if (self.editRxViewController == nil) {
                EditRxViewController *erxVC = [[EditRxViewController alloc] init];
                self.editRxViewController = erxVC;
                [erxVC release];
            }
            self.editRxViewController.prescription = newRx;
            [self.navigationController pushViewController: editRxViewController animated:YES];
            
            // Resize view for the new row.
            numAdditionalRows += 1;
            [self resizeTableViewByNumRows: 1];
        }
    }
}

///
-(void) handleTableRowRemoved: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == rxDataSource) {
            numAdditionalRows -= 1;
            [self resizeTableViewByNumRows: -1];
        }
    }
}

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

-(void) handlePatientDeleted: (NSNotification *)notification {
    Patient *p = [notification object];
    if (p == tempVisit.patient) {
        // The selected patient was deleted, so clear patient fields and values.
        [self reset];
        // Should not have to worry about popping the view since EditVisit->ViewPatient->EditPatient is not allowed.
    }
}

///
-(void) subscribeToLookupTablePropertyChanges: (BOOL)yesNo {
    if (yesNo) {
        [self.lookupTableDataSource addPropertyChangeObserver:self];
    }
    else {
        [self.lookupTableDataSource removePropertyChangeObserver:self];
    }
}

///
-(void) subscribeToPrescriptionNotifications: (BOOL)yesNo {
    if (yesNo) {
        [self.rxDataSource addTableRowInsertedObserver:self withHandler:@selector(handleTableRowAdded:)];
        [self.rxDataSource addTableRowRemovedObserver:self withHandler:@selector(handleTableRowRemoved:)];
    }
    else {
        [self.rxDataSource removeTableRowInsertedObserver:self];
        [self.rxDataSource removeTableRowRemovedObserver:self];
    }
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addThemeSettingChangedObserver:self withHandler:@selector(handleThemeChanged:)];
        [[ApplicationSupervisor instance] addPatientDeletedObserver:self withHandler:@selector(handlePatientDeleted:)];
    }
    else {
        [[ApplicationSupervisor instance] removeThemeSettingChangedObserver:self];
        [[ApplicationSupervisor instance] removePatientDeletedObserver:self];
    }
}

@end
