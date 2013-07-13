//
//  PatientListViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "PatientListViewController.h"

@interface PatientListViewController ()

@property (nonatomic, retain) UINavigationController *newPatientNavController;

-(void) reset;

-(void) handlePatientCreated: (NSNotification *)notification;

-(void) handlePatientUpdated: (NSNotification *)notification;

-(void) handlePatientDeleted: (NSNotification *)notification;

-(void) subscribeToAppNotifications: (BOOL)yesNo;

-(void) subscribeToDataSourceNotifications: (BOOL)yesNo;

@end


@implementation PatientListViewController


@synthesize listDataSource;
-(void) setListDataSource:(PatientsByNameDataSource *)value {
    if (value == listDataSource) {
        return;
    }
    [self subscribeToDataSourceNotifications:NO];
    [listDataSource autorelease];
    listDataSource = [value retain];
    [self subscribeToDataSourceNotifications:YES];
}

@synthesize newPatientViewController;
@synthesize newPatientNavController;
@synthesize patientViewController;
@synthesize selectedFirstName;
@synthesize searchBar;
@synthesize tableView;
@synthesize selectedLastName;


#pragma mark - Methods

// The designated initializer redirects to init.
-(id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    return [self init];
}

-(id) init {
    self = [super initWithNibName: @"PatientListView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"My Patients";
        wasViewPopped = NO;
        // The data source is allocated in the XIB.
    }
    return self;
}

-(void) reset {
    // Clear out the search bar.
    self.listDataSource.searchPhrase = nil;
    self.searchBar.text = nil;
}

//-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context {    
//    
//}


#pragma mark Actions

-(IBAction) addPatientAction: (id)sender {
    if (newPatientNavController == nil) {
        UINavigationController *npc = [[UINavigationController alloc] init];
        self.newPatientNavController = npc;
        [npc release];
    }
    
    if (newPatientViewController == nil) {
        EditPatientViewController *epvc = [[EditPatientViewController alloc] init];
        self.newPatientViewController = epvc;
        [epvc release];
        self.newPatientViewController.parentView = self;
    }
    else {
        Patient *p = [[Patient alloc] init];
        self.newPatientViewController.patient = p;
        [p release];
    }
    
    [newPatientNavController pushViewController: newPatientViewController animated: NO];
    [self.navigationController presentModalViewController: newPatientNavController animated:YES];
}


#pragma mark UIViewController Methods
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 -(void) loadView {
 }
 */

/**
 Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
-(void) viewDidLoad {
    [super viewDidLoad];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    // Is there a better way do disable the section index?
    tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
    
    // Change the search bar keyboard to enable the 'Done' button at all times.
    for (UIView *subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            // Always force 'Done' key to be enabled.
            [(UITextField *)subview setEnablesReturnKeyAutomatically:NO];
            // Set the return type as 'Done'.
            [(UITextField *)subview setReturnKeyType: UIReturnKeyDone];
            // Turn off autocorrect.
            [(UITextField *)subview setAutocorrectionType: UITextAutocorrectionTypeNo];
        }
    }
    
    // Add our custom add button as the nav bar's custom right view
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd 
                                                                               target: self
                                                                               action: @selector(addPatientAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    // Set the tableView's data source to this controller's PatientsByNameDataSource.
    listDataSource.tableView = tableView;
    
    // Subscriptions are okay now since the data sources are set up.
    [self subscribeToAppNotifications: YES];
}

-(void) viewWillAppear: (BOOL)animated {
    [super viewWillAppear:animated];
    
    // Clear out the selected name references.
    self.selectedFirstName = nil;
    self.selectedLastName = nil;
    // De-select any selected table rows.
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    
    // Dismiss the keyboard.
    [self dismissKeyboard];
    
    if ([self.navigationController topViewController] != patientViewController
        && [self.navigationController topViewController] != newPatientNavController
        && [self.navigationController topViewController] != newPatientViewController
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear:animated];
        
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark ViewControllerBase Methods

-(void) dismissKeyboard {
    [searchBar resignFirstResponder];
}

-(void) animateKeyboardWillShow: (NSNotification *)notification {
    // Swap the done button's action from "done" to "dismiss keyboard" function.
    //self.navigationItem.rightBarButtonItem.action = @selector(dismissKeyboard);
    
    // Resize scrollView for keyboard.
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = tableView.frame;
    scrollFrame.size.height -= keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:animationDuration];
    // Set the completion handler to scroll the field into view.
    //[UIView setAnimationDidStopSelector: @selector(keyboardResizeDidFinish:finished:context:)];
    tableView.frame = scrollFrame;
    [UIView commitAnimations];
}

-(void) animateKeyboardWillHide: (NSNotification *)notification {
    // Swap the done button's action from "dismiss keyboard" to "done" function.
    //self.navigationItem.rightBarButtonItem = nil;
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = tableView.frame;
    scrollFrame.size.height += keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    tableView.frame = scrollFrame;
    [UIView commitAnimations];
}

/// viewWasPopped
///
-(void) viewWasPopped {
    //TODO: Consider clearing out the subviews like PatientView, EditPatientView
    [self reset];
    
    // Scroll to top
    [self.tableView setContentOffset: CGPointMake(0.0, 0.0)];
}


#pragma mark Memory Management

-(void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
}

-(void) viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
//    [newPatientNavController release];
//    newPatientNavController = nil;
//    self.patientViewController = nil;
//    self.newPatientViewController = nil;
}

-(void) dealloc {
    [self subscribeToAppNotifications: NO];
    
    self.newPatientNavController = nil;
    self.listDataSource = nil;
    self.patientViewController = nil;
    self.newPatientViewController = nil;
    self.selectedFirstName = nil;
    self.selectedLastName = nil;
    self.searchBar = nil;
    self.tableView = nil;
    [super dealloc];
}


#pragma mark UITableViewDelegate

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    Patient *selectedPatient = [self.listDataSource getPatientForPath: indexPath];
    if (self.patientViewController == nil) {
        PatientViewController *pvc = [[PatientViewController alloc] initWithPatient: selectedPatient];
        self.patientViewController = pvc;
        pvc.parentView = self;
        [pvc release];
    }
    else {
        self.patientViewController.patient = selectedPatient;
    }
    // Keep references to the selected patient's name, in case it changes via editing.
    self.selectedFirstName = selectedPatient.firstName;
    self.selectedLastName = selectedPatient.lastName;
    [self.navigationController pushViewController: self.patientViewController animated:YES];
}


#pragma mark ParentViewDelegate Methods

-(void) dismissChildView: (UIViewController *)child {
    // If the temporary NavigationController exists, dispose of it to make room for a new one.
    if (newPatientNavController) {
        [newPatientNavController release];
        newPatientNavController = nil;
    }
    [newPatientViewController setViewWasPopped];
    [self.navigationController dismissModalViewControllerAnimated: YES];
}

-(void) childViewWillDisappear: (UIViewController *)child {
    // nothing.
}


#pragma mark Event Handling

-(void) handlePatientCreated: (NSNotification *)notification {
    Patient *p = [notification object];
    // This will also reload the table data if necessary.
    [self.listDataSource addPatient: p];
}

/// This is now handled by PatientListDataSource<==PatientTableViewCell<==Patient notifications.
///TODO: VERIFY THIS CAN BE REMOVED.
-(void) handlePatientUpdated: (NSNotification *)notification {
    Patient *p = [notification object];
    
    // If either the first or last name has changed, this view's dataSource needs to be updated too.
    if ([p.firstName caseInsensitiveCompare:self.selectedFirstName] != 0 || [p.lastName caseInsensitiveCompare:self.selectedLastName] != 0) {
        // This will also reload the table data if necessary.
        [self.listDataSource updatePatient:p fromOldFirstName:self.selectedFirstName andLastName:self.selectedLastName];
    }
}

-(void) handlePatientDeleted: (NSNotification *)notification {
    Patient *p = [notification object];
    // This will also reload the table data if necessary.
    [self.listDataSource removePatient: p];
}

///
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:sortByLastNamePropertyKey]) {
        [tableView reloadData];
    }
}

-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addPatientCreatedObserver:self withHandler:@selector(handlePatientCreated:)];
        //[[ApplicationSupervisor instance] addPatientUpdatedObserver:self withHandler:@selector(handlePatientUpdated:)];
        [[ApplicationSupervisor instance] addPatientDeletedObserver:self withHandler:@selector(handlePatientDeleted:)];
    }
    else {
        [[ApplicationSupervisor instance] removePatientCreatedObserver:self];
        //[[ApplicationSupervisor instance] removePatientUpdatedObserver:self];
        [[ApplicationSupervisor instance] removePatientDeletedObserver:self];
    }
}

///
-(void) subscribeToDataSourceNotifications: (BOOL)yesNo {
    if (listDataSource) {
        if (yesNo) {
            [listDataSource addPropertyChangeObserver:self];
        }
        else {
            [listDataSource removePropertyChangeObserver:self];
        }
    }
}

@end
