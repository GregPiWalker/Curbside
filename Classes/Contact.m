//
//  Contact.m
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Contact.h"
#import "Constants.h"


@implementation Contact

@synthesize ident;
static NSString *const addressKey = @"address";
@synthesize address;
static NSString *const cityKey = @"city";
@synthesize city;
static NSString *const stateKey = @"state";
@synthesize state;
static NSString *const zipKey = @"zip";
@synthesize zip;
static NSString *const phoneKey = @"phone";
@synthesize phone;
static NSString *const emailKey = @"email";
@synthesize email;


#pragma mark - Methods

+(void) initialize {
    [Contact setVersion: vContact];
}

-(id) init {
    return [self initWithIdent: [Utilities createGUID]];
}

-(id) initWithIdent: (GUID)anIdent {
    self = [super init];
    if (self) {
        ident = [anIdent copy];
        self.address = @"";
        self.city = @"";
        self.state = @"";
        self.zip = 0;
        self.phone = @"";
        self.email = @"";
    }
    return self;
}

-(NSString *) getZipAsString {
    if (zip == 0) {
        return @"";
    }
    return [NSString stringWithFormat: @"%i", zip];
}

-(NSString *) getPhoneNumberStripped: (BOOL)stripIt withRegionCode: (BOOL)addCode {
    static NSString *const regionPhoneCode = @"1";
    static const NSInteger regionalizedLength = 11;
    
    if (phone) {
        NSString *strippedPhone = [self.phone stripNonDigitCharacters];
        if (!addCode || ([strippedPhone length] == regionalizedLength && [[strippedPhone substringToIndex:1] isEqualToString: regionPhoneCode])) {
            if (!addCode) {
                // TODO: there is a case here where the region code is there but needs to be removed.
            }
            if (stripIt) {
                return strippedPhone;
            }
            return self.phone;
        }
        else if ([strippedPhone length] < regionalizedLength) {
            if (stripIt) {
                return [regionPhoneCode stringByAppendingString: strippedPhone];
            }
            return [regionPhoneCode stringByAppendingString:self.phone];
        }
    }
    return @"";
}

-(NSString *) simplifiedDescription {
    NSString *value = @"";
    
    if (address && ![address isEqualToString: @""]) {
        value = [value stringByAppendingString: address];
        if (phone && ![phone isEqualToString:@""]) {
            value = [value stringByAppendingFormat:@", %@", phone];
            // Address and Phone number are sufficient.
            return value;
        }
    }
    if (city && ![city isEqualToString:@""]) {
        if ([value length] > 0) {
            value = [value stringByAppendingFormat:@", %@", city];
        }
        else {
            value = [value stringByAppendingString: city];
        }
    }
    if (state && ![state isEqualToString:@""]) {
        if ([value length] > 0) {
            value = [value stringByAppendingFormat:@", %@", state];
        }
        else {
            value = [value stringByAppendingString: state];
        }
    }
    if (zip > 0) {
        if ([value length] > 0) {
            value = [value stringByAppendingFormat:@", %i", zip];
        }
        else {
            value = [value stringByAppendingFormat:@"%i", zip];
        }
    }
    if (phone && ![phone isEqualToString:@""]) {
        if ([value length] > 0) {
            value = [value stringByAppendingFormat:@", %@", phone];
        }
        else {
            value = [value stringByAppendingString: phone];
        }
    }
    if (email && ![email isEqualToString:@""]) {
        if ([value length] > 0) {
            value = [value stringByAppendingFormat:@", %@", email];
        }
        else {
            value = [value stringByAppendingString: email];
        }
    }
    
    return value;
}

-(NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"Contact: %@\n%@", ident, self.address];
    if (city && ![city isEqualToString:@""]) {
        if (zip > 0 || (state && ![state isEqualToString:@""])) {
            desc = [NSString stringWithFormat:@"%@\n%@, ", desc, city];
        }
        else {
            desc = [NSString stringWithFormat:@"%@\n%@", desc, city];
        }
    }
    if (state && ![state isEqualToString:@""]) {
        desc = [NSString stringWithFormat:@"%@ %@", desc, state];
    }
    if (zip > 0) {
        desc = [NSString stringWithFormat:@"%@ %i", desc, zip];
    }
    
    return desc;
}

// Override isEqual.  Returns true if all properties are equal except for the object ident.
-(BOOL) isEqual: (id)object {
    if (!object || ![object isKindOfClass: [Contact class]]) {
        return NO;
    }
    Contact *comparator = (Contact *)object;
    if ([address isEqualToString: comparator.address] && [city isEqual: comparator.city]
        && [state isEqualToString: comparator.state] && [phone isEqual: comparator.phone]
        && [email isEqualToString: comparator.email] && zip == comparator.zip) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void) dealloc {
    self.address = nil;
    self.city = nil;
    self.state = nil;
    self.phone = nil;
    self.email = nil;
    [ident release];
    [super dealloc];
}


#pragma mark NSCopying Methods

/// Create a deep copy of this Pharmacy with a new Ident.
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Contact *copy = [[Contact alloc] init];
    copy.address = [[self.address copy] autorelease];
    copy.city = [[self.city copy] autorelease];
    copy.state = [[self.state copy] autorelease];
    copy.phone = [[self.phone copy] autorelease];
    copy.email = [[self.email copy] autorelease];
    copy.zip = self.zip;
    
    return copy;
}

/// Create a deep copy exactly the same as this Contact.
-(id) copyExactly {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
     Contact *copy = [[Contact alloc] initWithIdent: self.ident];
    copy.address = [[self.address copy] autorelease];
    copy.city = [[self.city copy] autorelease];
    copy.state = [[self.state copy] autorelease];
    copy.phone = [[self.phone copy] autorelease];
    copy.email = [[self.email copy] autorelease];
    copy.zip = self.zip;
    
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    ident = [[decoder decodeObjectForKey:identKey] retain];
    
    self.address = [decoder decodeObjectForKey:addressKey];
    if (!address) {
        self.address = @"";
    }
    self.city = [decoder decodeObjectForKey:cityKey];
    if (!city) {
        self.city = @"";
    }
    self.state = [decoder decodeObjectForKey:stateKey];
    if (!state) {
        self.state = @"";
    }
    self.zip = [decoder decodeIntForKey:zipKey];
    self.phone = [decoder decodeObjectForKey:phoneKey];
    if (!phone) {
        self.phone = @"";
    }
    self.email = [decoder decodeObjectForKey:emailKey];
    if (!email) {
        self.email = @"";
    }
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:ident forKey:identKey];
    
    if (address && ![address isEqualToString:@""]) {
        [coder encodeObject:address forKey:addressKey];
    }
    if (city && ![city isEqualToString:@""]) {
        [coder encodeObject:city forKey:cityKey];
    }
    if (state && ![state isEqualToString:@""]) {
        [coder encodeObject:state forKey:stateKey];
    }
    if (zip > 0) {
        [coder encodeInt:zip forKey:zipKey];
    }
    if (phone && ![phone isEqualToString:@""]) {
        [coder encodeObject:phone forKey:phoneKey];
    }
    if (email && ![email isEqualToString:@""]) {
        [coder encodeObject:email forKey:emailKey];
    }
}


#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:addressKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:cityKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:stateKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:emailKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:phoneKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:zipKey options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath: addressKey];
        [self removeObserver:observer forKeyPath: cityKey];
        [self removeObserver:observer forKeyPath: stateKey];
        [self removeObserver:observer forKeyPath: emailKey];
        [self removeObserver:observer forKeyPath: phoneKey];
        [self removeObserver:observer forKeyPath: zipKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
