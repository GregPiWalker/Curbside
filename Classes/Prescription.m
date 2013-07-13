//
//  Prescription.m
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Prescription.h"
#import "Constants.h"
#import "Visit.h"

static NSString *const rxNamePattern = @"${prescription.name}";

// Non-const so these are retained and released.
static NSString *rxHeader = nil;
static NSString *rxFooter = nil;
static NSString *rxBodyRepeat = nil;


@implementation Prescription

@synthesize visit;
@synthesize ident;
static NSString *const medicationKey = @"medication";
@synthesize medication;
static NSString *const dosageKey = @"dosage";
@synthesize dosage;
static NSString *const usageFrequencyKey = @"usageFrequency";
@synthesize usageFrequency;
static NSString *const usagePeriodKey = @"usagePeriod";
@synthesize usagePeriod;
static NSString *const usageUnitsKey = @"usageUnits";
@synthesize usageUnits;
static NSString *const totalDispensedKey = @"totalDispensed";
@synthesize totalDispensed;
static NSString *const numRefillsKey = @"numRefills";
@synthesize numRefills;
static NSString *const visitIdentKey = @"visitIdent";
@synthesize visitIdent;


#pragma mark Methods

+(void) initialize {
    [Prescription setVersion: vPrescription];
}

-(id) init {
    return [self initWithIdent: [Utilities createGUID]];
}

-(id) initWithIdent: (GUID)anIdent {
    self = [super init];
    if (self) {
        ident = [anIdent copy];
        self.visit = nil;
        self.visitIdent = nil;
        self.dosage = @"";
        self.usageFrequency = @"";
        self.usagePeriod = @"";
        self.usageUnits = @"";
        self.totalDispensed = 0;
        self.numRefills = 0;
        self.medication = @"";
    }
    return self;
}

-(id) initFor: (Visit *)v withDetails: (PrescriptionDetails)details {
    self = [super init];
    if (self) {
        ident = [[Utilities createGUID] retain];
        self.visit = v;
        self.visitIdent = v.ident;
        self.medication = details.medicationName;
        self.dosage = details.dosage;
        self.usageFrequency = details.usageFrequency;
        self.usagePeriod = details.usagePeriod;
        self.usageUnits = details.usageUnits;
        self.totalDispensed = details.totalDispensed;
        self.numRefills = details.numberOfRefills;
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat: @"Prescription: %@, %@", self.medication, ident];
}

-(NSString *) toHtmlFragmentReportString {
    if (!rxHeader) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlPrescriptionBody1 ofType: extTxt];
        rxHeader = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!rxBodyRepeat) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlPrescriptionBody2 ofType: extTxt];
        rxBodyRepeat = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!rxFooter) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlPrescriptionBody3 ofType: extTxt];
        rxFooter = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    
    // Customize the prescription header.
    NSString *report = [rxHeader stringByReplacingOccurrencesOfString: rxNamePattern withString: self.medication];
    
    // Customize the prescription variables.
    if (self.dosage && [self.dosage length] > 0) {
        NSString *fragment = [rxBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Dosage:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: self.dosage];
        report = [report stringByAppendingString: fragment];
    }
    if (self.totalDispensed > 0) {
        NSString *fragment = [rxBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Total Dispensed:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: [NSString stringWithFormat:@"%i", self.totalDispensed]];
        report = [report stringByAppendingString: fragment];
    }
    if (self.numRefills >= 0) {
        NSString *fragment = [rxBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Number of Refills:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: [NSString stringWithFormat:@"%i", self.numRefills]];
        report = [report stringByAppendingString: fragment];
    }
    if (self.usageFrequency && [self.usageFrequency length] > 0) {
        NSString *fragment = [rxBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Usage:"];
        if (self.usagePeriod && self.usageUnits && [self.usagePeriod length] > 0 && [self.usageUnits length] > 0) {
            NSString *usage = [NSString stringWithFormat:@"%@ every %@ %@", self.usageFrequency, self.usagePeriod, self.usageUnits];
            fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: usage];
        }
        else {
            fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: @""];
        }
        report = [report stringByAppendingString: fragment];
    }
    
    // Apply the prescription footer.
    report = [report stringByAppendingString: rxFooter];
    
    return report;
}

-(void) dealloc {
    self.visit = nil;
    self.visitIdent = nil;
    self.usageFrequency = nil;
    self.usagePeriod = nil;
    self.usageUnits = nil;
    self.medication = nil;
    self.dosage = nil;
    [ident release];
    [rxHeader release];
    [rxFooter release];
    [rxBodyRepeat release];
    rxHeader = nil;
    rxFooter = nil;
    rxBodyRepeat = nil;
    
    [super dealloc];
}


#pragma mark NSCopying Methods

/// Create a deep copy of this Prescription with a new Ident.
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Prescription *copy = [[Prescription alloc] init];
    copy.medication = [[self.medication copy] autorelease];
    copy.dosage = [[self.dosage copy] autorelease];
    copy.usageFrequency = [[self.usageFrequency copy] autorelease];
    copy.usagePeriod = [[self.usagePeriod copy] autorelease];
    copy.usageUnits = [[self.usageUnits copy] autorelease];
    copy.totalDispensed = self.totalDispensed;
    copy.numRefills = self.numRefills;
    copy.visit = [[self.visit copy] autorelease];
    
    if (copy.visit) {
        copy.visitIdent = copy.visit.ident;
    }
    else {
        copy.visitIdent = nil;
    }
    
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    ident = [[decoder decodeObjectForKey:identKey] retain];
    self.visitIdent = [decoder decodeObjectForKey:visitIdentKey];
    
    self.dosage = [decoder decodeObjectForKey:dosageKey];
    if (!dosage) {
        self.dosage = @"";
    }
    self.medication = [decoder decodeObjectForKey:medicationKey];
    if (!medication) {
        self.medication = @"";
    }
    self.usageFrequency = [decoder decodeObjectForKey:usageFrequencyKey];
    if (!usageFrequency) {
        self.usageFrequency = @"";
    }
    self.usagePeriod = [decoder decodeObjectForKey:usagePeriodKey];
    if (!usagePeriod) {
        self.usagePeriod = @"";
    }
    self.usageUnits = [decoder decodeObjectForKey:usageUnitsKey];
    if (!usageUnits) {
        self.usageUnits = @"";
    }
    self.totalDispensed = [decoder decodeIntForKey:totalDispensedKey];
    self.numRefills = [decoder decodeIntForKey:numRefillsKey];
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:ident forKey:identKey];
    [coder encodeObject:visit.ident forKey:visitIdentKey];
    
    if (medication && ![medication isEqualToString:@""]) {
        [coder encodeObject:medication forKey:medicationKey];
    }
    if (usageFrequency && ![usageFrequency isEqualToString:@""]) {
        [coder encodeObject:usageFrequency forKey:usageFrequencyKey];
    }
    if (usagePeriod && ![usagePeriod isEqualToString:@""]) {
        [coder encodeObject:usagePeriod forKey:usagePeriodKey];
    }
    if (usageUnits && ![usageUnits isEqualToString:@""]) {
        [coder encodeObject:usageUnits forKey:usageUnitsKey];
    }
    if (dosage && ![dosage isEqualToString:@""]) {
        [coder encodeObject:dosage forKey:dosageKey];
    }
    if (numRefills > 0) {
        [coder encodeInt:numRefills forKey:numRefillsKey];
    }
    if (totalDispensed > 0) {
        [coder encodeInt:totalDispensed forKey:totalDispensedKey];
    }
}

@end
