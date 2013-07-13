//
//  EditPatientViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "EditPatientViewController.h"
#import "Constants.h"
#import "Patient.h"
#import "PatientDataSource.h"
#import "EditPharmacyViewController.h"
#import "PharmacyViewController.h"
#import "Contact.h"
#import "Pharmacy.h"

//static NSString *kDataGroupTitle = @"titleKey";
//static NSString *kDataGroupKeys = @"keysKey";
//static NSString *kDataGroupValues = @"valuesKey";
static const float tableHeaderHeight = 44.0;

/**
 Using an empty category to simulate a private method declaration.
 */
@interface EditPatientViewController ()

/**
 */
-(id) privateInitWithPatient: (Patient *) p andTitle: (NSString *) s;

/**
 */
-(BOOL) validatePatient;

/**
 */
- (void) slideDownDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context;
- (void) hideNavBarDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context;
- (void) hideImportBarDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context;

/**
 */
- (void) dismissDatePicker;

/**
 */
-(void) showDatePicker: (UITableView *)tv;

/**
 */
-(void) showInvalidUserAlert;

-(void) showDeletionDialog;

-(void) showImportWarning;

-(void) deletePatient;

-(void) showSaveButton;

-(void) showDismissEditorButton;

-(void) makeSelectedFieldVisible;

/**
 */
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo;
-(void) subscribeToPharmacyViewNotifications: (BOOL)yesNo;

-(void) resizeViewByHeight: (NSInteger)height;

-(void) reset;

-(void) refreshView;

-(void) hideNavigationBar;

-(void) hideImportNavigationBar;

-(void) handleSetDefaultPharmacyMenuButtonPressed: (UIMenuController*)menuController;

-(void) handleTableViewRowInserted: (NSNotification *)notification;

-(void) handleTableViewRowRemoved: (NSNotification *)notification;

-(void) handleShowPharmacyViewRequest: (NSNotification *)notification;

-(void) handlePharmacyAdded: (NSNotification *)notification;

-(void) handleSetDefaultPharmacyMenuButtonPressed: (UIMenuController*)menuController;

-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end


@implementation EditPatientViewController

#pragma mark - Properties

@synthesize parentView;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize pickerView;
@synthesize dismissEditorButton;
@synthesize saveButton;
@synthesize deletePatientButton;
@synthesize navBar;
@synthesize importBar;
@synthesize isNewPatient;
@synthesize tableView;
@synthesize dataSource;

@synthesize editPharmacyView;
-(void) setEditPharmacyView: (EditPharmacyViewController *)value {
    if (editPharmacyView == value) {
        return;
    }
    // Stop listening to save event from old EditPharmacyView.
    [self subscribeToPharmacyViewNotifications: NO];
    
    [editPharmacyView autorelease];
    editPharmacyView = [value retain];
    
    if (editPharmacyView) {
        // Listen for save event from EditPharmacyView.
        [self subscribeToPharmacyViewNotifications: YES];
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
        // This forces the table to re-fetch each cell, therefore refreshing the cell contents for the new patient value.
        [tableView reloadData];
    }
}


#pragma mark - Methods

/// The designated initializer redirects to a custom init for a new Patient.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

/// Just redirect to initWithNewPatient.
-(id) init {
    return [self initWithNewPatient:[[[Patient alloc] init] autorelease]];
}

-(id) initForEditWithPatient: (Patient *) existingPatient {
    
    [self privateInitWithPatient: existingPatient andTitle: @"Edit Patient"];
    isNewPatient = NO;
    wasViewPopped = NO;
    isImportBarHidden = YES;
    needsViewRefresh = YES;
    return self;
}

-(id) initWithNewPatient: (Patient *) newPatient {
    [self privateInitWithPatient: newPatient andTitle: @"New Patient"];
    isNewPatient = YES;
    wasViewPopped = NO;
    isImportBarHidden = YES;
    needsViewRefresh = NO;
    return self;
}

-(void) hideImportNavigationBar {
    isImportBarHidden = YES;
    importBar.hidden = YES;
    importBar.alpha = 1;
    
    if (!self.navigationController) {
        // If view is modal, make the NavBar visible again.
        navBar.hidden = NO;
        navBar.alpha = 1;
    }
    else {
        // If under NavController jurisdiction, move the button bar back up and away.
        CGRect barFrame = importBar.frame;
        CGRect scrollFrame = scrollView.frame;
        // The ImportBar's hidden origin depends on whether this is an edit or new patient.
        barFrame.origin.y = -barFrame.size.height;
        importBar.frame = barFrame;
        
        // If the scrollView has not been repositioned yet, do it now (animation not needed).
        if (scrollFrame.origin.y > 0) {
            scrollFrame.origin.y = 0;
            scrollFrame.size.height += importBar.frame.size.height;
            scrollView.frame = scrollFrame;
        }
    }
}

-(void) hideNavigationBar {
//    if (!self.navigationController) {
        navBar.hidden = YES;
//    }
//    else {
//        self.navigationController.navigationBar.hidden = YES;
//    }
}

-(void) deletePatient {
    // Assume the user already confirmed the deletion at this point.
    [self.dataSource forgetChanges];
        
    [[ApplicationSupervisor instance] deletePatient: patient];
    //[parentView dismissChildView: self];
    self.patient = nil;
    // PatientViewController will dismiss both this view and itself when
    // it receives the delete notification.
}

-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context {    
    [self makeSelectedFieldVisible];
}

-(void) makeSelectedFieldVisible {
    UITextField *selectedField = self.dataSource.fieldBeingEdited;
    if (selectedField) {
        NSInteger section = selectedField.superview.tag;
        NSInteger row = selectedField.tag;
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        CGRect selectedFrame = [self.tableView rectForRowAtIndexPath:path];
        [self.scrollView scrollRectToVisible:selectedFrame animated:YES];
    }
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_D];
}

/// Reset the Save button to "save" or "update" function based on edit mode, and make it visible.
-(void) showSaveButton {
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    else {
        //TODO: see that this works!
        for (UIView *vue in navBar.subviews) {
            if ([vue isKindOfClass: [UINavigationItem class]]) {
                ((UINavigationItem *)vue).rightBarButtonItem = saveButton;
                break;
            }
        }
    }
    if (isNewPatient) {
        self.saveButton.action = @selector(savePatientAction:);
    }
    else {
        self.saveButton.action = @selector(updatePatientAction:);
    }
}

/// Make the DismissEditor button visible.
-(void) showDismissEditorButton {
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = dismissEditorButton;
    }
    else {
        //TODO: see that this works!
        for (UIView *vue in navBar.subviews) {
            if ([vue isKindOfClass: [UINavigationItem class]]) {
                ((UINavigationItem *)vue).rightBarButtonItem = dismissEditorButton;
                break;
            }
        }
    }
}


#pragma mark Actions

-(IBAction) savePatientAction: (id)sender {
    [self dismissDatePicker];
    [self dismissKeyboard];
    
    if ([self validatePatient]) {
        ModificationTracker *changes = [self.dataSource applyChanges];
        if (isNewPatient) {
            if (![[ApplicationSupervisor instance] hasIdenticalPatient: patient]) {
                NSLog(@"Saving a new patient '%@' with ident: %@", patient.fullName, patient.ident);
                if ([[ApplicationSupervisor instance] hasEquivalentPatient: patient]) {
                    NSLog(@"ERROR: failed to save a new patient because an equivalent patient '%@' already exists", patient.fullName);
                }
                else {
                    // Propagate the Pharmacy additions to the AppSuper.
                    [[ApplicationSupervisor instance] createPharmacies: [changes additionsForClass: [Pharmacy class]]];
                    
                    //BEWARE: there seems to be a race condition here between NSNotifications for ApplicationSupe and PatientView
                    [[ApplicationSupervisor instance] createPatient: patient];
                    [parentView dismissChildView: self];
                }
            }
            else if (isNewPatient) {
                NSLog(@"ERROR: failed to save a new patient because a patient already exists with ident: %@", patient.ident);
            }
        }
    }
    else {
        [self showInvalidUserAlert];
    }

}

-(IBAction) updatePatientAction: (id)sender {
    [self dismissDatePicker];
    [self dismissKeyboard];
    
    if ([self validatePatient ]) {
        NSLog(@"Saving changes to an existing patient '%@' with ident: %@", patient.fullName, patient.ident);
        ModificationTracker *changes = [self.dataSource applyChanges];
        // Propagate the pharmacy deletions to the AppSuper.
        [[ApplicationSupervisor instance] deletePharmacies: [changes deletionsForClass: [Pharmacy class]]];
        // Propagate the pharmacy additions to the AppSuper.
        [[ApplicationSupervisor instance] createPharmacies: [changes additionsForClass: [Pharmacy class]]];
        
        //BEWARE: there seems to be a race condition here between NSNotifications for AppSuper and PatientView
        [parentView dismissChildView: self];
        // Propagate the patient updates to the AppSuper.
        [[ApplicationSupervisor instance] updatePatient: patient];
    }
    else {
        [self showInvalidUserAlert];
    }
}

-(IBAction) deletePatientAction: (id)sender {
    [self dismissDatePicker];
    [self dismissKeyboard];
    
    [self showDeletionDialog];
}

-(IBAction) cancelAction: (id)sender {
    [self dismissDatePicker];
    [self dismissKeyboard];
    
    [self.dataSource forgetChanges];
    [parentView dismissChildView: self];
    self.patient = nil;
}

-(IBAction) setDateAction: (id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
    
    NSDateFormatter *bdayFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [bdayFormatter setDateFormat: kDateFormatterFormat];
    self.dataSource.dateOfBirth = [bdayFormatter stringFromDate: pickerView.date];
    cell.detailTextLabel.text = self.dataSource.dateOfBirth;
}

-(IBAction) dismissDatePickerAction: (id)sender {
    [self dismissDatePicker];
}

-(IBAction) importPatientDataAction: (id)sender {
    if (!isNewPatient) {
        [self showImportWarning];
    }
    // Open contacts, then set patient data based on selected contact.
    ABPeoplePickerNavigationController *contactBrowser = [[ABPeoplePickerNavigationController alloc] init];
    
    contactBrowser.peoplePickerDelegate = self;
    //contactBrowser.displayedProperties = 
    
    [self presentModalViewController: contactBrowser animated:YES];
    
    [contactBrowser release];
}

-(IBAction) hideDataImportToolbarAction: (id)sender {
    if (importBar.hidden == NO) {
        navBar.hidden = NO;
        CGRect scrollFrame = scrollView.frame;
        scrollFrame.origin.y = 0;
        scrollFrame.size.height += importBar.frame.size.height;
        
        [UIView beginAnimations:@"HideImportButtonBar" context:NULL];
        [UIView setAnimationDuration:0.35];
        
        // We need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(hideImportBarDidStop:finished:context:)];
        [importBar setAlpha:0];
        // Toolbar appearance depends on whether this view is modal or controlled by a NavController.
        if (self.navigationController) {
            // If under NavController jurisdiction, animate the scroll view back up to top.
            scrollView.frame = scrollFrame;
        }
        else {
            // If modal, animate the NavBar back into view.
            [navBar setAlpha:1];
        }
        [UIView commitAnimations];
    }
}


#pragma mark ViewControllerBase Methods

-(void) dismissKeyboard {
    [self.dataSource dismissKeyboard];
}

-(void) animateKeyboardWillShow: (NSNotification *)notification {
    // Swap the Save button to the DismissEditor button and set its action for keyboard.
    [self showDismissEditorButton];
    self.dismissEditorButton.action = @selector(dismissKeyboard);
    
    // Resize scrollView for keyboard.
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.height -= keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:animationDuration];
    // Set the completion handler to scroll the field into view.
    [UIView setAnimationDidStopSelector: @selector(keyboardResizeDidFinish:finished:context:)];
    scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

-(void) animateKeyboardWillHide: (NSNotification *)notification {
    // Swap the DoneEditing button to the Save button.
    [self showSaveButton];
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.height += keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

/// viewWasPopped
///
-(void) viewWasPopped {
    
    // Resize the view to original state.
    // Undo all view resizing that was done for additional rows.
    [self resizeViewByHeight: -numAdditionalRows * [self.tableView rowHeight]];
    [self reset];
    // Clear dataSource changes.
    [self.dataSource forgetChanges];
    // Put the Import NavBar back to default state.
    [self hideImportNavigationBar];
    // Denote that the view needs a refresh so that the size is expanded if necessary on a re-push.
    needsViewRefresh = YES;
}

/// If this view's NavigationController is a child of another NavigationController, set the state to wasPopped=YES.
-(void) setViewWasPopped {
    if ([[self.navigationController parentViewController] isKindOfClass: [UINavigationController class]]) {
        wasViewPopped = YES;
    }
}


#pragma mark UIViewController Lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
 */

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    numAdditionalRows = self.dataSource.extraRowCount;
    
    // Set the DataSource's table reference.  This also set's the table's dataSource.
    self.dataSource.tableView = self.tableView;
    
    [self applyTheme];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    if (isNewPatient) {
        // Hide the delete button
        [deletePatientButton setHidden: YES];
    }
    else {
        [deletePatientButton setHidden: NO];
    }
    
    // Set the right bar button and its action depending on state.
    [self showSaveButton];
    
    // The ImportBar's hidden origin depends on whether this was pushed into a nav controller or not.
    if (self.navigationController) {
        if (isNewPatient) {
            // New Patient view requires a left button since it is the root view in this NavController.
            self.navigationItem.leftBarButtonItem = navBar.topItem.leftBarButtonItem;
        }
        
        CGRect barFrame = importBar.frame;
        barFrame.origin.y = -self.navigationController.navigationBar.frame.size.height;
        importBar.frame = barFrame;
    }
    else {
        // Using a custom NavigationBar instead of one supplied by a NavigationController.
        [self.view addSubview: navBar];
        navBar.topItem.title = self.title;
        
        // Need to move the scrollview down to make room.
        CGRect contentFrame = self.scrollView.frame;
        contentFrame.origin.y += navBar.frame.size.height;
        contentFrame.size.height -= navBar.frame.size.height;
        self.scrollView.frame = contentFrame;
    }
    
    // Size the ScrollView's scrollable area to that of the ScrollContentView.
    CGSize contentSize = self.tableView.superview.frame.size;
    scrollView.contentSize = contentSize;
    
    // This will show the red delete buttons next to removable cells.
    [tableView setEditing:YES animated:NO];
    tableView.allowsSelectionDuringEditing = YES;
}

/** viewWillAppear
 * When the view is visible, listen for keyboard notifications.
 */
-(void) viewWillAppear: (BOOL)animated {
	[super viewWillAppear:animated];
    
    isAtTopOfScroll = (scrollView.contentOffset.y == 0);
    
    // Refresh the view if it was popped after last viewing.
    if (needsViewRefresh) {
        // Apply view resize taking into account the variable row count.
        numAdditionalRows = self.dataSource.extraRowCount;
        [self resizeViewByHeight:numAdditionalRows * [self.tableView rowHeight]];
        // Refresh the table view to match the data.
        [self.dataSource reloadTableData];
        needsViewRefresh = NO;
    }
    
    // If EditPharmacyViewController is cancelled, remove empty table row.
    //[self.dataSource purgeUnfinishedRow];
}

-(void) viewWillDisappear: (BOOL)animated {
    // Super view dismisses the keyboard.
    [super viewWillDisappear: animated];
    
    // Get rid of any visible datePicker.
    [self dismissDatePicker];
    
    if ([self.navigationController topViewController] != editPharmacyView
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

/** viewDidDisappear
 * When the view disappears, remove keyboard notification listeners.
 */
-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Resize to original size if this view was popped off the navigation controller.
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
    //[self.dataSource forgetChanges];
    
}

/// This was added to enable long-press handling.
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
//    [pharmacyView release];
//    pharmacyView = nil;
//    self.editPharmacyView = nil;
//    self.patient = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //TODO:
//    [self subscribeToAppNotifications:NO];
//    [pharmacyView release];
//    pharmacyView = nil;
//    self.editPharmacyView = nil;
}

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [self subscribeToDataSourceNotifications: NO];
    self.patient = nil;
    // This will unsubscribe to the editPharmacyView notifications too.
    self.editPharmacyView = nil;
    [dataSource release];
    self.parentView = nil;
    self.scrollView= nil;
    self.scrollContentView = nil;
    self.navBar = nil;
    self.importBar = nil;
    self.pickerView = nil;
    self.dismissEditorButton = nil;
    self.saveButton = nil;
    self.deletePatientButton =nil;
    [super dealloc];
}


#pragma mark ABPeoplePickerNavigationController Methods

-(BOOL) peoplePickerNavigationController: (ABPeoplePickerNavigationController *)pPicker shouldContinueAfterSelectingPerson: (ABRecordRef)person {
    if (ABRecordGetRecordType(person) == kABPersonType) {
        // Grab personal info values.
        NSString *strValue = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (strValue && ![strValue isEqualToString:@""]) {
            self.patient.firstName = strValue;
        }
        [strValue release];
        strValue = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (strValue && ![strValue isEqualToString:@""]) {
            self.patient.lastName = strValue;
        }
        [strValue release];
        NSDate *bday = (NSDate *)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        if (bday) {
            self.patient.dateOfBirth = bday;
        }
        [bday release];
        
        // Grab address values
        ABMultiValueRef addrValues = ABRecordCopyValue(person, kABPersonAddressProperty);
        NSArray *addresses = (NSArray *)ABMultiValueCopyArrayOfAllValues(addrValues);
        for (NSDictionary *addr in addresses) {
            strValue = [addr objectForKey: (NSString *)kABPersonAddressStreetKey];
            if (strValue && ![strValue isEqualToString:@""]) {
                self.patient.contactInfo.address = strValue;
            }
            strValue = [addr objectForKey: (NSString *)kABPersonAddressCityKey];
            if (strValue && ![strValue isEqualToString:@""]) {
                self.patient.contactInfo.city = strValue;
            }
            strValue = [addr objectForKey: (NSString *)kABPersonAddressStateKey];
            if (strValue && ![strValue isEqualToString:@""]) {
                self.patient.contactInfo.state = strValue;
            }
            strValue = [addr objectForKey: (NSString *)kABPersonAddressZIPKey];
            if (strValue && ![strValue isEqualToString:@""]) {
                self.patient.contactInfo.zip = [strValue intValue];
            }
            
            // For now, only handle one address.
            break;
        }
        [addresses release];
        CFRelease(addrValues);
        
        // Grab ContactInfo values.
        ABMultiValueRef emailValues = (NSString*)ABRecordCopyValue(person, kABPersonEmailProperty);
        NSArray *emails = (NSArray *)ABMultiValueCopyArrayOfAllValues(emailValues);
        for (NSString *email in emails) {
            if (email && ![email isEqualToString:@""]) {
                self.patient.contactInfo.email = email;
                // for now only handle one email address.
                break;
            }
        }
        [emails release];
        CFRelease(emailValues);
        
        ABMultiValueRef phoneValues = (NSString*)ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *phones = (NSArray *)ABMultiValueCopyArrayOfAllValues(phoneValues);
        for (NSString *phone in phones) {
            if (phone && ![phone isEqualToString:@""]) {
                self.patient.contactInfo.phone = phone;
                // for now only handle one phone number.
                break;
            }
        }
        [phones release];
        CFRelease(phoneValues);
        
        // Force the tableview to use the new values.
        [self.tableView reloadData];
        // Put the navigation bars back to normal state.
        navBar.hidden = NO;
        navBar.alpha = 1;
        [self hideImportNavigationBar];
        
        [self dismissModalViewControllerAnimated:YES];
        return NO;   
    }
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

-(BOOL) peoplePickerNavigationController: (ABPeoplePickerNavigationController *)pPicker shouldContinueAfterSelectingPerson: (ABRecordRef)person 
                                property: (ABPropertyID)property 
                              identifier: (ABMultiValueIdentifier)identifier {
    [self dismissModalViewControllerAnimated:YES];
    [self hideImportNavigationBar];
    return NO;
}

-(void) peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
    [self hideImportNavigationBar];
    
    // For some reason, existing patient data gets wiped even on Cancel.
    if (!isNewPatient) {
        [self refreshView];
    }
}


#pragma mark UITableViewDelegate

/** didSelectRowAtIndexPath
 */
-(void) tableView: (UITableView *)tv didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    //NSString *sectionTitle = [dataSource.orderedSectionTitles objectAtIndex: indexPath.section];
    
    // Show the date picker if the DateOfBirth field is selected.
    if ([indexPath isEqual:[dataSource indexPathOfBirthdayCell]]) {
        [self dismissKeyboard];
        if (patient.dateOfBirth) {
            pickerView.date = patient.dateOfBirth;
        }
        else {
            pickerView.date = [NSDate date];
        }
        [self showDatePicker:tv];
    }
    else {
        [self dismissDatePicker];
        
        if (indexPath.section == [dataSource sectionNumberForSectionTitle: dataSource.pharmaciesLabel]) {
            
            //TODO:
            
        }
    }
}

/** editingStyleForRowAtIndexPath
 */
-(UITableViewCellEditingStyle) tableView: (UITableView *)tv editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    return [self.dataSource tableView:tv editingStyleForRowAtIndexPath:indexPath];
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


#pragma mark UIScrollViewDelegate Methods

-(void) scrollViewDidScroll: (UIScrollView *)sv {
    // If a NavController exists, the exposed bar rests below it at (0,0).  Otherwise it must
    // be put below a custom toolbar.
    NSInteger exposedYOrigin = (self.navigationController ? 0 : navBar.frame.size.height);
    NSInteger hiddenYOrigin = exposedYOrigin - importBar.frame.size.height;
    // ImportBar's resting origin is always Zero, whether in edit or new mode.
    NSInteger finalYOrigin = 0;
    CGRect barFrame = importBar.frame;
    BOOL isScrollingDown = lastScrollOffset > sv.contentOffset.y;
    
        // If the last scroll position is at the top and user starts scrolling down...
    if (isScrollingDown) {
        // Slide the input bar down with the scroll view until it reaches it's own height.
        if (isAtTopOfScroll && importBar.frame.origin.y < exposedYOrigin
            && navBar.hidden == NO && sv.contentOffset.y < 0) {
            //NSLog(@"content offset last=%i, now=%f", lastScrollOffset, sv.contentOffset.y);
            importBar.hidden = NO;
            barFrame.origin.y += lastScrollOffset - sv.contentOffset.y;
            if (barFrame.origin.y > barFrame.size.height) {
                barFrame.origin.y = barFrame.size.height;
            }
            importBar.frame = barFrame;
        }
    }
    else if (barFrame.origin.y < finalYOrigin) {
        isAtTopOfScroll = NO;
        // Scrolling up and the ImportBar was never fully exposed, so slide it to be hidden again.
        barFrame.origin.y += lastScrollOffset - sv.contentOffset.y;
        // Only slide it back up as far as the origin of the hidden placement.
        if (barFrame.origin.y < hiddenYOrigin) {
            barFrame.origin.y = hiddenYOrigin;
        }
        importBar.frame = barFrame;
    }
    else if (barFrame.origin.y > finalYOrigin) {
        // if the ImportBar is visible and pulled down beyond its exposed resting place.
        isAtTopOfScroll = NO;
        // If there is no NavController, the toolbar can be dissolved and the ImportBar placed on top.
        if (!self.navigationController && barFrame.origin.y == barFrame.size.height + finalYOrigin) {
            // If the ImportBar is pulled down to the base of the NavBar, fade the NavBar out.
            [UIView beginAnimations:@"HideNavButtonBar" context:NULL];
            [UIView setAnimationDuration:0.25];
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(hideNavBarDidStop:finished:context:)];
            [navBar setAlpha:0];
            [UIView commitAnimations];
        }
        
        //NSLog(@"content offset last=%i, now=%f", lastScrollOffset, sv.contentOffset.y);
        
        // Slide the input bar back up with the scroll view.
        barFrame.origin.y += lastScrollOffset - sv.contentOffset.y;
        // Only slide it back up as far as the final resting place.
        if (barFrame.origin.y < finalYOrigin) {
            barFrame.origin.y = finalYOrigin;
        }
        importBar.frame = barFrame;
    }
    else if (isImportBarHidden) {
        // Else the view is scrolling up while the ImportBar is fully exposed.
        isAtTopOfScroll = NO;

        // If the importBar hits its final resting place, just set it in place.
        isImportBarHidden = NO;
        CGRect scrollFrame = scrollView.frame;
        scrollFrame.origin.y = finalYOrigin + barFrame.size.height;
        scrollFrame.size.height -= barFrame.size.height;
        // Sometimes the ImportBar moves a bit into its resting place, so just animate that to make it smooth.
        [UIView beginAnimations:@"SetImportBarInPlace" context:NULL];
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.2];
        // If there is a NavController, the import bar is below a NavigationBar so make the content slide below the import bar.
        if (self.navigationController) {
            scrollView.frame = scrollFrame;
            scrollView.contentSize = scrollContentView.frame.size;
        }
        importBar.frame = barFrame;
        [UIView commitAnimations];
    }
    
    lastScrollOffset = scrollView.contentOffset.y;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)sv {
    isAtTopOfScroll = (sv.contentOffset.y == 0);
}


#pragma mark UIAlertViewDelegate Methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Only delete the patient if the Confirm button was clicked.
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self deletePatient];
    }
}


#pragma mark ParentViewDelegate Methods

-(void) dismissChildView: (UIViewController *)child {
    // nothing
}

-(void) childViewWillDisappear: (UIViewController *)child {
    // Time to assign the data from the calling child view.
    if ([child isKindOfClass: [EditPharmacyViewController class]]) {
//        EditPharmacyViewController *pharmacyView = (EditPharmacyViewController *)child;
//        if (pharmacyView.pharmacy) {
//            [patient addPharmacy: pharmacyView.pharmacy];
//        }
    }
}


#pragma mark Private Methods

-(id) privateInitWithPatient: (Patient *)p andTitle: (NSString *)s {
    self = [super initWithNibName: @"EditPatientView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = s;
        patient = [p retain];
        numAdditionalRows = 0;
        // Initialize the data source for all tables with regard to the patient.
        dataSource = [[PatientDataSource alloc] initWithPatient:p allowCellEdit:YES];
        dataSource.longPressHandler = self;
        //dataSource.patient = p;
        //dataSource.isEditEnabled = YES;
        [self subscribeToDataSourceNotifications: YES];
    }
    return self;
}

///TODO: Is this even used???
-(void) refreshView {
    if (self.patient != nil) {
//        if (self.patient.patient != nil) {
//            self.patientName = [NSString stringWithFormat:@"%@ %@", self.visit.patient.firstName, self.visit.patient.lastName];
//        }
//        else {
//            self.patientName = @"";
//        }
    }
    else {
    }
    
    [self showSaveButton];
    
    needsViewRefresh = NO;
}

-(void) reset {
    [self dismissKeyboard];
    [self.dataSource reset];
    
    self.patient = nil;
    numAdditionalRows = 0;
    
    // Scroll to top
    [self.scrollView setContentOffset: CGPointMake(0.0, 0.0)];
}

-(void) resizeViewByHeight: (NSInteger)height {
    // Resize all the necessary views.
    CGRect tvFrame = tableView.frame;
    CGRect contentFrame = self.scrollContentView.frame;
    tvFrame.size.height += height;
    contentFrame.size.height += height;
    
    // Apply the resized TableView height.
    self.tableView.frame = tvFrame;
    // Apply the resized ScrollContentView height.
    self.scrollContentView.frame = contentFrame;
    // Apply the resized scrollable content size.
    self.scrollView.contentSize = contentFrame.size;
}

/** validatePatient
 * Validates the current patient data held by this ViewControllers DataSource, which may or may not be
 in sync with this controller's patient.
 */
-(BOOL) validatePatient {
    if ((self.dataSource.firstName && ![self.dataSource.firstName isEqualToString: @""])
        || (self.dataSource.lastName && ![self.dataSource.lastName isEqualToString: @""])) {
        return YES;
    }
    return NO;
}

-(void) slideDownDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
	// the date picker has finished sliding downwards, so remove it
	[pickerView removeFromSuperview];
}

-(void) hideNavBarDidStop:(NSString *)animationId finished:(BOOL)finished context:(void *)context {
    [self hideNavigationBar];
}

-(void) hideImportBarDidStop:(NSString *)animationId finished:(BOOL)finished context:(void *)context {
    [self hideImportNavigationBar];
}

- (void) dismissDatePicker {
    if (pickerView.superview != nil) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;

        // start the slide down animation
        [UIView beginAnimations:@"ResizeForDatePicker" context:NULL];
        [UIView setAnimationDuration:0.3];

        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop:finished:context:)];
        pickerView.frame = endFrame;
        [UIView commitAnimations];
        
        // Swap the DismissEditor button back to the Save button.
        [self showSaveButton];
        
        // deselect the DOB cell
        [tableView deselectRowAtIndexPath:[dataSource indexPathOfBirthdayCell] animated:YES];
    }
}

-(void) showDatePicker: (UITableView *)tv {
    // check if our date picker is already on screen
    if (pickerView.superview == nil) {
        // Make sure the keyboard is not visible
        [self dismissKeyboard];
        
        [self.view.window addSubview: pickerView];
        
        // Swap the Save button to the DismissEditor button and set its action for the DatePicker.
        [self showDismissEditorButton];
        self.dismissEditorButton.action = @selector(dismissDatePickerAction:);
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width, pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:@"ResizeForDatePicker" context:NULL];
        [UIView setAnimationDuration:0.3];
        // we need to perform some post operations after the animation is complete.
        [UIView setAnimationDelegate:self];
        pickerView.frame = pickerRect;
        [UIView commitAnimations];
    }
}

-(void) showInvalidUserAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"A new patient requires a first or last name." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) showDeletionDialog {
    UIAlertView *deleteView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" 
                                                         message:@"Deleting a Patient will expunge all related visit information." 
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel" 
                                               otherButtonTitles:@"Confirm", nil];
    [deleteView show];
    [deleteView release];
}

-(void) showImportWarning {
    UIAlertView *deleteView = [[UIAlertView alloc] initWithTitle:@"Warning" 
                                                         message:@"Importing contact data will overwrite existing values." 
                                                        delegate:self
                                               cancelButtonTitle:@"Ok" 
                                               otherButtonTitles:nil];
    [deleteView show];
    [deleteView release];
}


#pragma mark Event Handling

-(void) handleSetDefaultPharmacyMenuButtonPressed: (UIMenuController*)menuController {
    
    SetDefaultMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        // Set the selected pharmacy as the default.
        patient.defaultPharmacy = [dataSource.pharmacies objectAtIndex: menuItem.indexPath.row];
        [tableView reloadData];
    }
}

-(void) handleLongPress: (UILongPressGestureRecognizer*)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            SetDefaultMenuItem *menuItem = [[SetDefaultMenuItem alloc] initWithTitle:@"Set As Default" action:@selector(handleSetDefaultPharmacyMenuButtonPressed:)];
            menuItem.indexPath = pressedIndexPath;
            menuController.menuItems = [NSArray arrayWithObject:menuItem];
            [menuItem release];
            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

-(void) handleTableViewRowInserted: (NSNotification *)notification {
    PatientDataSource *source = (PatientDataSource *)[notification object];
    if (source == dataSource) {
        //id info = [notification userInfo];
        [self dismissKeyboard];
        numAdditionalRows += 1;
        [self resizeViewByHeight: [self.tableView rowHeight]];
        // Forced reload is needed.
        [tableView reloadData];
    }
}

-(void) handleTableViewRowRemoved: (NSNotification *)notification {
    PatientDataSource *source = (PatientDataSource *)[notification object];
    if (source == dataSource) {
        numAdditionalRows -= 1;
        [self resizeViewByHeight: -[self.tableView rowHeight]];
        // Forced reload is needed.
        [tableView reloadData];
    }
}

/// handlePharmacyAdded
/// Handles the case where a notification indicates that a new or existing Pharmacy needs to be added to the Patient.
-(void) handlePharmacyAdded: (NSNotification *)notification {
    if ([notification object] == editPharmacyView) {
        // Adding the Pharm to the dataSource.  It won't be created or referenced until the patient changes are saved.
        // Make sure to insert in the right place!
        [self.dataSource.pharmacies insertObject: editPharmacyView.pharmacy atIndex:[dataSource.pharmacies count] - 1];
        numAdditionalRows += 1;
        [self resizeViewByHeight: [self.tableView rowHeight]];
        // Forced reload is needed.
        [tableView reloadData];
    }
}

//-(void) handleExistingPharmacyAdded: (NSNotification *)notification {
//    if ([notification object] == editPharmacyView) {
//        // Adding the Pharm to the Patient object.
//        [patient addPharmacy: editPharmacyView.pharmacy];
//        // Make sure to insert in the right place!
//        [self.dataSource.pharmacies insertObject: editPharmacyView.pharmacy atIndex:[dataSource.pharmacies count] - 1];
//        numAdditionalRows += 1;
//        [self resizeViewByHeight: [self.tableView rowHeight]];
//        // Forced reload is needed.
//        [tableView reloadData];
//    }
//}

-(void) handleShowPharmacyViewRequest: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [NotificationArgs class]]) {
        NotificationArgs *args = (NotificationArgs *)[notification object];
        if (args.notificationSender == self.dataSource
            && [args.notificationData isKindOfClass: [Pharmacy class]]) {
            Pharmacy *newPharm = (Pharmacy *)args.notificationData;
            
            // Show the view for a new pharmacy.
            if (!editPharmacyView) {
                self.editPharmacyView = [[[EditPharmacyViewController alloc] initWithNewPharmacy:newPharm] autorelease];
            }
            else {
                editPharmacyView.pharmacy = newPharm;
            }
            editPharmacyView.parentView = self;
            editPharmacyView.isNewPharmacy = YES;
            // View handling for new Pharmacy differs depending on how this view was presented.
            if (self.navigationController) {
                [self.navigationController pushViewController: editPharmacyView animated:YES];
            }
            else {
                //TODO: THIS IS A BUG FOR NOW. Modal view mode not supported yet.
                // THERE IS NO NAVBAR TO PROVIDE A SAVE OR CANCEL FOR THE VIEW.
//                [editPharmacyView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//                [self presentModalViewController:editPharmacyView animated:YES];
            }
        }
    }
}

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

/** observeValueForKeyPath
 *
 When the editing status of the data source changes, this event handler dismisses any special editors.
 */
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)sender change:(NSDictionary *)change context:(void *)context {
    if (sender == self.dataSource) {
        if ([keyPath isEqualToString: isEditingKey ]) {
            if (((PatientDataSource *)sender).isEditing) {
                [self dismissDatePicker];
                
                //TODO: dismiss keyboard
            }
        }
        else if ([keyPath isEqualToString: fieldBeingEditedKey]) {
            // Make the newly selected field visible.
            [self makeSelectedFieldVisible];
        }
    }
}

///
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo {
    if (yesNo) {
        [self.dataSource addPropertyChangeObserver: self];
        [self.dataSource addTableRowInsertedObserver:self withHandler:@selector(handleTableViewRowInserted:)];
        [self.dataSource addTableRowRemovedObserver:self withHandler:@selector(handleTableViewRowRemoved:)];
        [self.dataSource addShowPharmacyViewRequestObserver:self withHandler:@selector(handleShowPharmacyViewRequest:)];
    }
    else {
        [self.dataSource removePropertyChangeObserver: self];
        [self.dataSource removeTableRowInsertedObserver:self];
        [self.dataSource removeTableRowRemovedObserver:self];
        [self.dataSource removeShowPharmacyViewRequestObserver:self];
    }
}
     
-(void) subscribeToPharmacyViewNotifications: (BOOL)yesNo {
    if (yesNo) {
        [self.editPharmacyView addPharmacySavedObserver:self withHandler: @selector(handlePharmacyAdded:)];
        [self.editPharmacyView addPharmacyReferencedObserver:self withHandler: @selector(handleExistingPharmacyAdded:)];
    }
    else {
        [self.editPharmacyView removePharmacySavedObserver: self];
        [self.editPharmacyView removePharmacyReferencedObserver: self];
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
