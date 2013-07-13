//
//  Prescription.h
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
@class Visit;

/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vPrescription = 1;

typedef struct  {
    NSString *medicationName;
    int numberOfRefills;
    int totalDispensed;
    NSString *dosage;
    NSString *usageFrequency;
    NSString *usagePeriod;
    NSString *usageUnits;
} PrescriptionDetails;


@interface Prescription : NSObject <NSCoding, NSCopying> {
@private 
    GUID ident;
    GUID visitIdent;
    Visit *visit;
    NSString *medication;
    NSString *dosage;
    NSString *usageFrequency;
    NSString *usagePeriod;
    NSString *usageUnits;
    int totalDispensed;
    int numRefills;
}

@property (nonatomic, readonly) GUID ident;

/// This property is only used for object persistence.
@property (nonatomic, retain) GUID visitIdent;

/// The visit property is during runtime, while visitIdent is used for persistence.
@property (nonatomic, retain) Visit *visit;

/*
 */
@property (nonatomic, retain) NSString *medication;

/*
 */
@property (nonatomic, retain) NSString *dosage;

/*
 */
@property (nonatomic, retain) NSString *usageFrequency;
@property (nonatomic, retain) NSString *usagePeriod;
@property (nonatomic, retain) NSString *usageUnits;

/*
 */
@property (nonatomic, assign) int totalDispensed;

/*
 */
@property (nonatomic, assign) int numRefills;

/**
 */
-(id) initFor: (Visit *)v withDetails: (PrescriptionDetails)details;

-(id) initWithIdent: (GUID)anIdent;

-(NSString *) toHtmlFragmentReportString;

@end
