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
#import "ParentViewDelegate.h"

@class AboutViewController;
@class UsageTipsViewController;
@class ArchiveListViewController;
@class FileArchiveResult;


@interface MoreViewController : UIViewController<MFMailComposeViewControllerDelegate, UIAlertViewDelegate, ParentViewDelegate, IASKSettingsDelegate> {
    @private
    AboutViewController *aboutView;
    UsageTipsViewController *usageView;
    FileArchiveResult *archiveResult;
    ArchiveListViewController *archiveFileListView;
    IBOutlet UIButton *aboutButton;
    IBOutlet UIButton *usageButton;
    IBOutlet UIButton *exportButton;
    IBOutlet UIButton *importButton;
    IBOutlet UIButton *medicationsButton;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIView *overlayView;
    IBOutlet UIImageView *logoImage;
    IASKAppSettingsViewController *appSettingsView;
}

-(IBAction) showMedicationsViewAction: (id) sender;

-(IBAction) showAboutViewAction: (id)sender;

-(IBAction) showUsageViewAction: (id)sender;

-(IBAction) showArchiveListViewAction: (id)sender;

-(IBAction) showSettingsModalAction: (id)sender;

-(IBAction) archiveDataAction: (id)sender;

@end
