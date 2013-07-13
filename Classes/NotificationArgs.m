//
//  NotificationArgs.m
//  Curbside
//
//  Created by Greg Walker on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationArgs.h"


/// A class to be used with NSNotification handling through direct subscription.
@implementation NotificationArgs

@synthesize notificationData;
@synthesize notificationSender;

+(id) argsWithData: (id)data fromSender: (id)sender {
    return [[[NotificationArgs alloc] initWithData:data fromSender:sender] autorelease];
}

-(id) initWithData: (id)data fromSender: (id)sender {
    self = [super init];
    if (self) {
        notificationData = [data retain];
        notificationSender = [sender retain];
    }
    return self;
}

-(void) dealloc {
    [notificationSender release];
    [notificationData release];
    
    [super dealloc];
}

@end
