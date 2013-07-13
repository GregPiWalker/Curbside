//
//  StyledTextView.m
//  Curbside
//
//  Created by Greg Walker on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StyledTextView.h"


@interface StyledTextView ()
-(void) applyStyle;
@end

@implementation StyledTextView

-(id) init {
    self = [super init];
    [self applyStyle];
    return self;
}

-(id) initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self applyStyle];
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self applyStyle];
    return self;
}

-(void) applyStyle {
    // Give a nice rounded corner.
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    // Make the border resemble a UITextField.
    self.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
    self.layer.borderWidth = 1.0;
}

@end
