//
//  NotificationArgs.h
//  Curbside
//
//  Created by Greg Walker on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/// A class to be used with NSNotification handling through direct subscription.
@interface NotificationArgs : NSObject {
    id notificationSender;
    id notificationData;
}

@property (nonatomic, readonly) id notificationSender;
@property (nonatomic, readonly) id notificationData;

+(id) argsWithData: (id)data fromSender: (id)sender;

-(id) initWithData: (id)data fromSender: (id)sender;

@end
