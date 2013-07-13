//
//  Patient.h
//  CurbSide
//
//  Created by Greg Walker on 2/28/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "NamedDataModel.h"
#import "PropertyChangePublisher.h"
@class Visit;
@class Pharmacy;
@class Contact;

/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vPatient = 1;

@interface Patient : NSObject <NSCoding, NSCopying, PropertyChangePublisher, NamedDataModel> {
@private 
    GUID ident;
    NSString *firstName;
    NSString *lastName;
    Contact *contactInfo;
    Pharmacy *defaultPharmacy;
    NSDate *dateOfBirth;
    NSMutableArray *allergies;
    NSMutableArray *pharmacies;
    NSMutableArray *priorVisits;
    NSMutableArray *medications;
}

@property(nonatomic, readonly) GUID ident;

@property(nonatomic, retain) Pharmacy *defaultPharmacy;

@property(nonatomic, readonly) NSString *fullName;

/*
 */
@property(nonatomic, retain) NSString *firstName;

/*
 */
@property(nonatomic, retain) NSString *lastName;

/*
 */
@property(nonatomic, retain) Contact *contactInfo;

/*
 */
@property(nonatomic, retain) NSDate *dateOfBirth;

/*
 */
@property(nonatomic, readonly) NSInteger age;

/*
 */
@property(nonatomic, retain) NSMutableArray *allergies;

/*
 */
@property(nonatomic, retain) NSMutableArray *pharmacies;

/*
 */
@property(nonatomic, retain) NSMutableArray *priorVisits;

/*
 */
@property(nonatomic, retain) NSMutableArray *medications;

-(id) initWithIdent: (GUID)anIdent;

/**
 */
-(NSString *) getBirthdayAsString;

/**
 */
-(NSString *) ageAsString;

-(NSString *) toHtmlReportStringWithTitle: (NSString *)title;

-(NSComparisonResult) compareByFullName: (id)comparisonObject;

/* Tests whether the Patient is equivalent to another by virtue of it's property values.
 */
-(BOOL) isEquivalent: (Patient *)p;

/// Add the given Visit and then issue a
/// change notification on the Visit collection.
-(void) addVisit: (Visit *)v;

/// Remove the given Visit if it belongs to this Patient, and then issue a
/// change notification on the Visit collection.
-(void) removeVisit: (Visit *)v;

/// Add the given allergy and then issue a
/// change notification on the allergy collection.
-(void) addAllergy: (NSString *)a;

/// Remove the given allergy if it belongs to this Patient, and then issue a
/// change notification on the allergy collection.
-(void) removeAllergy: (NSString *)a;

/// Add the given medication and then issue a
/// change notification on the current medication collection.
-(void) addMedication: (NSString *)m;

/// Remove the given medication if it belongs to this Patient, and then issue a
/// change notification on the current medication collection.
-(void) removeMedication: (NSString *)m;

-(void) addPharmacy: (Pharmacy *)p;
-(void) removePharmacy: (Pharmacy *)p;

/**
 */
//-(void) addPropertyChangeObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;

/** 
 */
-(void) addPropertyChangeObserver: (NSObject *)observer;

/**
 */
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
