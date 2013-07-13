//
//  Patient.m
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <objc/runtime.h>
#import "Patient.h"
#import "ApplicationSupervisor.h"
#import "Constants.h"
#import "ObservableMutableArray.h"
#import "Contact.h"
#import "Visit.h"
#import "Pharmacy.h"


static NSString *const visitCreationDateTimePattern = @"${visit.creationDateTime}";
static NSString *const visitChiefComplaintPattern = @"${visit.chiefComplaint}";

// Non-const so these are retained and released.
static NSString *reportHeader = nil;
static NSString *reportFooter = nil;


/// An empty Category to declare private methods.
@interface Patient ()

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

@end

/**
 These Macros expand into Category Interface & Implementation for Patient that add collection
 observation on the given properties.
 */
OBSERVABLE_MUTABLE_ARRAY(Patient, Allergies, allergies)
OBSERVABLE_MUTABLE_ARRAY(Patient, Pharmacies, pharmacies)
OBSERVABLE_MUTABLE_ARRAY(Patient, Medications, medications)


@implementation Patient


#pragma mark Properties

@synthesize ident;
static NSString *const lastNameKey = @"lastName";
@synthesize lastName;
static NSString *const firstNameKey = @"firstName";
@synthesize firstName;
@synthesize allergies;
@synthesize pharmacies;
@synthesize contactInfo;
@synthesize priorVisits;
@synthesize medications;
static NSString *const defaultPharmacyIdentKey = @"defaultPharmacyIdent";
@synthesize defaultPharmacy;

@synthesize dateOfBirth;
/// This setter can take either an NSDate or NSString incoming value.
-(void) setDateOfBirth: (NSDate *)value {
    // This is kind of a hack.  Handle an incoming string.
    if ([value isKindOfClass:[NSString class]]) {
        NSDateFormatter *bdayFormatter = [[NSDateFormatter alloc] init];
        [bdayFormatter setDateFormat: kDateFormatterFormat];
        value = [bdayFormatter dateFromString: (NSString*)value];
        [bdayFormatter release];
    }
    if (dateOfBirth == value) {
        return;
    }
    [dateOfBirth autorelease];
    dateOfBirth = [value retain];
}

@dynamic fullName;
-(NSString *) fullName {
    if (firstName && ![firstName isEqualToString:@""]) {
        if (lastName && ![lastName isEqualToString:@""]) {
            return [firstName stringByAppendingFormat:@" %@", lastName];
        }
        else {
            return firstName;
        }
    }
    else {
        return lastName;
    }
}

static NSString *const ageKey = @"age";
@dynamic age;
-(NSInteger) age {
    NSInteger age = 0;
    if (dateOfBirth) {
        NSDateComponents *dobComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate: dateOfBirth];
        NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate: [NSDate date]];
        age = [nowComponents year] - [dobComponents year];
        // Need to take into account birthdays that have not yet happened this year.
        if ([dobComponents month] > [nowComponents month]
            || ([dobComponents month] == [nowComponents month] && [dobComponents day] > [nowComponents day])) {
            age -= 1;
        }
    }
    return age;
}


#pragma mark Methods

+(void) initialize {
    [Patient setVersion: vPatient];
}

-(id) init {
    return [self initWithIdent: [Utilities createGUID]];
}

-(id) initWithIdent: (GUID)anIdent {
    self = [super init];
    if (self) {
        ident = [anIdent copy];
        self.lastName = @"";
        self.firstName = @"";
        contactInfo = [[Contact alloc] init];
        self.allergies = [NSMutableArray array];
        self.pharmacies = [NSMutableArray array];
        self.priorVisits = [NSMutableArray array];
        self.medications = [NSMutableArray array];
        self.dateOfBirth = nil;
        self.defaultPharmacy = nil;
    }
    return self;
}

-(NSString *) getBirthdayAsString {
    if (self.dateOfBirth) {
        NSDateFormatter *newDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [newDateFormatter setDateFormat: kDateFormatterFormat];
        return [newDateFormatter stringFromDate: self.dateOfBirth];
    }
    else {
        return @"";
    }
}

-(NSString *) ageAsString {
    if (self.dateOfBirth) {
        return [NSString stringWithFormat: @"%i", self.age];
    }
    else {
        return @"";
    }
}

-(NSString *) description {
    return [NSString stringWithFormat: @"Patient: %@ %@, %@", self.firstName, self.lastName, ident];
}

-(NSString *) toHtmlReportStringWithTitle: (NSString *)title {
    if (!reportHeader) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource: rsrcHtmlReportHeader ofType: extTxt];
        reportHeader = [[NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: nil] retain];
    }
    if (!reportFooter) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource: rsrcHtmlReportFooter ofType: extTxt];
        reportFooter = [[NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: nil] retain];
    }
    
    // Customize report header section.
    NSString *report = [reportHeader stringByReplacingOccurrencesOfString: kReportTitlePattern withString: title];
    report = [report stringByReplacingOccurrencesOfString:kPatientNamePattern withString: self.fullName];
    
    // Sort the visits based on the user setting.
    NSComparisonResult sortOrder = [ApplicationSupervisor instance].dateSortOrderSetting;
    NSArray *sortedVisits = nil;
    if (sortOrder == NSOrderedAscending) {
        sortedVisits = [self.priorVisits sortedArrayUsingSelector:@selector(compare:)];
    }
    else {
        sortedVisits = [self.priorVisits sortedArrayUsingSelector:@selector(reverseCompare:)];
    }
    
    // Build the variable length visit section.
    BOOL first = YES;
    for (Visit *v in sortedVisits) {
        if (first) {
            first = NO;
        }
        else {
            // Add a spacing row.
            report = [report stringByAppendingString: @"<tr><td>&nbsp;</td></tr>\n"];
        }
        // Append a visit report section.
        report = [report stringByAppendingString: [v toHtmlFragmentReportString]];
    }
    
    // Apply report footer section.
    report = [report stringByAppendingString: reportFooter];
    
    return report;
}

-(NSComparisonResult) compareByFullName: (id)comparisonObject {
    if ([comparisonObject isMemberOfClass:[Patient class]]) {
        Patient *p = (Patient*)comparisonObject;
        NSInteger lastComparison = [self.lastName localizedCaseInsensitiveCompare: p.lastName];
        if (lastComparison == NSOrderedSame) {
            return [self.firstName localizedCaseInsensitiveCompare: p.firstName];
        }
        else {
            return lastComparison;
        }
    }
    return NSIntegerMax;
}

-(BOOL) isEquivalent: (Patient *)p {
    if ([p isMemberOfClass:[Patient class]]) {
        if ([self.firstName localizedCaseInsensitiveCompare: p.firstName] == NSOrderedSame
            && [self.lastName localizedCaseInsensitiveCompare: p.lastName] == NSOrderedSame
            && ((self.dateOfBirth == nil && p.dateOfBirth == nil) || [self.dateOfBirth isEqual: p.dateOfBirth])) {
            return YES;
        }
    }
    return NO;
}

/// Add the given Visit and then issue a
/// change notification on the Visit collection.
-(void) addVisit: (Visit *)v {
    if (![self.priorVisits containsObject:v]) {
        NSMutableArray *proxyVisits = [self mutableArrayValueForKey:priorVisitsKey];
        // Add the visit to the proxy array. This will send the notification.
        [proxyVisits addObject: v];
        
        // Set the reverse reference.
        v.patient = self;
    }
    
}

/// Remove the given Visit if it belongs to this Patient, and then issue a
/// change notification on the Visit collection.
-(void) removeVisit: (Visit *)v {
    if ([self.priorVisits containsObject:v]) {
        NSMutableArray *proxyVisits = [self mutableArrayValueForKey:priorVisitsKey];
        // Remove from the proxy collection. This will send a notification.
        [proxyVisits removeObject: v];
        
        // Remove the reverse reference.
        v.patient = nil;
    }
}

/// Add the given Pharmacy and then issue a
/// change notification on the Pharmacy collection.
-(void) addPharmacy: (Pharmacy *)p {
    if (![self.pharmacies containsObject:p]) {
        NSMutableArray *proxyPharms = [self mutableArrayValueForKey:pharmaciesKey];
        // Add the pharmacy to the proxy array. This will send the notification.
        [proxyPharms addObject: p];
        // Increment the counter that indicates how many Patients use a Pharmacy.
        p.referenceCount++;
        // If no default is set yet, make this the default.
        if (!defaultPharmacy) {
            self.defaultPharmacy = p;
        }
    }
}

/// Remove the given Pharmacy and then issue a change notification on the collection.
-(void) removePharmacy: (Pharmacy *)p {
    if (self.defaultPharmacy == p) {
        self.defaultPharmacy = nil;
    }
    if ([self.pharmacies containsObject:p]) {
        NSMutableArray *proxyPharms = [self mutableArrayValueForKey:pharmaciesKey];
        // Remove from the proxy collection. This will send a notification.
        [proxyPharms removeObject: p];
        // Decrement the counter that indicates how many Patients use a Pharmacy.
        p.referenceCount--;
    }
}

/// Add the given Medication and then issue a
/// change notification on the Medication collection.
-(void) addMedication:(NSString *)m {
    if (![self.medications containsObject:m]) {
        NSMutableArray *proxyMeds = [self mutableArrayValueForKey:medicationsKey];
        // Add the medication to the proxy array. This will send the notification.
        [proxyMeds addObject: m];
    }
}

-(void) removeMedication:(NSString *)m {
    if ([self.medications containsObject:m]) {
        NSMutableArray *proxyMeds = [self mutableArrayValueForKey:medicationsKey];
        // Remove from the proxy collection. This will send a notification.
        [proxyMeds removeObject: m];
    }
}

/// Add the given allergy and then issue a
/// change notification on the allergy collection.
-(void) addAllergy: (NSString *)a {
    if (![self.allergies containsObject:a]) {
        NSMutableArray *proxyAllergies = [self mutableArrayValueForKey:allergiesKey];
        [proxyAllergies addObject: a];
    }
}

/// Remove the given allergy if it belongs to this Patient, and then issue a
/// change notification on the allergy collection.
-(void) removeAllergy: (NSString *)a {
    if ([self.allergies containsObject:a]) {
        NSMutableArray *proxyAllergies = [self mutableArrayValueForKey:allergiesKey];
        [proxyAllergies removeObject: a];
    }
}


#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:firstNameKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:lastNameKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:dateOfBirthKey options:NSKeyValueObservingOptionNew context:nil];
    //TODO: apply ContactListDataSource instead.
    [self addObserver:observer forKeyPath:@"contactInfo.address" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"contactInfo.city" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"contactInfo.state" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"contactInfo.email" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"contactInfo.phone" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"contactInfo.zip" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:allergiesKey options:NSKeyValueChangeRemoval | NSKeyValueChangeInsertion | NSKeyValueChangeReplacement context:nil];
    [self addObserver:observer forKeyPath:pharmaciesKey options:NSKeyValueChangeRemoval | NSKeyValueChangeInsertion context:nil];
    [self addObserver:observer forKeyPath:medicationsKey options:NSKeyValueChangeRemoval | NSKeyValueChangeInsertion context:nil];
    [self addObserver:observer forKeyPath:priorVisitsKey options:NSKeyValueChangeRemoval | NSKeyValueChangeInsertion context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath:firstNameKey];
        [self removeObserver:observer forKeyPath:lastNameKey];
        [self removeObserver:observer forKeyPath:dateOfBirthKey];
        //TODO: apply ContactListDataSource instead.
        [self removeObserver:observer forKeyPath:@"contactInfo.address"];
        [self removeObserver:observer forKeyPath:@"contactInfo.city"];
        [self removeObserver:observer forKeyPath:@"contactInfo.state"];
        [self removeObserver:observer forKeyPath:@"contactInfo.email"];
        [self removeObserver:observer forKeyPath:@"contactInfo.phone"];
        [self removeObserver:observer forKeyPath:@"contactInfo.zip"];
        [self removeObserver:observer forKeyPath:allergiesKey];
        [self removeObserver:observer forKeyPath:pharmaciesKey];
        [self removeObserver:observer forKeyPath:medicationsKey];
        [self removeObserver:observer forKeyPath:priorVisitsKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}


#pragma mark Memory Management

-(void) dealloc {
    self.lastName = nil;
    self.firstName = nil;
    self.contactInfo = nil;
    self.dateOfBirth = nil;
    self.allergies = nil;
    self.pharmacies = nil;
    self.priorVisits = nil;
    self.medications = nil;
    [ident release];
    self.defaultPharmacy = nil;
    [super dealloc];
}


#pragma mark NSCopying Methods

/// Create a pseudo-deep copy of this Patient with a new Ident.
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Patient *copy = [[Patient alloc] init];
    copy.lastName = [[self.lastName copy] autorelease];
    copy.firstName = [[self.firstName copy] autorelease];
    copy.dateOfBirth = [[self.dateOfBirth copy] autorelease];
    // Just create a new array without copying the contents.
    copy.allergies = [NSMutableArray arrayWithArray: self.allergies];
    // Just create a new array without copying the contents.
    copy.pharmacies = [NSMutableArray arrayWithArray: self.pharmacies];
    // Just create a new array without copying the contents.
    copy.priorVisits = [NSMutableArray arrayWithArray: self.priorVisits];
    copy.medications = [[self.medications copy] autorelease];
    copy.contactInfo = [[self.contactInfo copy] autorelease];
    copy.defaultPharmacy = self.defaultPharmacy;
    
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    ident = [[decoder decodeObjectForKey:identKey] retain];
    GUID defaultPharmacyIdent = [[decoder decodeObjectForKey:defaultPharmacyIdentKey] retain];
    if (defaultPharmacyIdent) {
        self.defaultPharmacy = [[ApplicationSupervisor instance] pharmacyWithIdent: defaultPharmacyIdent];
        if (!defaultPharmacy) {
            NSLog(@"ERROR: Failed to load the default Pharmacy with ident %@", defaultPharmacyIdent);
        }
    }
    else {
        // No default pharmacy is set yet.
        defaultPharmacy = nil;
    }
    [defaultPharmacyIdent release];
    
    self.lastName = [decoder decodeObjectForKey:lastNameKey];
    if (!lastName) {
        self.lastName = @"";
    }
    self.firstName = [decoder decodeObjectForKey:firstNameKey];
    if (!firstName) {
        self.firstName = @"";
    }
    self.contactInfo = [decoder decodeObjectForKey:contactInfoKey];
    if (!contactInfo) {
        contactInfo = [[Contact alloc] init];
    }
    self.dateOfBirth = [decoder decodeObjectForKey:dateOfBirthKey];
    
    self.allergies = [decoder decodeObjectForKey:allergiesKey];
    if (!allergies) {
        self.allergies = [NSMutableArray array];
    }
    
    self.pharmacies = [NSMutableArray array];
    // Need to convert Pharmacy idents into Pharmacy instances.
    NSMutableArray *pharmIdents = [[decoder decodeObjectForKey:pharmaciesKey] retain];
    if (pharmIdents) {
        for (NSString *pharmIdent in pharmIdents) {
            // Do not need to retain this object.
            Pharmacy *pharm = [[ApplicationSupervisor instance] pharmacyWithIdent: pharmIdent];
            if (pharm && [pharm isKindOfClass:[Pharmacy class]]) {
                [self.pharmacies addObject: pharm];
                // Increment the count of how many Patients use this Pharmacy.
                pharm.referenceCount++;
            }
            else {
                NSLog(@"ERROR: Failed to load referenced Pharmacy with ident %@", pharmIdent);
            }
        } 
        [pharmIdents release];
    }
    
    self.medications = [decoder decodeObjectForKey:medicationsKey];
    if (!medications) {
        self.medications = [NSMutableArray array];
    }

    self.priorVisits = [NSMutableArray array];
    // Need to convert Visit idents into Visit instances.
    NSMutableArray *visitIdents = [[decoder decodeObjectForKey:priorVisitsKey] retain];
    if (visitIdents) {
        for (NSString *visitIdent in visitIdents) {
            // Do not need to retain this object.
            Visit *v = [[ApplicationSupervisor instance] visitWithIdent: visitIdent];
            if (v && [v isKindOfClass:[Visit class]]) {
                [self.priorVisits addObject: v];
                // Set the reverse reference.
                v.patient = self;
            }
            else {
                NSLog(@"ERROR: Failed to load referenced Visit with ident %@", visitIdent);
            }
        } 
        [visitIdents release];
    }
    
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:ident forKey:identKey];
    if (defaultPharmacy) {
        [coder encodeObject:defaultPharmacy.ident forKey:defaultPharmacyIdentKey];
    }
    
    if (firstName && ![firstName isEqualToString:@""]) {
        [coder encodeObject:firstName forKey:firstNameKey];
    }
    if (lastName && ![lastName isEqualToString:@""]) {
        [coder encodeObject:lastName forKey:lastNameKey];
    }
    if (dateOfBirth) {
        [coder encodeObject:dateOfBirth forKey:dateOfBirthKey];
    }
    [coder encodeObject:contactInfo forKey:contactInfoKey];
    if (allergies && [allergies count] > 0) {
        [coder encodeObject:allergies forKey:allergiesKey]; 
    }
    if (medications && [medications count] > 0) {
        [coder encodeObject:medications forKey:medicationsKey]; 
    }
    
    if (pharmacies && [pharmacies count] > 0) {
        // Only serializing the pharmacy idents here.
        NSMutableArray *pharmIdents = [[NSMutableArray alloc] initWithCapacity:[pharmacies count]];
        for (Pharmacy *pharm in pharmacies) {
            [pharmIdents addObject: pharm.ident];
        }
        [coder encodeObject:pharmIdents forKey:pharmaciesKey]; 
        [pharmIdents release];
    }
    
    if (priorVisits && [priorVisits count] > 0) {
        // Only serializing the visit idents here.
        NSMutableArray *visitIdents = [[NSMutableArray alloc] initWithCapacity:[priorVisits count]];
        for (Visit *v in priorVisits) {
            [visitIdents addObject: v.ident];
        }
        [coder encodeObject:visitIdents forKey:priorVisitsKey]; 
        [visitIdents release];
    }
}

@end
