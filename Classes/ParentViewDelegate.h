//
//  ModalViewParentDelegate.h
//  CurbSide
//
//  Created by Greg Walker on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ParentViewDelegate

-(void) dismissChildView: (UIViewController *)child;

//-(void) childViewWillDisappear: (UIViewController *)child;

@end
