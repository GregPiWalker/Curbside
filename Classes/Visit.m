//
//  Visit.m
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Visit.h"
#import "Constants.h"
#import "Patient.h"
#import "Prescription.h"
#import "ApplicationSupervisor.h"

static NSString *const visitCreationDateTimePattern = @"${visit.creationDateTime}";
static NSString *const visitChiefComplaintPattern = @"${visit.chiefComplaint}";

// Non-const so these are retained and released.
static NSString *reportHeader = nil;
static NSString *reportFooter = nil;
static NSString *visitHeader = nil;
static NSString *visitBodyRepeat = nil;
static NSString *visitBodyClose = nil;
static NSString *visitFooter = nil;
static NSString *rxSectionHeader = nil;
static NSString *rxSectionFooter = nil;

/**
 This Macro expands into Category Interface & Implementation for Visit that add collection
 observation on the given properties.
 */
//OBSERVABLE_MUTABLE_ARRAY(Visit, Prescriptions, prescriptions)


@implementation Visit


#pragma mark - Properties

@synthesize ident;
static NSString *const visitNumberKey = @"visitNumber";
@synthesize visitNumber;
@synthesize createdDateTime;
@synthesize prescriptions;
@synthesize chiefComplaint;
@synthesize historyPresentIllness;
@synthesize impression;
@synthesize physicalExam;
@synthesize plan;
@synthesize wasCalledIn;
static NSString *const patientIdentKey = @"patientIdent";
@synthesize patientIdent;

@synthesize calledinDateTime;
-(void) setCalledinDateTime: (NSDate *)value {
    if (calledinDateTime == value) {
        return;
    }
    [calledinDateTime autorelease];
    calledinDateTime = [value retain];
    
    self.wasCalledIn = (calledinDateTime == nil ? NO : YES);
}

@synthesize patient;
/** Custom Patient propety setter */
-(void) setPatient:(Patient *)p {
    if (patient == p) {
        return;
    }

    [patient autorelease];
    patient = [p retain];
    
    if (patient != nil) {
        self.patientIdent = patient.ident;
    }
}


#pragma mark - Methods

+(void) initialize {
    [Visit setVersion: vVisit];
}

-(id) init {
    return [self initWithIdent: [Utilities createGUID]];
}

-(id) initWithIdent: (GUID)anIdent {
    self = [super init];
    if (self) {
        ident = [anIdent copy];
        patient = nil;
        self.prescriptions = [NSMutableArray array];
        self.chiefComplaint = @"";
        self.historyPresentIllness = @"";
        self.impression = @"";
        self.physicalExam = @"";
        self.plan = @"";
        self.createdDateTime = [NSDate date];
        self.calledinDateTime = nil;
        wasCalledIn = NO;
    }
    return self;
}

-(id) initWithPatient: (Patient *)p andPrescriptions: (NSArray *)rxs andDetails: (VisitDetails)details {
    self = [super init];
    if (self) {
        ident = [[Utilities createGUID] retain];
        if (rxs) {
            self.prescriptions = [NSMutableArray arrayWithArray:rxs];
        }
        else {
            self.prescriptions = [NSMutableArray array];
        }
        self.patient = p;
        self.chiefComplaint = details.chiefComplaint;
        self.historyPresentIllness = details.historyPresentIllness;
        self.impression = details.impression;
        self.physicalExam = details.physicalExam;
        self.plan = details.plan;
        self.createdDateTime = details.createdDateTime;
        if (details.calledinDateTime) {
            self.calledinDateTime = details.calledinDateTime;
            self.wasCalledIn = YES;
        }
        else {
            self.calledinDateTime = nil;
            self.wasCalledIn = NO;
        }
    }
    return self;
}

-(NSString *) description {
    return [NSString stringWithFormat: @"Visit: %@, %@", [self getCreationDateTimeAsString], ident];
}

/// Add the given Prescription and then issue a
/// change notification on the Prescription collection.
-(void) addPrescription: (Prescription *)p {
    if (![self.prescriptions containsObject:p]) {
        NSMutableArray *proxyRXs = [self mutableArrayValueForKey:prescriptionsKey];
        // Add the prescription to the proxy array. This will send the notification.
        [proxyRXs addObject: p];
        // Set the reverse reference.
        p.visit = self;
    }
}

/// Remove the given Prescription and then issue a change notification on the collection.
-(void) removePrescription: (Prescription *)p {
    if ([self.prescriptions containsObject:p]) {
        NSMutableArray *proxyRXs = [self mutableArrayValueForKey:prescriptionsKey];
        // Remove from the proxy collection. This will send a notification.
        [proxyRXs removeObject: p];
        // Clear the reverse reference.
        p.visit = nil;
    }
}

-(NSString *) getCreationDateAsString {
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    [newDateFormatter setDateFormat: kDateFormatterFormat];
    NSString *rval = [newDateFormatter stringFromDate: self.createdDateTime];
    [newDateFormatter release];
    return rval;
}

-(NSString *) getCreationDateTimeAsString {
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    [newDateFormatter setDateFormat: kDateTimeAmPmFormatterFormat];
    NSString *rval = [newDateFormatter stringFromDate: self.createdDateTime];
    [newDateFormatter release];
    return rval;
}

-(NSString *) getCallInDateTimeAsString {
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    [newDateFormatter setDateFormat: kDateTimeAmPmFormatterFormat];
    NSString *rval = [newDateFormatter stringFromDate: self.calledinDateTime];
    [newDateFormatter release];
    return rval;
}

-(NSString *) toHtmlReportStringWithTitle: (NSString *)title {
    if (!reportHeader) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlReportHeader ofType: extTxt];
        reportHeader = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!reportFooter) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlReportFooter ofType: extTxt];
        reportFooter = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    
    // Customize report header section.
    NSString *report = [reportHeader stringByReplacingOccurrencesOfString:kReportTitlePattern withString:title];
    report = [report stringByReplacingOccurrencesOfString:kPatientNamePattern withString:patient.fullName];
    
    // Build the visit body.
    report = [report stringByAppendingString:[self toHtmlFragmentReportString]];
    
    // Apply report footer section.
    report = [report stringByAppendingString: reportFooter];
    
    return report;
}

-(NSString *) toHtmlFragmentReportString {
    if (!visitHeader) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlVisitHeader ofType: extTxt];
        visitHeader = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!visitBodyRepeat) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlVisitBody1 ofType: extTxt];
        visitBodyRepeat = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!visitBodyClose) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlVisitBody2 ofType: extTxt];
        visitBodyClose = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!visitFooter) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlVisitFooter ofType: extTxt];
        visitFooter = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!rxSectionHeader) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlPrescriptionHeader ofType: extTxt];
        rxSectionHeader = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    if (!rxSectionFooter) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:rsrcHtmlPrescriptionFooter ofType: extTxt];
        rxSectionFooter = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] retain];
    }
    
    // Customize report visit header section.
    NSString *report = [visitHeader stringByReplacingOccurrencesOfString: visitCreationDateTimePattern withString: [self getCreationDateTimeAsString]];
    report = [report stringByReplacingOccurrencesOfString: visitChiefComplaintPattern withString: self.chiefComplaint];
    
    // Customize report visit variables section.
    if (self.historyPresentIllness && [self.historyPresentIllness length] > 0) {
        NSString *fragment = [visitBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"History of Present Illness:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: self.historyPresentIllness];
        report = [report stringByAppendingString: fragment];
    }
    if (self.physicalExam && [self.physicalExam length] > 0) {
        NSString *fragment = [visitBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Physical Exam:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: self.physicalExam];
        report = [report stringByAppendingString: fragment];
    }
    if (self.impression && [self.impression length] > 0) {
        NSString *fragment = [visitBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Impression:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: self.impression];
        report = [report stringByAppendingString: fragment];
    }
    if (self.plan && [self.plan length] > 0) {
        NSString *fragment = [visitBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Plan:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: self.plan];
        report = [report stringByAppendingString: fragment];
    }
    if (self.calledinDateTime) {
        NSString *fragment = [visitBodyRepeat stringByReplacingOccurrencesOfString: kFieldNamePattern withString: @"Last Called-In:"];
        fragment = [fragment stringByReplacingOccurrencesOfString: kFieldValuePattern withString: [self getCallInDateTimeAsString]];
        report = [report stringByAppendingString: fragment];
    }
    // Close the visit body variable section.
    report = [report stringByAppendingString:visitBodyClose];
    
    if ([self.prescriptions count] > 0) {
        // Apply prescriptions header.
        report = [report stringByAppendingString: rxSectionHeader];
        
        NSInteger c = 1;
        for (Prescription *rx in prescriptions) {
            // Add a prescription fragment.
            NSString *fragment = [rx toHtmlFragmentReportString];
            fragment = [fragment stringByReplacingOccurrencesOfString: kItemCountPattern withString: [NSString stringWithFormat:@"%i", c++]];
            report = [report stringByAppendingString: fragment];
        }
        
        // Apply prescriptions footer.
        report = [report stringByAppendingString: rxSectionFooter];
    }
    
    // Apply the visit footer.
    report = [report stringByAppendingString: visitFooter];
    
    return report;
}

/** compare
 Redefine compare method to compare two Visits based on creation DateTime.
 */
-(NSComparisonResult) compare: (id)otherObject {
    if ([otherObject respondsToSelector:@selector(createdDateTime)]) {
        return [self.createdDateTime compare: [otherObject createdDateTime]];
    }
    // TODO: exception handling.
    return NSIntegerMax;
}

/// reverseCompare
/// Returns the opposite results of compare.
-(NSComparisonResult) reverseCompare: (id)otherObject {
    if ([otherObject respondsToSelector:@selector(createdDateTime)]) {
        return [self.createdDateTime reverseCompare: [otherObject createdDateTime]];
    }
    // TODO: exception handling.
    return NSIntegerMax;
}

/// Do a shallow copy of the flat data members of this Visit onto the target visit.
-(void) copyOnto: (Visit *)target {
    target.patientIdent = self.patientIdent;
    target.chiefComplaint = self.chiefComplaint;
    target.historyPresentIllness = self.historyPresentIllness;
    target.impression = self.impression;
    target.physicalExam = self.physicalExam;
    target.plan = self.plan;
    target.createdDateTime = self.createdDateTime;
    target.calledinDateTime = self.calledinDateTime;
}

-(void) dealloc {
    self.prescriptions = nil;
    self.patient = nil;
    self.patientIdent = nil;
    self.chiefComplaint = nil;
    self.historyPresentIllness = nil;
    self.impression = nil;
    self.physicalExam = nil;
    self.plan = nil;
    self.createdDateTime = nil;
    self.calledinDateTime = nil;
    [ident release];
    [reportHeader release];
    [reportFooter release];
    [visitHeader release];
    [visitBodyRepeat release];
    [visitBodyClose release];
    [visitFooter release];
    [rxSectionHeader release];
    [rxSectionFooter release];
    reportHeader = nil;
    reportFooter = nil;
    visitHeader = nil;
    visitBodyRepeat = nil;
    visitBodyClose = nil;
    visitFooter = nil;
    rxSectionHeader = nil;
    rxSectionFooter = nil;
    
    [super dealloc];
}


#pragma mark NSCopying Methods

/// Create a pseudo-deep copy of this Visit with a new Ident.
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    Visit *copy = [[Visit alloc] init];
    // Just get a new array holding the same prescriptions.
    copy.prescriptions = [NSMutableArray arrayWithArray:self.prescriptions];
    copy.chiefComplaint = [[self.chiefComplaint copy] autorelease];
    copy.historyPresentIllness = [[self.historyPresentIllness copy] autorelease];
    copy.impression = [[self.impression copy] autorelease];
    copy.physicalExam = [[self.physicalExam copy] autorelease];
    copy.plan = [[self.plan copy] autorelease];
    copy.createdDateTime = [[self.createdDateTime copy] autorelease];
    copy.calledinDateTime = [[self.calledinDateTime copy] autorelease];
    copy.wasCalledIn = wasCalledIn;
    
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    self = [super init];
    
    ident = [[decoder decodeObjectForKey:identKey] retain];
    self.patientIdent = [decoder decodeObjectForKey:patientIdentKey];
    
    self.chiefComplaint = [decoder decodeObjectForKey:chiefComplaintKey];
    if (!chiefComplaint) {
        self.chiefComplaint = @"";
    }
    self.historyPresentIllness = [decoder decodeObjectForKey:historyPresentIllnessKey];
    if (!historyPresentIllness) {
        self.historyPresentIllness = @"";
    }
    self.impression = [decoder decodeObjectForKey:impressionKey];
    if (!impression) {
        self.impression = @"";
    }
    self.physicalExam = [decoder decodeObjectForKey:physicalExamKey];
    if (!physicalExam) {
        self.physicalExam = @"";
    }
    self.plan = [decoder decodeObjectForKey:planKey];
    if (!plan) {
        self.plan = @"";
    }
    
    //TODO: Set Timezone info as current TZ, not saved TZ
    self.createdDateTime = [decoder decodeObjectForKey:createdDateTimeKey];
    //TODO: Set Timezone info as current TZ, not saved TZ
    self.calledinDateTime = [decoder decodeObjectForKey:calledinDateTimeKey];
    
    self.prescriptions = [NSMutableArray array];
    // Need to convert Prescription idents into Prescription instances.
    NSMutableArray *rxIdents = [[decoder decodeObjectForKey:prescriptionsKey] retain];
    if (rxIdents) {
        for (NSString *rxIdent in rxIdents) {
            // Do not need to retain this object.
            Prescription *rx = [[ApplicationSupervisor instance] prescriptionWithIdent: rxIdent];
            if (rx) {
                [self.prescriptions addObject: rx];
                // Set the reverse reference.
                rx.visit = self;
            }
            else {
                NSLog(@"ERROR: Failed to load referenced Prescription with ident %@", rxIdent);
            }
        } 
        [rxIdents release];
    }
    
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:ident forKey:identKey];
    [coder encodeObject:patient.ident forKey:patientIdentKey];
    
    if (chiefComplaint && ![chiefComplaint isEqualToString:@""]) {
        [coder encodeObject:chiefComplaint forKey:chiefComplaintKey];
    }
    if (historyPresentIllness && ![historyPresentIllness isEqualToString:@""]) {
        [coder encodeObject:historyPresentIllness forKey:historyPresentIllnessKey];
    }
    if (physicalExam && ![physicalExam isEqualToString:@""]) {
        [coder encodeObject:physicalExam forKey:physicalExamKey];
    }
    if (impression && ![impression isEqualToString:@""]) {
        [coder encodeObject:impression forKey:impressionKey];
    }
    if (plan && ![plan isEqualToString:@""]) {
        [coder encodeObject:plan forKey:planKey];
    }
    if (createdDateTime) {
        [coder encodeObject:createdDateTime forKey:createdDateTimeKey];
    }
    if (calledinDateTime) {
        [coder encodeObject:calledinDateTime forKey:calledinDateTimeKey];
    }
    
    if (prescriptions && [prescriptions count] > 0) {
        // Only serializing the prescription idents here.
        NSMutableArray *rxIdents = [[NSMutableArray alloc] init];
        for (Prescription *rx in prescriptions) {
            [rxIdents addObject: rx.ident];
        }
        [coder encodeObject:rxIdents forKey:prescriptionsKey]; 
        [rxIdents release];
    }
}


#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:createdDateTimeKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:calledinDateTimeKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:chiefComplaintKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:historyPresentIllnessKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:physicalExamKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:impressionKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:planKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:visitNumberKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:prescriptionsKey options:NSKeyValueChangeRemoval | NSKeyValueChangeInsertion context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath:createdDateTimeKey];
        [self removeObserver:observer forKeyPath:calledinDateTimeKey];
        [self removeObserver:observer forKeyPath:chiefComplaintKey];
        [self removeObserver:observer forKeyPath:historyPresentIllnessKey];
        [self removeObserver:observer forKeyPath:physicalExamKey];
        [self removeObserver:observer forKeyPath:impressionKey];
        [self removeObserver:observer forKeyPath:planKey];
        [self removeObserver:observer forKeyPath:visitNumberKey];
        [self removeObserver:observer forKeyPath:prescriptionsKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
