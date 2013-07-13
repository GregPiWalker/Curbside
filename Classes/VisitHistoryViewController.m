    //
//  VisitHistoryViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "VisitHistoryViewController.h"
#import "Visit.h"
#import "Patient.h"

@interface VisitHistoryViewController ()

-(void) handleVisitCreated: (NSNotification *)notification;

-(void) handleVisitDeleted: (NSNotification *)notification;

-(void) subscribeToNotifications: (BOOL)yesNo;

-(void) viewWasPopped;

-(void) dismissKeyboard;

@end


@implementation VisitHistoryViewController

@synthesize visitViewController;
@synthesize searchBar;

#pragma mark - Methods

// The default initializer redirects to a custom init.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

/// The designated initializer.
-(id) initWithHistory: (NSArray *)visitHistory {
    self = [super initWithNibName: @"VisitHistoryView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Visit Log";
        historyDataSource = [[VisitHistoryDataSource alloc] initWithHistory:visitHistory];
        // Subscribe last, after data sources are set up.
        [self subscribeToNotifications: YES];
    }
    return self;
}


#pragma mark ViewControllerBase Methods

-(void) dismissKeyboard {
    [searchBar resignFirstResponder];
}

-(void) animateKeyboardWillShow: (NSNotification *)notification {
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
    // Scroll to top
    [self.tableView setContentOffset: CGPointMake(0.0, 0.0)];
}


#pragma mark UIViewController Methods

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void) viewDidLoad {
    [super viewDidLoad];
 
    // Set the TableView's data source.
    self.historyDataSource.tableView = self.tableView;
    // Enable cell deletion.
    self.historyDataSource.isEditable = YES;
    self.searchBar.delegate = (VisitHistoryDataSource *)self.historyDataSource;
    
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
    
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    
    // Dismiss the keyboard.
    [self dismissKeyboard];
    
    if ([self.navigationController topViewController] != visitViewController
        && [self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear: animated];
    
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
    // e.g. self.myOutlet = nil;
    //TODO:
}

///
- (void)dealloc {
    [self subscribeToNotifications: NO];
    
    self.visitViewController = nil;
    self.searchBar = nil;
    [super dealloc];
}

#pragma mark UITableViewDelegate

-(void) tableView: (UITableView *)tv didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    VisitHistoryDataSource *visitDataSource = (VisitHistoryDataSource *)self.historyDataSource;
    Visit *selectedVisit = [visitDataSource getVisitForTableView:tv atIndexPath:indexPath];
    if (!visitViewController) {
        // The view controller has not been created yet.
        VisitViewController *vvc = [[VisitViewController alloc] initWithVisit:selectedVisit];
        self.visitViewController = vvc;
        [vvc release];
        // This lets child views pop to this view if necessary.
        self.visitViewController.parentView = self;
    }
    else {
        self.visitViewController.visit = selectedVisit;
    }
    [self.navigationController pushViewController:visitViewController animated:YES];
}

-(UITableViewCellEditingStyle) tableView: (UITableView *)tv editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark Event Handling

-(void) handleVisitCreated: (NSNotification *)notification {
    Visit *v = [notification object];
    [self.historyDataSource addHistoryItem: v];
    [self.historyDataSource reloadTableData];
}

// This is now handled in the VisitHistoryDataSource.
-(void) handleVisitUpdated: (NSNotification *)notification {
//    Visit *v = [notification object];
//    // Remove the visit and then add it again so that it is sorted and sectioned.
//    [self.historyDataSource removeHistoryItem: v];
//    [self.historyDataSource addHistoryItem: v];
//    [self.tableView reloadData];
}

-(void) handleVisitDeleted: (NSNotification *)notification {
    Visit *v = [notification object];
    [self.historyDataSource removeHistoryItem: v];
    [self.historyDataSource reloadTableData];
}

-(void) handlePatientUpdated: (NSNotification *)notification {
    // Just reload the table.  
    // TODO: Maybe later it can be more efficient, since this method is
    // called for all patient changes, but this only cares about first and last name.
    [self.tableView reloadData];
}

-(void) subscribeToNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addVisitCreatedObserver:self withHandler:@selector(handleVisitCreated:)];
        [[ApplicationSupervisor instance] addVisitDeletedObserver:self withHandler:@selector(handleVisitDeleted:)];
        //[[ApplicationSupervisor instance] addVisitUpdatedObserver:self withHandler:@selector(handleVisitUpdated:)];
        [[ApplicationSupervisor instance] addPatientUpdatedObserver:self withHandler:@selector(handlePatientUpdated:)];
    }
    else {
        [[ApplicationSupervisor instance] removeVisitCreatedObserver:self];
        [[ApplicationSupervisor instance] removeVisitDeletedObserver:self];
        //[[ApplicationSupervisor instance] removeVisitUpdatedObserver:self];
        [[ApplicationSupervisor instance] removePatientUpdatedObserver:self];
    }
}

@end
