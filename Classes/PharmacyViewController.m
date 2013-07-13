//
//  PharmacyViewController.m
//  Curbside
//
//  Created by Greg Walker on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PharmacyViewController.h"
#import "ApplicationSupervisor.h"
#import "Constants.h"
#import "ContactListDataSource.h"
#import "EditPharmacyViewController.h"
#import "Pharmacy.h"


@interface PharmacyViewController ()

-(void) applyTheme;
-(void) reset;

-(void) viewWasPopped;

-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end


@implementation PharmacyViewController

#pragma mark - Properties

@synthesize parentView;
@synthesize nameTextField;
@synthesize contactInfoTableView;
@synthesize editPharmacyView;
@synthesize contactsDataSource;
@synthesize editPharmacyButton;
@synthesize nameLabel;
@synthesize contactLabel;

@synthesize pharmacy;
-(void) setPharmacy: (Pharmacy *)value {
    if (value == pharmacy) {
        return;
    }
    [pharmacy autorelease];
    pharmacy = [value retain];
    needsViewRefresh = YES;
    
    if (pharmacy && contactsDataSource) {
        // Update the pharmacy's ContactListDataSource. Only one Contact for now.
        [contactsDataSource populateContacts: [NSArray arrayWithObject: pharmacy.contactInfo]];
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
    self = [super initWithNibName: @"PharmacyView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Pharmacy";
    }
    return self;
}

-(id) initWithPharmacy: (Pharmacy *)existingPharm {
    self = [self init];
    if (self) {
        // Dont' initialize the DataSource for the table view. It's done by the XIB.
        self.pharmacy = existingPharm;
    }
    return self;
}

-(void) refreshView {
    if (self.pharmacy != nil) {
        self.name = pharmacy.name;
    }
    else {
        [self reset];
    }
    [contactsDataSource reloadTableData];
    needsViewRefresh = NO;
}

-(void) reset {
    self.name = @"";
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_D];
    
    // Update the font color for labels.
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: nameLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: contactLabel];
}

#pragma mark Actions

-(IBAction) editPharmacyAction: (id)sender {
    if (self.editPharmacyView == nil) {
        EditPharmacyViewController *epvc = [[EditPharmacyViewController alloc] initForEditWithPharmacy: pharmacy];
        self.editPharmacyView = epvc;
        [epvc release];
        // This will allow the child views to pop to this view when necessary.
        //TODO: check if this is used, remove if not.
        //self.editPharmacyView.parentView = self;
    }
    else {
        self.editPharmacyView.pharmacy = pharmacy;
    }
    
    [self.navigationController pushViewController: self.editPharmacyView animated: YES];
}


#pragma mark View lifecycle

-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self applyTheme];
    self.contactInfoTableView.backgroundColor = [UIColor clearColor];
    [self subscribeToAppNotifications:YES];
    
    // put the edit button in place.
    self.navigationItem.rightBarButtonItem = editPharmacyButton;
    
    // Set the ContactListDataSource's contact reference.
    if (pharmacy) {
        [contactsDataSource addContact: pharmacy.contactInfo];
    }
    // Set the DataSource's table reference.  This also set's the table's dataSource.
    contactsDataSource.tableView = contactInfoTableView;
    // Make the contact uneditable.
    contactsDataSource.enableEdit = NO;
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

/// viewWasPopped
///
-(void) viewWasPopped {
    [self reset];
    
    needsViewRefresh = YES;
}

-(void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self subscribeToAppNotifications:NO];
    // e.g. self.myOutlet = nil;
    //TODO:
}

/// viewDidDisappear
///
-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    
    // For now, view was popped everytime the view disappears.
    if ([self.navigationController topViewController] != self) {
        wasViewPopped = YES;
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Memory Management

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    self.pharmacy = nil;
    self.parentView = nil;
    self.editPharmacyView = nil;
    self.contactsDataSource = nil;
    self.editPharmacyButton = nil;
    [nameTextField release];
    [contactInfoTableView release];
    [nameLabel release];
    [contactLabel release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //TODO:
}


#pragma mark Event Handling

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

-(void) handlePharmacyUpdated: (NSNotification *)n {
    if ([n object] == pharmacy) {
        // The displayed pharmacy was updated, so refresh the view.
        [self refreshView];
    }
}

-(void) handlePharmacyDeleted: (NSNotification *)n {
    if ([n object] == pharmacy) {
        // The displayed pharmacy was deleted, so reset and pop to parent view.
        [self reset];
        if (self.parentView && self.navigationController) {
            // Not sure what will happen if this view has already been popped by the user.  Just wrap in Try/Catch incase.
            @try {
                // Need to dismiss this view (or any child).
                [self.navigationController popToViewController: (UIViewController *)self.parentView animated:YES];
            }
            @catch (NSException *ex) {
                // Nothing needed.
            }
        }
    }
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addThemeSettingChangedObserver: self withHandler:@selector(handleThemeChanged:)];
        [[ApplicationSupervisor instance] addPharmacyUpdatedObserver: self withHandler:@selector(handlePharmacyUpdated:)];
        [[ApplicationSupervisor instance] addPharmacyDeletedObserver: self withHandler:@selector(handlePharmacyDeleted:)];
    }
    else {
        [[ApplicationSupervisor instance] removeThemeSettingChangedObserver: self];
        [[ApplicationSupervisor instance] removePharmacyUpdatedObserver: self];
        [[ApplicationSupervisor instance] removePharmacyDeletedObserver: self];
    }
}

@end