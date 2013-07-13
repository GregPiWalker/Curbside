//
//  AboutViewController.m
//  CurbSide
//
//  Created by Greg Walker on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "Constants.h"

@interface AboutViewController ()

-(NSString *) buildMessageBody;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end

@implementation AboutViewController

@synthesize feedbackButton;
@synthesize versionLabel;
@synthesize versionNumberLabel;
@synthesize curbLogoLabel;
@synthesize sideLogoLabel;
@synthesize aboutTextView;
@synthesize logoImage;

-(id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    return [self init];
}

-(id) init {
    self = [super initWithNibName: @"AboutView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"About";
    }
    return self;
}

#pragma mark Actions

-(IBAction) sendFeedbackAction: (id) sender {
    @try {
        MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init]; 
        if (mailer) {
            mailer.mailComposeDelegate = self;
            [mailer setToRecipients: [NSArray arrayWithObject:feedbackRecipientAddress]];
            [mailer setSubject:@"Curbside User Feedback"];
            [mailer setMessageBody:[self buildMessageBody] isHTML:NO];
            [self presentModalViewController:mailer animated:YES];
        }
        [mailer release];
    }
    @catch (NSException *ex) {
        NSLog(@"Open Email Failed: %@", ex); 
    }
}

#pragma mark - Methods

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_C];
    
    // Set the button label color and background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToButton: feedbackButton];
    // Set the logo imagel
    [[ApplicationSupervisor instance].themeManager applyThemeToLogoImage: logoImage];
    
    aboutTextView.textColor = [ApplicationSupervisor instance].themeManager.labelFontColor;
    
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: versionLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: versionNumberLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: curbLogoLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: sideLogoLabel];
}

-(NSString *) buildMessageBody {
    NSString *body = [NSString stringWithFormat:@"System Name:  %@\n", [[UIDevice currentDevice] systemName]];
    body = [NSString stringWithFormat:@"%@System Version:  %@\n", body, [[UIDevice currentDevice] systemVersion]];
    body = [NSString stringWithFormat:@"%@Device Model:  %@\n", body, [[UIDevice currentDevice] model]];
    body = [NSString stringWithFormat:@"%@CurbSide Version:  %@\n\n", body, [[ApplicationSupervisor instance] releaseVersionString]];
    return body;
}

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    [feedbackButton release];
    [versionLabel release];
    [versionNumberLabel release];
    [curbLogoLabel release];
    [sideLogoLabel release];
    [aboutTextView release];
    [logoImage release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //TODO:
}

#pragma mark View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    versionNumberLabel.text = [ApplicationSupervisor instance].releaseVersionString;
    
    [self applyTheme];
    [self subscribeToAppNotifications:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
    //[self subscribeToAppNotifications:NO];
}


#pragma mark MFMailComposeViewControllerDelegate Methods

-(void) mailComposeController: (MFMailComposeViewController*)mailer  
          didFinishWithResult: (MFMailComposeResult)result 
                        error: (NSError *)error {
    if (result == MFMailComposeErrorCodeSendFailed) {
        NSLog(@"Error: Failed to send a user-feedback email.");
    }
    [self dismissModalViewControllerAnimated:YES];
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
