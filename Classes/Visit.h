//
//  Visit.h
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "ObservableMutableArray.h"
#import "PropertyChangePublisher.h"
@class Patient;
@class Prescription;

/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vVisit = 1;

static NSString *const chiefComplaintKey = @"chiefComplaint";
static NSString *const createdDateTimeKey = @"createdDateTime";
static NSString *const calledinDateTimeKey = @"calledinDateTime";
static NSString *const historyPresentIllnessKey = @"historyPresentIllness";
static NSString *const physicalExamKey = @"physicalExam";
static NSString *const impressionKey = @"impression";
static NSString *const planKey = @"plan";
static NSString *const wasCalledInKey = @"wasCalledIn";

typedef struct  {
    NSString *chiefComplaint;
    NSString *historyPresentIllness;
    NSString *physicalExam;
    NSString *impression;
    NSString *plan;
    NSDate *createdDateTime;
    NSDate *calledinDateTime;
} VisitDetails;

@interface Visit : NSObject <NSCoding, NSCopying, PropertyChangePublisher> {
@private
    GUID ident;
    GUID patientIdent;
    Patient *patient;
    int visitNumber;
    NSDate *createdDateTime;
    NSDate *calledinDateTime;
    NSMutableArray *prescriptions;
    NSString *chiefComplaint;
    NSString *historyPresentIllness;
    NSString *physicalExam;
    NSString *impression;
    NSString *plan;
    BOOL wasCalledIn;
}

/*
 */
@property (nonatomic, assign, readonly) int visitNumber;

@property (nonatomic, readonly) GUID ident;

@property (nonatomic, retain) GUID patientIdent;

/*
 */
@property (nonatomic, retain) Patient *patient;

@property (nonatomic, assign) BOOL wasCalledIn;

/*
 */
@property (nonatomic, retain) NSDate *createdDateTime;

@property (nonatomic, retain) NSDate *calledinDateTime;

/*
 */
@property (nonatomic, retain) NSMutableArray *prescriptions;

/*
 */
@property (nonatomic, retain) NSString *chiefComplaint;

/*
 */
@property (nonatomic, retain) NSString *historyPresentIllness;

/*
 */
@property(nonatomic, retain) NSString *physicalExam;

/*
 */
@property(nonatomic, retain) NSString *impression;

/*
 */
@property(nonatomic, retain) NSString *plan;

-(id) initWithPatient: (Patient *)p andPrescriptions: (NSArray *)rxs andDetails: (VisitDetails)details;

-(id) initWithIdent: (GUID)anIdent;

-(NSString *) getCreationDateAsString;

-(NSString *) getCreationDateTimeAsString;

-(NSString *) getCallInDateTimeAsString;

-(NSString *) toHtmlReportStringWithTitle: (NSString *)title;

-(NSString *) toHtmlFragmentReportString;

/// Do a shallow copy of the flat data members of this Visit onto the target visit.
-(void) copyOnto: (Visit *)target;

-(void) addPrescription: (Prescription *)p;

-(void) removePrescription: (Prescription *)p;

-(NSComparisonResult) compare: (id)otherObject;

-(NSComparisonResult) reverseCompare: (id)otherObject;

-(void) addPropertyChangeObserver: (NSObject *)observer;

-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
