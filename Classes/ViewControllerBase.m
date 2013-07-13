//
//  ViewControllerBase.m
//  CurbSide
//
//  Created by Greg Walker on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewControllerBase.h"
#import "Constants.h"


@implementation ViewControllerBase

-(void) dismissKeyboard {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass of ViewControllerBase.", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

-(void) animateKeyboardWillShow: (NSNotification *)notification {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass of ViewControllerBase.", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

-(void) animateKeyboardWillHide: (NSNotification *)notification {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass of ViewControllerBase.", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

#pragma mark View lifecycle

-(void) viewWasPopped {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass of ViewControllerBase.", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Add notification observers for keyboard visibility changes.
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Dismiss the keyboard.
    [self dismissKeyboard];
    
    // Remove keyboard visibility change observers.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
}

@end
