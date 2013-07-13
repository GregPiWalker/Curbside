//
//  CurbSideAppDelegate.h
//  CurbSide
//
//  Created by Greg Walker on 3/5/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface CurbSideAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    MainViewController *mainViewController;
}

/**
 */
@property (nonatomic, retain) IBOutlet UIWindow *window;

/**
 */
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

/**
 */
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;


@end

