//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//


#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
static classname *instance = nil; \
 \
+ (classname *)instance \
{ \
	@synchronized(self) \
	{ \
		if (instance == nil) \
		{ \
			instance = [[self alloc] init]; \
		} \
	} \
	 \
	return instance; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (instance == nil) \
		{ \
            instance = [super allocWithZone:zone]; \
            if ([instance respondsToSelector:@selector(initSingleton)]) { \
                [instance initSingleton]; \
            } \
			return instance; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (oneway void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
