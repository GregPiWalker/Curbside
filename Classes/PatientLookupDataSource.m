//
//  LookupTableDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatientLookupDataSource.h"
#import "Patient.h"

@interface PatientLookupDataSource ()

-(void) handlePatientCreated: (NSNotification *)notification;

-(void) handlePatientDeleted: (NSNotification *)notification;

-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end

@implementation PatientLookupDataSource


@synthesize sortedPatients;
static NSString *const selectedPatientKey = @"selectedPatient";
//TODO: make a setter that uses a copy of the supplied patient.
@dynamic selectedPatient;
-(Patient *) selectedPatient {
    return (Patient *)selectedItem;
}
-(void) setSelectedPatient: (Patient *)value {
    self.selectedItem = value;
}


-(id) init {
    self = [super init];
    if (self) {
        sortedPatients = [[PatientsByNameDataSource alloc] init];
        // Subscribe last, after data sources are set up.
        [self subscribeToAppNotifications: YES];
    }
    return self;
}

-(void) dealloc {
    [self subscribeToAppNotifications: NO];
    self.sortedPatients = nil;
    [super dealloc];
}


#pragma mark UITableViewDataSource Methods

/// cellForRowAtIndexPath
///
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    PatientTableViewCell *cell = [TableCellFactory createEmphasizedPatientCellForTable: tv 
                                                                        withEmphasisOn: self.lookupTextField.text
                                                                        withIdentifier: @"SimplePatientCell" 
                                                                               withTag: indexPath.row];
    // set the patient for this cell as specified by the data filtered from the PatientListDataSource.
    cell.patient = [self.tableData objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark UITextFieldDelegate Methods

/// shouldChangeCharactersInRange
///
/// Uses the character change of the field of interest to modify contents of the data source.
-(BOOL) textField: (UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacement {
    if (self.lookupTextField == nil) {
        self.lookupTextField = tf;
    }
    // Patient is always NIL until editing is done.
    self.selectedPatient = nil;
    BOOL contentsDidChange = NO;
    
    NSString *matchValue;
    if ([tf.text length] > 0) {
        matchValue = [tf.text stringByReplacingCharactersInRange:range withString:replacement];
    }
    else {
        matchValue = replacement;
    }
    // Get rid of any white space.
    matchValue = [matchValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Clear previous values.
    if ([self.tableData count] > 0) {
        contentsDidChange = YES;
    }
    [self.tableData removeAllObjects];
    // Add matching values back in, if there are any.
    if ([matchValue length] > 0) {
        
        // Find and set the new matching patients.
        NSRange matchRange;
        matchRange.location = 0;
        matchRange.length = [matchValue length];
        NSString *index = [matchValue substringToIndex:1];
        NSArray *firstMatches = [self.sortedPatients getSectionReadonlyForFirstNameKey:index];
        NSArray *lastMatches = [self.sortedPatients getSectionReadonlyForLastNameKey:index];
        
        //TODO: CAN USE THE SEARCH PHRASE FILTER FEATURE OF PatientsListDataSource NOW, RATHER THAN CUSTOM LOGIC BELOW.
        //sortedPatients.searchPhrase = matchValue;
        //[[sortedPatients filteredData] allValues]
        
        // Build a collection of all Patients whose full name is partially matched by the TextField text.
        for (Patient *p in firstMatches) {
            NSString *wholeName = [NSString stringWithFormat:@"%@%@", p.firstName, p.lastName];
            if ([wholeName length] >= matchRange.length
                && [wholeName compare:matchValue options:NSCaseInsensitiveSearch range:matchRange] == NSOrderedSame) {
                [self.tableData addObject:p];
                contentsDidChange = YES;
            }
        }
        // Now add any remaining partial matches for the last name only.
        for (Patient *p in lastMatches) {
            if (![self.tableData containsObject:p]
                && [p.lastName length] >= matchRange.length
                && [p.lastName compare:matchValue options:NSCaseInsensitiveSearch range:matchRange] == NSOrderedSame) {
                [self.tableData addObject:p];
                contentsDidChange = YES;
            }
        }
    }
    if (contentsDidChange) {
        //[self.tableView reloadData];
    }
    
    return YES;
}


#pragma mark Event Handling

-(void) handlePatientCreated: (NSNotification *)notification {
    Patient *p = [notification object];
    [self.sortedPatients addPatient: p];
}

-(void) handlePatientDeleted: (NSNotification *)notification {
    Patient *p = [notification object];
    [self.sortedPatients removePatient: p];
}

-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addPatientCreatedObserver:self withHandler:@selector(handlePatientCreated:)];
        // Don't listen to update: Assuming that the TableView will not be visible while a patient is updated.
        [[ApplicationSupervisor instance] addPatientDeletedObserver:self withHandler:@selector(handlePatientDeleted:)];
    }
    else {
        [[ApplicationSupervisor instance] removePatientCreatedObserver:self];
        [[ApplicationSupervisor instance] removePatientDeletedObserver:self];
    }
}

@end
