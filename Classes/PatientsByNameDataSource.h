//
//  PatientsByNameDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationSupervisor.h"
#import "Patient.h"
#import "TableCellFactory.h"
#import "Utilities.h"


static NSString *const sortByLastNamePropertyKey = @"sortByLastName";


@interface PatientsByNameDataSource : NSObject <UITableViewDataSource, UISearchBarDelegate> {
    NSMutableDictionary *dataSortedOnFirstName;
    NSMutableDictionary *dataSortedOnLastName;
    NSMutableDictionary *filteredData;
    NSMutableArray *sectionTitlesByFirstName;
    NSMutableArray *sectionTitlesByLastName;
    NSString *searchPhrase;
    BOOL sortByLastName;
    UITableView *tableView;
}

/// dataSortedOnFirstName is a dictionary of arrays indexed by single characters.
/// Each contained array holds Patient objects alphabetized by first name.
@property (nonatomic, retain) NSMutableDictionary *dataSortedOnFirstName;

/// dataSortedOnLastName is a dictionary of arrays indexed by single characters.
/// Each contained array holds Patient objects alphabetized by last name.
@property (nonatomic, retain) NSMutableDictionary *dataSortedOnLastName;

/// A dictionary of group title keys and array values containing section data.
@property (nonatomic, retain) NSMutableDictionary *filteredData;

///
@property (nonatomic, retain) NSMutableArray *sectionTitlesByFirstName;

///
@property (nonatomic, retain) NSMutableArray *sectionTitlesByLastName;

@property (nonatomic, retain) NSString *searchPhrase;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, assign) BOOL sortByLastName;

-(void) addPatient: (Patient *)newPatient;
-(void) updatePatient: (Patient *)patient fromOldFirstName: (NSString *)oldFirst andLastName: (NSString *)oldLast;
-(void) removePatient: (Patient *)obsoletePatient;
-(Patient *) getPatientForPath: (NSIndexPath *)path;
-(NSIndexPath *) indexPathForPatient: (Patient *)p;
-(NSArray *) getSectionReadonlyForFirstNameKey: (NSString *)key;
-(NSArray *) getSectionReadonlyForLastNameKey: (NSString *)key;
-(NSArray *) getFilteredSectionTitles;

-(void) addPropertyChangeObserver: (NSObject *)observer;
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
