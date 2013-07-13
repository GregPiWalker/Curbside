//
//  Contact.h
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vContact = 1;

@interface Contact : NSObject <NSCoding, NSCopying> {
@protected
    GUID ident;
@private
    NSString *address;
    NSString *city;
    NSString *state;
    NSString *phone;
    NSString *email;
    int zip;
}

@property(nonatomic, readonly) GUID ident;

/*
 */
@property (nonatomic, retain) NSString *address;

/*
 */
@property (nonatomic, retain) NSString *city;

/*
 */
@property (nonatomic, retain) NSString *state;

/*
 */
@property (nonatomic, retain) NSString *phone;

/*
 */
@property (nonatomic, retain) NSString *email;

/*
 */
@property int zip; 

/**
 */
-(NSString *) getZipAsString;

-(id) initWithIdent: (GUID)ident;
-(NSString *) getPhoneNumberStripped: (BOOL)stripIt withRegionCode: (BOOL)addCode;
-(NSString *) simplifiedDescription;
-(id) copyExactly;

-(void) addPropertyChangeObserver: (NSObject *)observer;
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
