//
//  Pharmacy.m
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ApplicationSupervisor.h"
#import "Pharmacy.h"
#import "Visit.h"
#import "Contact.h"
#import "Constants.h"


@implementation Pharmacy

@synthesize ident;
@synthesize name;
@synthesize referenceCount;

@synthesize contactInfo;
-(void) setContactInfo: (Contact *)value {
    if (value == contactInfo) {
        return;
    }
    
    // Remove listeners from the old contact.
    for (id observer in observers) {
        [contactInfo removePropertyChangeObserver: observer];
    }
    
    [contactInfo autorelease];
    contactInfo = [value retain];
    
    if (contactInfo) {
        // Add listeners to the new contact.
        for (id observer in observers) {
            [contactInfo addPropertyChangeObserver: observer];
        }
    }
}

@dynamic fullName;
-(NSString *) fullName {
    return self.name;
}


#pragma mark - Methods

+(void) initialize {
    [Pharmacy setVersion: vPharmacy];
}

-(id) init {
    return [self initWithIdent: [Utilities createGUID]];
}

-(id) initWithIdent: (GUID)anIdent {
    self = [super init];
    if (self) {
        ident = [anIdent copy];
        self.name = @"";
        contactInfo = [[Contact alloc] init];
        referenceCount = 0;
        observers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) dealloc {
    self.name = nil;
    self.contactInfo = nil;
    [observers release];
    [ident release];
    [super dealloc];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Name: %@, %@", self.name, ident];
}

-(BOOL) tryPlaceCallForVisit: (Visit*)visit {
    BOOL success = NO;
    @try {
        if ([UIApplication instancesRespondToSelector:@selector(canOpenURL:)] && contactInfo.phone) {
            NSString *phoneNum = [self.contactInfo getPhoneNumberStripped:YES withRegionCode:YES];
            NSURL *phoneURL = [[NSURL URLWithString: [@"tel:" stringByAppendingString: phoneNum]] retain];
            if ([[UIApplication sharedApplication] canOpenURL: phoneURL]) {
                [[UIApplication sharedApplication] openURL: phoneURL];
                if (visit) {
                    // Set the Call-In date and save the results.
                    visit.calledinDateTime = [NSDate date];
                    [[ApplicationSupervisor instance] updateVisit: visit];
                }
                success = YES;
            }
            [phoneURL release];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"Call pharmacy failed: %@", ex);
    }
    return success;
}

-(BOOL) tryPlaceCall {
    return [self tryPlaceCallForVisit:nil];
}

// Override isEqual.  Returns true if all properties are equal except for the object ident.
-(BOOL) isEqual: (id)object {
    if (!object || ![object isKindOfClass: [Pharmacy class]]) {
        return NO;
    }
    Pharmacy *comparator = (Pharmacy *)object;
    if ([name isEqualToString: comparator.name] && [contactInfo isEqual: comparator.contactInfo]) {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark NSCopying Methods

/// Create a deep copy of this Pharmacy with a new Ident.
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Pharmacy *copy = [[Pharmacy alloc] init];
    copy.name = [[self.name copy] autorelease];
    copy.contactInfo = [[self.contactInfo copy] autorelease];
    
    return copy;
}

/// Create a deep copy exactly the same as this Pharmacy.
-(id) copyExactly {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Pharmacy *copy = [[Pharmacy alloc] initWithIdent: ident];
    copy.name = [[self.name copy] autorelease];
    copy.contactInfo = [[self.contactInfo copyExactly] autorelease];
    
    //TODO: add observers too.
    
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    
    ident = [[decoder decodeObjectForKey:identKey] retain];
    
    self.name = [decoder decodeObjectForKey:nameKey];
    if (!name) {
        self.name = @"";
    }
    self.contactInfo = [decoder decodeObjectForKey:contactInfoKey];
    if (!contactInfo) {
        contactInfo = [[Contact alloc] init];
    }
    observers = [[NSMutableArray alloc] init];
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:ident forKey:identKey];
    
    if (name && ![name isEqualToString:@""]) {
        [coder encodeObject:name forKey:nameKey];
    }
    [coder encodeObject:contactInfo forKey:contactInfoKey];
}


#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath: nameKey options:NSKeyValueObservingOptionNew context:nil];
    //[self addObserver:observer forKeyPath: contactInfoKey options:NSKeyValueObservingOptionNew context:nil];
    [contactInfo addPropertyChangeObserver: observer];
    [observers addObject: observer];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath:nameKey];
        //[self removeObserver:observer forKeyPath:contactInfoKey];
        [contactInfo removePropertyChangeObserver: observer];
        [observers removeObject: observer];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
