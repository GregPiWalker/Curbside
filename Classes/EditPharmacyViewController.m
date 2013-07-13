//
//  EditPharmacyViewController.m
//  CurbSide
//
//  Created by Greg Walker on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditPharmacyViewController.h"
#import "ApplicationSupervisor.h"
#import "Constants.h"
#import "ContactListDataSource.h"
#import "PharmacyLookupDataSource.h"
#import "Pharmacy.h"
#import "Contact.h"

@interface EditPharmacyViewController ()

-(BOOL) validatePharmacy;

-(void) showInvalidPharmacyAlert;

-(void) moveCurrentFieldIntoVisibleArea;
-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo;

@end


@implementation EditPharmacyViewController

@synthesize parentView;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize autocompleteTableView;
@synthesize saveButton;
@synthesize dismissEditorButton;
@synthesize nameTextField;
@synthesize contactInfoTableView;
@synthesize isNewPharmacy;
@synthesize controlBeingEdited;
@synthesize deletePharmacyButton;
@synthesize contactLabel;
@synthesize nameLabel;
@synthesize pharmacyLookupDataSource;
@synthesize contactListDataSource;

@synthesize pharmacy;
-(void) setPharmacy: (Pharmacy *)value {
    if (value == pharmacy) {
        return;
    }
    [pharmacy autorelease];
    pharmacy = [value retain];
    needsViewRefresh = YES;
    
    if (pharmacy && contactListDataSource) {
        // Update the pharmacy's ContactListDataSource. Only one Contact for now.
        [contactListDataSource populateContacts: [NSArray arrayWithObject: pharmacy.contactInfo]];
    }
}

@dynamic name;
-(NSString *) name {
    return nameTextField.text;
}
-(void) setName: (NSString *)value {
    nameTextField.text = value;
}


#pragma mark - Methods

/// The designated initializer redirects to a custom init.
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

/// Just redirect to initWithNewPharmacy.
-(id) init {
    return [self initWithNewPharmacy:[[[Pharmacy alloc] init] autorelease]];
}

-(id) initForEditWithPharmacy: (Pharmacy *)existingPharm {
    self = [super initWithNibName: @"EditPharmacyView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Edit Pharmacy";
        // Dont' initialize the DataSource for the table view. It's done by the XIB.
        self.pharmacy = existingPharm;
        self.contactListDataSource = nil;
        self.pharmacyLookupDataSource = nil;
        isNewPharmacy = NO;
        maxLookupTableRows = 0;
    }
    return self;
}

-(id) initWithNewPharmacy: (Pharmacy *)newPharm {
    self = [super initWithNibName: @"EditPharmacyView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"New Pharmacy";
        // Dont' initialize the DataSource for the table view. It's done by the XIB.
        self.pharmacy = newPharm;
        isNewPharmacy = YES;
        // Show up to 3 pharmacy names in the autocomplete table.
        maxLookupTableRows = 3;
    }
    return self;
}

-(void) refreshView {
    if (self.pharmacy != nil) {
        self.name = pharmacy.name;
        
        //TODO: the rest
    }
    else {
        self.name = @"";
        
        //TODO: the rest
    }
    [contactInfoTableView reloadData];
    needsViewRefresh = NO;
}

-(void) reset {
    self.autocompleteTableView.hidden = YES;
    //TODO:
}

/// BEWARE: this code can break if the UIView structure is altered.
-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
    [self moveCurrentFieldIntoVisibleArea];
}

-(void) moveCurrentFieldIntoVisibleArea {
    // Try to scroll the control into view.
    CGRect frame = controlBeingEdited.frame;
    UIView *view = controlBeingEdited.superview;
    // Add the Y-origin of all superviews until the master UIScrollView is found.
    while (view && ([view isKindOfClass: [UITableView class]] || ![view isKindOfClass: [UIScrollView class]])) {
        frame.origin.y += view.frame.origin.y;
        view = view.superview;
    }
    [self.scrollView scrollRectToVisible:frame animated:YES];   
}

-(BOOL) validatePharmacy {
    if (self.name && [self.name length] > 0 && self.contactListDataSource.phone && [self.contactListDataSource.phone length] > 0) {
        return YES;
    }
    return NO;
}

-(void) showInvalidPharmacyAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"A new pharmacy requires a name and a phone number." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_B];
    
    // Update the font color for labels.
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: nameLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: contactLabel];   
}


#pragma mark Actions

-(IBAction) savePharmacyAction: (id)sender {
    [self dismissKeyboard];
    
    if ([self validatePharmacy]) {
        // Create pharmacy view.
        if (isNewPharmacy) {
            // The view for a new pharmacy can be for a new object or a reference to an existing one.
            Pharmacy *existing = [[ApplicationSupervisor instance] pharmacyWithIdent: pharmacy.ident];
            
            if (existing) {
                // This will get a new Contact if any values were changed, or the original otherwise.
                self.pharmacy.contactInfo = contactListDataSource.currentContact;
                // If it already exists but doesn't match exactly, create a new Pharmacy and use it.
                if (![pharmacy isEqual: existing]) {
                    // Something was changed. Give the modified Pharmacy a new Ident so that it doesn't clash with an existing Pharmacy.
                    Contact *c = pharmacy.contactInfo;
                    self.pharmacy = [[pharmacy copy] autorelease];
                    self.pharmacy.contactInfo = c;
                }
                // If it does match but isn't the same object, use the object already held in the data store.
                else if (existing != pharmacy) {
                    // Otherwise, just use the existing pharmacy so that object equality is maintained.
                    self.pharmacy = existing;
                }
            }
            else {
                [contactListDataSource applyChanges];
            }
            // Send the signal and let the observer handle the creation.
            [self sendNotification: kPharmacySavedNotification about:self];
        }
        else {
            // Edit pharmacy view.
            // Apply the changes made inside the data source.
            [contactListDataSource applyChanges];
            // Do application-wide update now.
            [[ApplicationSupervisor instance] updatePharmacy:pharmacy];
        }
        self.pharmacy = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self showInvalidPharmacyAlert];
    }
}

//-(IBAction) beginEditingTextFieldAction: (id)sender {
//    self.controlBeingEdited = (UIControl *)sender;
//}

-(IBAction) nameEditingEndAction: (id)sender {
    pharmacy.name = [(UITextField *)sender text];
}

-(IBAction) dismissKeyboardAction: (id)sender {
    [self dismissKeyboard];
}

#pragma mark View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self applyTheme];
    self.contactInfoTableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    // Set the title and right button action.
    if (isNewPharmacy) {
        // Hide the delete button
        [deletePharmacyButton setHidden: YES];
    }
    
    self.navigationItem.rightBarButtonItem = saveButton;
      
    // Size the ScrollView's scrollable area to that of the ScrollContentView.
    CGSize contentSize = scrollView.superview.frame.size;
    scrollView.contentSize = contentSize;
    
    // Set the contactListDataSource's contact reference.
    if (pharmacy) {
        // Only one Contact for now.
        [contactListDataSource addContact: pharmacy.contactInfo];
    }
    // Set the DataSource's table reference.  This also set's the table's dataSource.
    contactListDataSource.tableView = contactInfoTableView;
    // Make the contact editable
    contactListDataSource.enableEdit = YES;
    // Subscribe to data source notifications
    [self subscribeToDataSourceNotifications: YES];
}

/** viewWillAppear
 * When the view is visible, listen for keyboard notifications.
 */
-(void) viewWillAppear: (BOOL)animated {
	[super viewWillAppear:animated];
    
    if (needsViewRefresh) {
        [self refreshView];
    }
}

-(void) viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
    //[self subscribeToAppNotifications:NO];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ViewControllerBase Methods

-(void) dismissKeyboard {
    [controlBeingEdited resignFirstResponder];
    [self.contactListDataSource dismissKeyboard];
    self.controlBeingEdited = nil;
}

-(void) animateKeyboardWillShow: (NSNotification *)notification {
    // Swap the done button's action from "save" to "dismiss keyboard" function.
    self.navigationItem.rightBarButtonItem = dismissEditorButton;
    
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
    // Swap the done button's action from "dismiss keyboard" to "save" function.
    self.navigationItem.rightBarButtonItem = saveButton;
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.height += keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}


#pragma mark UITextFieldDelegate Methods

/// textFieldShouldReturn
///
-(BOOL) textFieldShouldReturn: (UITextField *)textField {
    if (textField == nameTextField) {
        // Jump to the next text field.
        [contactListDataSource selectTextFieldInRow: 0];
        return NO;
    }
    return YES;
}

/// textFieldDidBeginEditing
///
-(void) textFieldDidBeginEditing: (UITextField *)textField {
    self.controlBeingEdited = textField;
}

/// textFieldDidEndEditing
///
/// Handles when a TextField is done being edited.  The new text value is entered into the data source
/// at the appropriate location.
-(void) textFieldDidEndEditing: (UITextField *)tf {
    self.autocompleteTableView.hidden = YES;
    
    // If the Patient text field is done editing, forward the message on to the PharmacyLookupDataSource.
    if (tf == self.nameTextField) {
        // Create a new pharmacy if none was selected.
        if (![tf.text isEqualToString:@""] && self.pharmacyLookupDataSource.selectedPharmacy == nil) {
            self.autocompleteTableView.hidden = YES;
            // Modify the existing pharmacy's name, which will cause a new copy to be saved later.
            //pharmacy.name = tf.text;
//            Pharmacy *newPharm = [[Pharmacy alloc] init];
//            self.pharmacyLookupDataSource.selectedPharmacy = newPharm;
//            [newPharm release];
//            newPharm.name = tf.text;
//            self.isNewPharmacy = YES;
        }
    }
    controlBeingEdited = nil;
}

-(BOOL) textFieldShouldClear: (UITextField *)tf {
    if (tf == self.nameTextField) {
        self.autocompleteTableView.hidden = YES;
        [self.pharmacyLookupDataSource reset];
    }
    return YES;
}

///
-(BOOL) textField: (UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)str {
    // If the Patient text field is changing, forward the message on to the PatientLookupTableDataSource.
    if (tf == self.nameTextField) {
        // If this is an existing Pharmacy, let the name change but don't use the LookupTableView.
        if (!self.isNewPharmacy) {
            return YES;
        }
        
        // Forward the UI message on to the Data Source.
        [self.pharmacyLookupDataSource textField:tf shouldChangeCharactersInRange:range replacementString:str];
        
        // Change table visibility based on its contents
        if (self.pharmacyLookupDataSource.numberOfRows > 0) {
            self.autocompleteTableView.hidden = NO;
            // Reload the table since the data should have changed.
            [self.autocompleteTableView reloadData];
            
            // Resize the autocomplete table.
            NSInteger numRows = self.pharmacyLookupDataSource.numberOfRows;
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



#pragma mark Memory Management

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [self subscribeToDataSourceNotifications: NO];
    self.pharmacy = nil;
    self.parentView = nil;
    self.contactListDataSource = nil;
    self.pharmacyLookupDataSource = nil;
    self.contactListDataSource = nil;
    self.controlBeingEdited = nil;
    self.autocompleteTableView = nil;
    [saveButton release];
    [dismissEditorButton release];
    [scrollView release];
    [scrollContentView release];
    [deletePharmacyButton release];
    [nameTextField release];
    [contactInfoTableView release];
    [contactLabel release];
    [nameLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //TODO:
}


#pragma mark Event Handling

/// observeValueForKeyPath
/// Handle changes to Property values.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == contactListDataSource) {
        if ([keyPath isEqualToString: fieldBeingEditedKey]) {
            self.controlBeingEdited = contactListDataSource.fieldBeingEdited;
            if (contactListDataSource.fieldBeingEdited) {
                // move field into view
                [self moveCurrentFieldIntoVisibleArea];
            }
        }
    }
    else if (object == pharmacyLookupDataSource) {
        if ([keyPath isEqualToString: selectedItemKey] && self.pharmacyLookupDataSource.selectedPharmacy) {
            self.autocompleteTableView.hidden = YES;
            // Get a copy of the selected Pharmacy so that changes won't affect the original.  Then a
            // property-by-property value comparison can be done at save time.
            self.pharmacy = self.pharmacyLookupDataSource.selectedPharmacy;
            //self.isNewPharmacy = NO;
            // Don't call refresh because it will erase the name.  Just update the table data.
            [contactInfoTableView reloadData];
            needsViewRefresh = NO;
        }
        else if ([keyPath isEqualToString: useExistingItemKey]) {
            //self.isNewPharmacy = !self.pharmacyLookupDataSource.useExistingItem;
        }
    }
}

-(void) addPharmacySavedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPharmacySavedNotification object:self];
}

-(void) removePharmacySavedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPharmacySavedNotification object:self];
}

-(void) addPharmacyReferencedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPharmacyReferencedNotification object:self];
}

-(void) removePharmacyReferencedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPharmacyReferencedNotification object:self];
}

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

///
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo {
    if (yesNo) {
        [self.contactListDataSource addPropertyChangeObserver: self];
        [self.pharmacyLookupDataSource addPropertyChangeObserver:self];
    }
    else {
        [self.contactListDataSource removePropertyChangeObserver: self];
        [self.pharmacyLookupDataSource removePropertyChangeObserver:self];
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

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
