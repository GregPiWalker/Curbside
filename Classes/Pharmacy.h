//
//  Pharmacy.h
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "NamedDataModel.h"
@class ApplicationSupervisor;
@class Visit;
@class Contact;


/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vPharmacy = 1;
static NSString *const referenceCountKey = @"referenceCount";
static NSString *const contactInfoKey = @"contactInfo";


@interface Pharmacy : NSObject <NSCoding, NSCopying, NamedDataModel> {
@protected
    GUID ident;
@private
    NSString *name;
    Contact *contactInfo;
    NSInteger referenceCount;
    NSMutableArray *observers;
}

@property (nonatomic, readonly) GUID ident;

/*
 */
@property (nonatomic, retain) NSString *name;

@property (nonatomic, readonly) NSString *fullName;

/*
 */
@property (nonatomic, retain) Contact *contactInfo;

@property (nonatomic, assign) NSInteger referenceCount;

-(id) initWithIdent: (GUID)anIdent;

-(BOOL) tryPlaceCallForVisit: (Visit*)visit;

-(BOOL) tryPlaceCall;

/// Create a deep copy exactly the same as this Pharmacy.
-(id) copyExactly;

-(void) addPropertyChangeObserver: (NSObject *)observer;
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
