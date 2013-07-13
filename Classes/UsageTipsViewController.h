//
//  UsageTipsViewController.h
//  Curbside
//
//  Created by Greg Walker on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UsageTipsViewController : UIViewController {
    UIWebView *usageWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView *usageWebView;

@end