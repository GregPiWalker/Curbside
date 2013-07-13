//
//  ViewControllerBase.h
//  CurbSide
//
//  Created by Greg Walker on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationSupervisor.h"


@interface ViewControllerBase : UIViewController {
    NSInteger navigationRank;
    BOOL wasViewPopped;
}

/// Called by a NavigationViewController when this view was popped off the stack.
-(void) viewWasPopped;

-(void) dismissKeyboard;

-(void) animateKeyboardWillShow: (NSNotification *)notification;

-(void) animateKeyboardWillHide: (NSNotification *)notification;

@end
