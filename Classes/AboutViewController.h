//
//  AboutViewController.h
//  CurbSide
//
//  Created by Greg Walker on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ApplicationSupervisor.h"


@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    @private
    UIButton *feedbackButton;
    UITextView *aboutTextView;
    UILabel *versionLabel;
    UILabel *versionNumberLabel;
    UILabel *curbLogoLabel;
    UILabel *sideLogoLabel;
    UIImageView *logoImage;
}

@property (nonatomic, assign) IBOutlet UIImageView *logoImage;

@property (nonatomic, retain) IBOutlet UIButton *feedbackButton;

@property (nonatomic, retain) IBOutlet UITextView *aboutTextView;

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

@property (nonatomic, retain) IBOutlet UILabel *versionNumberLabel;

@property (nonatomic, retain) IBOutlet UILabel *curbLogoLabel;

@property (nonatomic, retain) IBOutlet UILabel *sideLogoLabel;

-(IBAction) sendFeedbackAction: (id) sender;

@end
