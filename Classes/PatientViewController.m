//
//  PatientViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "PatientViewController.h"
#import "Constants.h"
#import "Patient.h"
#import "Visit.h"
#import "Pharmacy.h"
#import "PatientDataSource.h"
#import "EditPatientViewController.h"
#import "EditVisitViewController.h"
#import "VisitViewController.h"
#import "PharmacyViewController.h"


//static const NSInteger staticHeaderHeight = 26;
static const float tableHeaderHeight = 44.0;

/**
 Empty category to define private methods.
 */
@interface PatientViewController ()

-(void) subscribeToNotifications: (BOOL)yesNo;

-(void) resizeContentByHeight: (NSInteger)height;

-(void) reset;

-(void) refreshView;

-(void) hideToolbar;

-(void) showToolbar;

-(void) showDialerFailAlert: (NSString *)errMsg;

-(void) showEmailNotPermittedAlert;

-(void) handleTableViewRowInserted: (NSNotification *)notification;

-(void) handleTableViewRowRemoved: (NSNotification *)notification;

-(void) handleSetDefaultPharmacyMenuButtonPressed: (UIMenuController*)menuController;

-(void) handleCallPharmacyMenuButtonPressed: (UIMenuController*)menuController;

-(void) handlePharmacyCreated: (NSNotification *)notification;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end


@implementation PatientViewController

#pragma mark - Properties

@synthesize dataSource;
@synthesize exportVisitsButton;
@synthesize editButton;
@synthesize tableView;
@synthesize scrollView;
@synthesize parentView;
@synthesize headingTextColor;
@synthesize editPatientViewController;

@dynamic showEditButton;
-(BOOL) showEditButton {
    if ([parentView isKindOfClass: [EditVisitViewController class]]) {
        return NO;
    }
    return YES;
}

@synthesize canSelectVisits;
-(void) setCanSelectVisits: (BOOL)value {
    if (value != canSelectVisits) {
        canSelectVisits = value;
        if (dataSource) {
            dataSource.canSelectVisits = value;
        }
    }
}

@synthesize patient;
/** setPatient
 Custom implementation so that changing the Patient also propagates into the DataSource.
 */
-(void) setPatient:(Patient *)p {
    if (p == patient) {
        return;
    }
    [patient autorelease];
    patient = [p retain];
    needsViewRefresh = YES;
    
    if (dataSource != nil) {
        dataSource.patient = p;
    }
}


#pragma mark - Methods

// The designated initializer redirects to a custom init for a new Patient.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    return [self init];
//}

-(id) initWithPatient: (Patient *) existingPatient {
    self = [super initWithNibName: @"PatientView" bundle: nil];
    if (self) {
        self.title = @"Patient";
        // Just set a default color.  It can be overridden later.
        self.headingTextColor = [UIColor blackColor];
        needsViewRefresh = YES;
        wasViewPopped = NO;
        isToolbarHidden = YES;
        canSelectVisits = YES;
        numAdditionalRows = 0;
        numAdditionalSections = 0;
        patient = [existingPatient retain];
        // Initialize the data source as empty first so edit state can be set.
        dataSource = [[PatientDataSource alloc] init];
        dataSource.isEditEnabled = NO;
        dataSource.longPressHandler = self;
        // Now populate the data source with the existing patient.
        dataSource.patient = existingPatient;
        [self subscribeToNotifications: YES];
    }
    return self;
}

-(id) initWithData: (id)data {
    return [self initWithPatient: (Patient *)data];
}

-(void) resizeContentByHeight: (NSInteger)height {
    // Resize all the necessary views.
    CGRect tvFrame = tableView.frame;
    tvFrame.size.height += height;
    
    // Apply the resized TableView height.
    self.tableView.frame = tvFrame;
    // Apply the resized scrollable content size.
    self.scrollView.contentSize = tvFrame.size;
}

-(void) reset {
    self.patient = nil;
    [self.dataSource reset];
    numAdditionalRows = 0;
    numAdditionalSections = 0;
    
    // Scroll to top
    [self.scrollView setContentOffset: CGPointMake(0.0, 0.0)];
}

/// refreshView
///
/// Do everything needed to make the UI components reflect the current state
/// of the supporting data.
-(void) refreshView {
    if (self.patient != nil) {
        //TODO:
        
    }
    else {
        //TODO:
        
    }
    
    if (self.showEditButton) {
        self.navigationItem.rightBarButtonItem = editButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // This will resize the view based on whether the Toolbar is visible or hidden.
    if (patient != nil && [patient.priorVisits count] > 0) {
        [self showToolbar];
    }
    else {
        [self hideToolbar];
    }
    
    if ([parentView isKindOfClass: [VisitViewController class]]) {
        dataSource.canSelectVisits = NO;
    }
    else {
        dataSource.canSelectVisits = YES;
    }
    
    // Apply content resize taking into account the variable row count.
    numAdditionalRows = self.dataSource.extraRowCount;
    NSInteger extraSize = numAdditionalRows * [self.tableView rowHeight];
    // Apply content resize taking into account the variable section count.
    numAdditionalSections = self.dataSource.extraSectionCount;
    //extraSize += numAdditionalSections * (staticHeaderHeight + [self.tableView sectionHeaderHeight]);
    extraSize += numAdditionalSections * tableHeaderHeight;
    [self resizeContentByHeight: extraSize];
    
    [dataSource reloadTableData];
    needsViewRefresh = NO;
}

-(void) showToolbar {
    if (isToolbarHidden) {
        isToolbarHidden = NO;
        toolbar.hidden = NO;
        // Shrink the view to make space for the toolbar.
        CGRect scrollFrame = scrollView.frame;
        scrollFrame.size.height -= toolbar.frame.size.height;
        scrollView.frame = scrollFrame;
    }
}

-(void) hideToolbar {
    if (!isToolbarHidden) {
        isToolbarHidden = YES;
        toolbar.hidden = YES;
        // Grow the view to use the extra space.
        CGRect scrollFrame = scrollView.frame;
        scrollFrame.size.height += toolbar.frame.size.height;
        scrollView.frame = scrollFrame;
    }
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
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_C];
}


#pragma mark Actions

-(IBAction) editPatientAction: (id)sender {
    if (self.editPatientViewController == nil) {
        EditPatientViewController *epvc = [[EditPatientViewController alloc] initForEditWithPatient: patient];
        self.editPatientViewController = epvc;
        [epvc release];
        // This will allow the child views to pop to this view when necessary.
        self.editPatientViewController.parentView = self;
    }
    else {
        self.editPatientViewController.patient = patient;
    }
    
    [self.navigationController pushViewController: self.editPatientViewController animated: YES];
}

-(IBAction) emailVisitsReportAction: (id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        @try {
            MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            NSString *emailAddr = [ApplicationSupervisor instance].userEmailAddressSetting;
            if (emailAddr && [emailAddr length] > 0) {
                // Configure message using the user-defined destination email address.
                [mailer setToRecipients: [NSArray arrayWithObject: emailAddr]];
            }
            NSString *subject = [kPatientSubjectPrefix stringByAppendingString: patient.fullName];
            NSString *message = [patient toHtmlReportStringWithTitle: subject];
            NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
            [newDateFormatter setDateFormat: kDateFormatterFormat];
            NSString *date = [newDateFormatter stringFromDate: [NSDate date]];
            [newDateFormatter release];
            NSString *fileName = [NSString stringWithFormat: @"%@_%@_%@.html", patient.firstName, 
                                                                              patient.lastName, 
                                                                              [date stringByReplacingOccurrencesOfString: @"/" withString: @"-"]];
            fileName = [fileName stringByReplacingOccurrencesOfString: @" " withString: @"_"];
            // Also attach the message as an HTML file.
            [mailer addAttachmentData: [message dataUsingEncoding: NSUTF8StringEncoding] mimeType: kHtmlMimeType fileName: fileName];
            [mailer setSubject: subject];
            [mailer setMessageBody: message isHTML: YES];
            [self presentModalViewController:mailer animated:YES];
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

#pragma mark View Lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self applyTheme];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    if ([self.parentView isKindOfClass:[VisitViewController class]]) {
        self.canSelectVisits = NO;
    }
    else {
        self.canSelectVisits = YES;
    }
    
    // Size the ScrollView content to that of the TableView size.
    self.scrollView.contentSize = self.tableView.frame.size;
    
    // Set the TableView's data source.
    self.dataSource.tableView = tableView;
    
    // Indicate that a refresh is needed in case extra rows need to show.
    needsViewRefresh = YES;
}

/** viewWillAppear
 * When the view is visible, listen for keyboard notifications.
 */
-(void) viewWillAppear: (BOOL)animated {
	[super viewWillAppear:animated];
    
    // Refresh the view if it was popped after last viewing.
    if (needsViewRefresh) {
        [self refreshView];
    }
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    
    if ([self.navigationController topViewController] != editPatientViewController
        && [self.navigationController topViewController] != visitViewController
        && [self.navigationController topViewController] != pharmacyView
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

/** viewDidDisappear
 * When the view disappears, remove keyboard notification listeners.
 */
-(void) viewDidDisappear: (BOOL)animated 
{
    [super viewDidDisappear:animated];
    
    // Resize to original size if this view was popped off the navigation controller.
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}

/// viewWasPopped
///
-(void) viewWasPopped {
    // Undo all view resizing that was done for additional rows.
    [self resizeContentByHeight: -numAdditionalRows * [self.tableView rowHeight]];
    // And sections.
    //[self resizeContentByHeight: -numAdditionalSections * (staticHeaderHeight + [self.tableView sectionHeaderHeight])];
    [self resizeContentByHeight: -numAdditionalSections * tableHeaderHeight];
    
    [self reset];
    
    needsViewRefresh = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //[self subscribeToAppNotifications:NO];
    // e.g. self.myOutlet = nil;
    //TODO:
}

/// This allows response to Long Press UITouch events.
-(BOOL)canBecomeFirstResponder {    
    return YES;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
    //self.patient = nil;
}

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [self subscribeToNotifications: NO];
    self.patient = nil;
    self.parentView = nil;
    self.dataSource = nil;
    self.editPatientViewController = nil;
    self.exportVisitsButton = nil;
    self.tableView = nil;
    self.scrollView = nil;
    self.editButton = nil;
    [visitViewController release];
    [pharmacyView release];
    [super dealloc];
}


#pragma mark UITableViewDelegate

/** didSelectRowAtIndexPath
 */
-(void) tableView: (UITableView *)selectedTableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.section == [self.dataSource sectionNumberForSectionTitle: dataSource.visitHistoryLabel]) {
        if (self.canSelectVisits) {
            id item = [self.dataSource dataItemForIndexPath:indexPath];
            if (item && [item isKindOfClass:[Visit class]]) {
                // Show the VisitView.
                if (!visitViewController) {
                    // The view controller has not been created yet.
                    visitViewController = [[VisitViewController alloc] initWithVisit:(Visit *)item];
                    // In this usage, VisitViewController should not show the ViewPatient button.
                    visitViewController.isShowPatientButtonHidden = YES;
                }
                else {
                    visitViewController.visit = (Visit *)item;
                }
                [self.navigationController pushViewController:visitViewController animated:YES];
            }
        }
    }
    else if (indexPath.section == [self.dataSource sectionNumberForSectionTitle: dataSource.pharmaciesLabel]) {
        Pharmacy *pharm = [dataSource dataItemForIndexPath:indexPath];
        // Push the PharmacyView for the selected pharmacy.
        if (!pharmacyView) {
            pharmacyView = [[PharmacyViewController alloc] initWithPharmacy:pharm];
            pharmacyView.parentView = self;
        }
        else {
            pharmacyView.pharmacy = pharm;
        }

        [self.navigationController pushViewController:pharmacyView animated:YES];
    }
}

/// viewForHeaderInSection
/// This allows customized section headers.
-(UIView *) tableView: (UITableView *)tv viewForHeaderInSection: (NSInteger)section {
    static const float leftMargin = 10.0;
    static const float topMargin = 0.0;
    static const float topOffset = 10.0;
    static const int fontSize = 19;
	// create the parent view that will hold header Label.  This allows the label to have some padding.
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(tv.bounds.origin.x, topMargin, tv.bounds.size.width, tableHeaderHeight)] autorelease];
	
	// Create the label object.
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: headerLabel];
	//headerLabel.opaque = NO;
	headerLabel.font = [UIFont boldSystemFontOfSize: fontSize];
	headerLabel.frame = CGRectMake(leftMargin, topOffset, tv.bounds.size.width, tableHeaderHeight - topOffset);
	headerLabel.text = [self.dataSource tableView:tv titleForHeaderInSection:section];
    
	[customView addSubview:headerLabel];
    [headerLabel release];
    
	return customView;
}

-(CGFloat) tableView: (UITableView *)tv heightForHeaderInSection: (NSInteger)section {
	return tableHeaderHeight;
}


#pragma mark MFMailComposeViewControllerDelegate Methods

-(void) mailComposeController: (MFMailComposeViewController*)mailer  
          didFinishWithResult: (MFMailComposeResult)result 
                        error: (NSError *)error {
    if (result == MFMailComposeResultFailed) {
        NSLog(@"Failed to send visit via email.");
    }
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark ParentViewDelegate Methods

-(void) dismissChildView: (UIViewController *)child {
    [self.navigationController popViewControllerAnimated: YES];
}

-(void) childViewWillDisappear: (UIViewController *)child {
    // nothing
}


#pragma mark Event Handling

-(void) handleSetDefaultPharmacyMenuButtonPressed: (UIMenuController*)menuController {
    SetDefaultMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        // Set the selected pharmacy as the default.
        patient.defaultPharmacy = [dataSource.pharmacies objectAtIndex: menuItem.indexPath.row];
        // Update the patient change.
        [[ApplicationSupervisor instance] updatePatient:patient];
        [tableView reloadData];
    }
}

-(void) handleCallPharmacyMenuButtonPressed: (UIMenuController*)menuController {
    SetDefaultMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        // Set the selected pharmacy as the default.
        Pharmacy *callMe = [dataSource.pharmacies objectAtIndex: menuItem.indexPath.row];
        if (callMe && ![callMe tryPlaceCall]) {
            [self showDialerFailAlert: @"Unable to open the phone dialer for this device."];
        }
    }
}

-(void) handleLongPress: (UILongPressGestureRecognizer*)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        // Only the pharmacy section responds to long-press at this time.
        if (pressedIndexPath && pressedIndexPath.row != NSNotFound && pressedIndexPath.section == [dataSource sectionNumberForSectionTitle: pharmaciesLabel]) {
            // Handle a long press on a Pharmacy row.
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            Pharmacy *pharm = [dataSource.pharmacies objectAtIndex: pressedIndexPath.row];
            // Only add this menu item if it is not the default pharmacy already.
            if (pharm && pharm != patient.defaultPharmacy) {
                // Create the 'Set As Default' menu item.
                SetDefaultMenuItem *defaultMenuItem = [[SetDefaultMenuItem alloc] initWithTitle:@"Set As Default" action:@selector(handleSetDefaultPharmacyMenuButtonPressed:)];
                defaultMenuItem.indexPath = pressedIndexPath;
                [items addObject: defaultMenuItem];
                [defaultMenuItem release];
            }
            // Create the 'Call Now' menu item.
            SetDefaultMenuItem *callMenuItem = [[SetDefaultMenuItem alloc] initWithTitle:@"Call Now" action:@selector(handleCallPharmacyMenuButtonPressed:)];
            callMenuItem.indexPath = pressedIndexPath;
            [items addObject: callMenuItem];
            [callMenuItem release];
            // Add all menu items to the menu controller.
            menuController.menuItems = items;
            [items release];
            // Position the menu.
            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

-(void) handleTableViewRowInserted: (NSNotification *)notification {
    PatientDataSource *source = (PatientDataSource *)[notification object];
    if (source == dataSource) {
        numAdditionalRows += 1;
        [self resizeContentByHeight: [self.tableView rowHeight]];
        
        if (numAdditionalSections != dataSource.extraSectionCount) {
            //[self resizeContentByHeight: (staticHeaderHeight + [self.tableView sectionHeaderHeight])];
            [self resizeContentByHeight: tableHeaderHeight];
            numAdditionalSections += 1;
        }
        
        // Now reload the table to show data changes.
        [tableView reloadData];
    }
}

-(void) handleTableViewRowRemoved: (NSNotification *)notification {
    PatientDataSource *source = (PatientDataSource *)[notification object];
    if (source == dataSource) {
        numAdditionalRows -= 1;
        [self resizeContentByHeight: -[self.tableView rowHeight]];
        
        if (numAdditionalSections != dataSource.extraSectionCount) {
            //[self resizeContentByHeight: -(staticHeaderHeight + [self.tableView sectionHeaderHeight])];
            [self resizeContentByHeight: -tableHeaderHeight];
            numAdditionalSections -= 1;
        }
        
        // Now reload the table to show data changes.
        [tableView reloadData];
    }
}

-(void) handlePharmacyCreated: (NSNotification *)notification {
    //TODO: Duhhhh???
}

-(void) handlePatientUpdated: (NSNotification *)notification {
    Patient *p = [notification object];
    if (p == patient) {
        [tableView reloadData];
    }
}

-(void) handlePatientDeleted: (NSNotification *)notification {
    Patient *p = [notification object];
    if (p == patient) {
        [self reset];
        if (self.parentView && self.navigationController) {
            // Not sure if this view is in the nav stack, but try anyway.
            @try {
                // Need to dismiss this view (or any child).
                [self.navigationController popToViewController:self.parentView animated:YES];
            }
            @catch (NSException *exception) {
                // nothing
            }
        }
    }
}

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

///
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    PatientDataSource *psd = (PatientDataSource *)object;
    if (psd != self.dataSource) {
        return;
    }
    
    if ([keyPath isEqualToString:@"isReloadNeeded"] && [self.dataSource isReloadNeeded]) {
        needsViewRefresh = YES;
    }
}

-(void) subscribeToNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addPatientUpdatedObserver:self withHandler:@selector(handlePatientUpdated:)];
        [[ApplicationSupervisor instance] addPatientDeletedObserver:self withHandler:@selector(handlePatientDeleted:)];
        [self.dataSource addTableRowInsertedObserver:self withHandler:@selector(handleTableViewRowInserted:)];
        [self.dataSource addTableRowRemovedObserver:self withHandler:@selector(handleTableViewRowRemoved:)];
        [self.dataSource addPropertyChangeObserver:self];
    }
    else {
        [[ApplicationSupervisor instance] removePatientUpdatedObserver:self];
        [[ApplicationSupervisor instance] removePatientDeletedObserver:self];
        [self.dataSource removeTableRowInsertedObserver:self];
        [self.dataSource removeTableRowRemovedObserver:self];
        [self.dataSource removePropertyChangeObserver:self];
    }
    
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addThemeSettingChangedObserver:self withHandler:@selector(handleThemeChanged:)];
    }
    else {
        [[ApplicationSupervisor instance] removeThemeSettingChangedObserver:self];
    }
}

@end
