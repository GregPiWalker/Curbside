//
//  PropertyChangePublisher.h
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PropertyChangePublisher <NSObject>

-(void) addPropertyChangeObserver: (NSObject *)observer;

-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
