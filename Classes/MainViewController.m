//
//  MainViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/6/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"


static NSString *const scrubsThemeMenuItemTitle = @"Scrubs Theme";
static NSString *const leatherThemeMenuItemTitle = @"Leather Theme";
static NSString *const woodThemeMenuItemTitle = @"Wood Theme";


@interface MainViewController ()
-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;
@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

// The designated initializer.  
- (id)init {
    self = [super initWithNibName: @"MainView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Curb Side";
    }
    return self;
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_A];
    // Set the logo imagel
    [[ApplicationSupervisor instance].themeManager applyThemeToLogoImage: logoImage];
    // Set the button label colors and background images.
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: visitButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: patientsButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: visitsButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: moreButton];
}

#pragma mark MainView Actions

-(IBAction) newVisitPressed: (id) sender
{
    if (!newVisitViewController) {
        // The view controller has not been created yet.
        newVisitViewController = [[EditVisitViewController alloc] init];
    }
    [self.navigationController pushViewController: newVisitViewController animated:YES];
}

-(IBAction) patientListPressed: (id) sender
{
    if (!patientListViewController) {
        // The view controller has not been created yet.
        patientListViewController = [[PatientListViewController alloc] init];
    }
    [self.navigationController pushViewController: patientListViewController animated:YES];
}

-(IBAction) visitHistoryPressed: (id) sender
{
    if (!visitHistoryViewController) {
        // The view controller has not been created yet.
        visitHistoryViewController = [[VisitHistoryViewController alloc] initWithHistory:[[ApplicationSupervisor instance] visits]];
    }
    [self.navigationController pushViewController: visitHistoryViewController animated:YES];
}

//-(IBAction) rxHistoryPressed: (id) sender
//{
//    if (!rxHistoryViewController) {
//        // The view controller has not been created yet.
//        rxHistoryViewController = [[RxHistoryViewController alloc] init];
//    }
//    [self.navigationController pushViewController: rxHistoryViewController animated:YES];
//}

-(IBAction) morePressed: (id) sender
{
    if (!moreViewController) {
        // The view controller has not been created yet.
        moreViewController = [[MoreViewController alloc] init];
    }
    [self.navigationController pushViewController: moreViewController animated:YES];
}

#pragma mark UIViewController Members

-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self subscribeToAppNotifications:YES];
    
    [self applyTheme];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
 */

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

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
//    [rxHistoryViewController release];
//    rxHistoryViewController = nil;
//    [visitHistoryViewController release];
//    visitHistoryViewController = nil;
//    [newVisitViewController release];
//    newVisitViewController = nil;
//    [patientListViewController release];
//    patientListViewController = nil;
//    [moreViewController release];
//    moreViewController = nil;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //TODO:
//    [self subscribeToAppNotifications:NO];
//    [rxHistoryViewController release];
//    rxHistoryViewController = nil;
//    [visitHistoryViewController release];
//    visitHistoryViewController = nil;
//    [newVisitViewController release];
//    newVisitViewController = nil;
//    [patientListViewController release];
//    patientListViewController = nil;
//    [moreViewController release];
//    moreViewController = nil;
}

-(void) dealloc {
    NSLog(@"Dealloc in class %@", [self class]);
    [self subscribeToAppNotifications:NO];
//    [rxHistoryViewController release];
//    rxHistoryViewController = nil;
    [visitHistoryViewController release];
    visitHistoryViewController = nil;
    [newVisitViewController release];
    newVisitViewController = nil;
    [patientListViewController release];
    patientListViewController = nil;
    [moreViewController release];
    moreViewController = nil;
    [super dealloc];
}


#pragma mark UINavigationControllerDelegate Methods

-(void) navigationController: (UINavigationController *)navController willShowViewController: (UIViewController *)viewController animated: (BOOL)animated {
    if ([viewController isKindOfClass: [MainViewController class]]) {
        // Only the main view hides the navigation bar.
        [self.navigationController setNavigationBarHidden: YES animated: YES];
    }
    else {
        [self.navigationController setNavigationBarHidden: NO animated: YES];
    }
    
//    if ([self.navigationController.topViewController isKindOfClass: [EditPatientViewController class]])
//    {
//        EditPatientViewController *editView = (EditPatientViewController *)self.navigationController.topViewController;
//        // Need to set a 'Done' button for editing an existing patient.
//        if (!editView.isNewPatient) {
//            self.navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
//                                                                                                          target: editView
//                                                                                                          action: @selector(updatePatientAction:)];
//        }
//    }
}

-(void) navigationController:(UINavigationController *)navController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    previousViewController = viewController;
}


#pragma mark Event Handling

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
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
