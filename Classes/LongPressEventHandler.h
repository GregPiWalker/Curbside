//
//  LongPressEventHandler.h
//  Curbside
//
//  Created by Greg Walker on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol LongPressEventHandler <NSObject>

-(void) handleLongPress: (UILongPressGestureRecognizer*)longPressRecognizer;

@end
