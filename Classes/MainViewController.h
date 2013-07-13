//
//  MainViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/6/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditVisitViewController.h"
#import "PatientListViewController.h"
#import "EditPatientViewController.h"
#import "EditRxViewController.h"
//#import "RxHistoryViewController.h"
#import "VisitHistoryViewController.h"
#import "MoreViewController.h"

/**
 This class acts as the view controller for the topLevelView of the UINavigationController.  It is also
 the UINavigationController's delegate.
 */
@interface MainViewController : UIViewController <UINavigationControllerDelegate> {
@private
    EditVisitViewController *newVisitViewController;
    PatientListViewController *patientListViewController;
    VisitHistoryViewController *visitHistoryViewController;
    //RxHistoryViewController *rxHistoryViewController;
    MoreViewController *moreViewController; 
    UIViewController *previousViewController;
    IBOutlet UIImageView *logoImage;
    IBOutlet UIButton *visitButton;
    IBOutlet UIButton *patientsButton;
    IBOutlet UIButton *visitsButton;
    IBOutlet UIButton *moreButton;
}

- (id) init;

/**
 Raised when the NewVisit button is pressed.
 */
-(IBAction) newVisitPressed: (id) sender;

/**
 Raised when the PatientList button is pressed.
 */
-(IBAction) patientListPressed: (id) sender;

/**
 Raised when the VisitHistory button is pressed.
 */
-(IBAction) visitHistoryPressed: (id) sender;

/**
 Raised when the RxHistory button is pressed.
 */
//-(IBAction) rxHistoryPressed: (id) sender;

/**
 Raised when the More button is pressed.
 */
-(IBAction) morePressed: (id) sender;

@end
