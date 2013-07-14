    //
//  MoreViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MoreViewController.h"
#import "AboutViewController.h"
#import "UsageTipsViewController.h"
#import "ArchiveListViewController.h"
#import "Constants.h"
#import "FileArchiveResult.h"


@interface MoreViewController ()

-(void) applyTheme;
-(void) emailDataArchive: (FileArchiveResult *)archiveResult;
-(void) showBackupDialog;
-(void) showBackupSavedAlert;
-(void) showBackupFailedAlert;
-(void) showImportCompleteAlert;
-(void) showImportFailedAlert;
-(void) showEmailNotPermittedAlert;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@property (nonatomic, retain) FileArchiveResult *archiveResult;

@end


@implementation MoreViewController

@synthesize archiveResult;

#pragma mark - Methods

// The designated initializer redirects to a custom init.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (id)init {
    self = [super initWithNibName: @"MoreView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"More";
        appSettingsView = nil;
    }
    return self;
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_D];
    // Set the logo imagel
    [[ApplicationSupervisor instance].themeManager applyThemeToLogoImage: logoImage];
    
    // Set the button label colors.
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: aboutButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: usageButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: exportButton];
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: importButton];
    //[[ApplicationSupervisor instance].themeManager applyThemeToButton: medicationsButton];
}

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [aboutView release];
    aboutView = nil;
    [usageView release];
    usageView = nil;
    [appSettingsView release];
    appSettingsView = nil;
    [archiveFileListView release];
    archiveFileListView = nil;
    self.archiveResult = nil;
    [super dealloc];
}

-(void) emailDataArchive: (FileArchiveResult *)result {
    if ([MFMailComposeViewController canSendMail]) {
        @try {
            MFMailComposeViewController *exportMailer = [[MFMailComposeViewController alloc] init];
            exportMailer.mailComposeDelegate = self;
            NSString *emailAddr = [ApplicationSupervisor instance].userEmailAddressSetting;
            if (emailAddr && [emailAddr length] > 0) {
                // Configure message using the user-defined destination email address.
                [exportMailer setToRecipients: [NSArray arrayWithObject: emailAddr]];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: kDateTimeAmPmFormatterFormat];
            NSString *subject = [NSString stringWithFormat: @"%@%@", kExportSubjectPrefix, [formatter stringFromDate: result.creationDate]];
            [formatter release];
            // Attach the archive as an Curbside data file.
            [exportMailer addAttachmentData: result.archiveData mimeType: kCurbsideMimeType fileName: result.fileName];
            [exportMailer setSubject: subject];
            [exportMailer setMessageBody: @"" isHTML: NO];
            [self presentModalViewController: exportMailer animated: YES];
            [exportMailer release];
        }
        @catch (NSException *ex) {
            NSLog(@"Open Email Failed: %@", ex);
        }
    }
    else {
        [self showEmailNotPermittedAlert];
    }
}


#pragma mark - Alerts
-(void) showBackupDialog {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Backup Option" 
                                                    message: @"Send a copy of the backup by email?"
                                                   delegate: self 
                                          cancelButtonTitle: @"No"
                                          otherButtonTitles: @"Yes", nil];
    [alert show];
    [alert release];
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

-(void) showBackupSavedAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Success!"
                                                        message: @"A backup was saved in Curbside's shared folder.  Use iTunes to move it to a safe location."
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void) showBackupFailedAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Backup Failed"
                                                        message: @"Curbside failed to archive its data.  Please send a bug report to the developer."
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void) showImportCompleteAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Success!"
                                                        message: @"Curbside successfully imported data from an archive file."
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void) showImportFailedAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Data Import Failed"
                                                        message: @"Curbside failed to import a data archive.  Please send a bug report to the developer."
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}


#pragma mark Actions

-(IBAction) showAboutViewAction: (id) sender {
    if (!aboutView) {
        // The view controller has not been created yet.
        aboutView = [[AboutViewController alloc] init];
    }
    [self.navigationController pushViewController: aboutView animated:YES];
}

-(IBAction) showUsageViewAction: (id) sender {
    if (!usageView) {
        // The view controller has not been created yet.
        usageView = [[UsageTipsViewController alloc] init];
    }
    [self.navigationController pushViewController: usageView animated:YES];
}

-(IBAction) showMedicationsViewAction: (id) sender {
//    if (!aboutViewController) {
//        // The view controller has not been created yet.
//        aboutViewController = [[AboutViewController alloc] init];
//    }
//    [self.navigationController pushViewController: aboutViewController animated:YES];
}

-(IBAction) showArchiveListViewAction: (id)sender {
    if (!archiveFileListView) {
        // The view controller has not been created yet.
        archiveFileListView = [[ArchiveListViewController alloc] init];
        archiveFileListView.parentView = (id<ParentViewDelegate>)self;
    }
    [self.navigationController pushViewController: archiveFileListView animated:YES];
}

-(IBAction) showSettingsModalAction: (id)sender {
    if (!appSettingsView) {
		appSettingsView = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsView.delegate = self;
        appSettingsView.title = @"Curbside Settings";
    }
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController: appSettingsView];
    //[appSettingsView setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    appSettingsView.showDoneButton = YES;
    [self presentModalViewController: aNavController animated: YES];
    [aNavController release];
}

-(IBAction) archiveDataAction: (id)sender {
    BOOL success = YES;
    // Show the view overlay to suppress user actions.
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow insertSubview: overlayView aboveSubview: mainWindow];
    [mainWindow layoutSubviews];
    @try {
        self.archiveResult = [[ApplicationSupervisor instance] archiveCurbsideData];
        success = (archiveResult != nil);
    }
    @catch (NSException *ex) {
        success = NO;
    }
    // Archival is done, remove the overlay.
    [overlayView removeFromSuperview];
    [mainWindow layoutSubviews];
    
    if (success) {
        [self showBackupDialog];
    }
    else {
        // backup failed
        [self showBackupFailedAlert];
    }
}


#pragma mark IASKSettingsDelegate methods

-(void) settingsViewControllerDidEnd: (IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated: YES];
}


#pragma mark UIViewController methods

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self applyTheme];
    [self subscribeToAppNotifications:YES];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [buttonItem release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
//    [aboutView release];
//    aboutView = nil;
//    [usageView release];
//    usageView = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //TODO:
    // Release any retained subviews of the main view.
//    [self subscribeToAppNotifications:NO];
//    [aboutView release];
//    aboutView = nil;
//    [usageView release];
//    usageView = nil;
}

-(void) dismissChildView: (UIViewController *)child {
    if (child == archiveFileListView || child == aboutView || child == usageView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark MFMailComposeViewControllerDelegate Methods

-(void) mailComposeController: (MFMailComposeViewController*)mailer  
          didFinishWithResult: (MFMailComposeResult)result 
                        error: (NSError *)error {
    if (result == MFMailComposeResultFailed) {
        NSLog(@"Failed to send data archive via email.");
    }
    
    [self dismissModalViewControllerAnimated: NO];
}


#pragma mark UIAlertViewDelegate Methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (archiveResult) {
        // Only email the data archive if the Yes button was clicked.
        if (alertView.cancelButtonIndex != buttonIndex) {
            [self emailDataArchive: archiveResult];
        }
        else {
            [[ApplicationSupervisor instance] saveArchiveToDisk: archiveResult];
            [self showBackupSavedAlert];
        }
        self.archiveResult = nil;
    }
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
