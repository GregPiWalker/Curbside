//
//  MoreViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "IASKAppSettingsViewController.h"

@class AboutViewController;
@class UsageTipsViewController;
@class FileArchiveResult;


@interface MoreViewController : UIViewController<MFMailComposeViewControllerDelegate, UIAlertViewDelegate, IASKSettingsDelegate> {
    @private
    AboutViewController *aboutView;
    UsageTipsViewController *usageView;
    FileArchiveResult *archiveResult;
    IBOutlet UIButton *aboutButton;
    IBOutlet UIButton *usageButton;
    IBOutlet UIButton *exportButton;
    IBOutlet UIButton *medicationsButton;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIView *overlayView;
    IBOutlet UIImageView *logoImage;
    IASKAppSettingsViewController *appSettingsView;
}

-(IBAction) showMedicationsViewAction: (id) sender;

-(IBAction) showAboutViewAction: (id)sender;

-(IBAction) showUsageViewAction: (id)sender;

-(IBAction) showSettingsModalAction: (id)sender;

-(IBAction) archiveDataAction: (id)sender;

@end
