//
//  MedicationLookupDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedicationLookupDataSource.h"


@implementation MedicationLookupDataSource

@synthesize medicationTextField;
@synthesize selectedMedication;
@synthesize tableData;
@synthesize useExistingMedication;
@synthesize numberOfRows;
@synthesize numberOfVisibleRows;


-(void) dealloc {
    self.medicationTextField = nil;
    self.selectedMedication = nil;
    self.tableData = nil;
    [super dealloc];
}

#pragma mark UITableViewDataSource Methods

/// cellForRowAtIndexPath
///
-(UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    /*PatientTableViewCell *cell = [TableCellFactory createEmphasizedPatientCellForTable:tableView 
                                                                        withEmphasisOn:self.patientTextField.text
                                                                        withIdentifier:@"SimplePatientCell" 
                                                                               withTag:indexPath.row];
    // set the patient for this cell as specified by the data filtered from the PatientListDataSource.
    cell.patient = [self.tableData objectAtIndex:indexPath.row];
    
    return cell;*/
    return nil;
}

/// sectionForSectionIndexTitle
///
-(NSInteger) tableView: (UITableView *)tableView sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    return index;
}

/// numberOfRowsInSection
///
-(NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)sectionIndex {
    // OK to resize table here since there is only one section.
    numberOfRows = [self.tableData count];
    if (numberOfRows <= numberOfVisibleRows) {
        // Resize tableView.
        CGRect tableFrame = tableView.frame;
        tableFrame.size.height = tableView.rowHeight * numberOfRows;
        tableView.frame = tableFrame;
    }
    
    return self.numberOfRows;
}

/// titleForHeaderInSection
///
-(NSString *) tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)sectionIndex {
    return @"";
}

/// numberOfSectionsInTableView
///
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

/// sectionIndexTitlesForTableView
///
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *)tableView {
    // Return nil so that the index is not created.
    return nil;
}


#pragma mark UITableViewDelegate

/// didSelectRowAtIndexPath
///
-(void) tableView: (UITableView *)selectedTableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    NSString *selected = nil;
    if (self.medicationTextField) {
        // Find the medication for the selected row.
        selected = [self.tableData objectAtIndex:indexPath.row];
        
        // Set the textField text to the text of the selected row.
        self.medicationTextField.text = selected;
        self.useExistingMedication = YES;
    }
    self.selectedMedication = selected;
    // Dismiss the keyboard.
    [self.medicationTextField resignFirstResponder];
}


#pragma mark UITextFieldDelegate Methods

/// shouldChangeCharactersInRange
///
/// This responds only to the Patient TextField.
-(BOOL) textField: (UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacement {
    if (self.medicationTextField == nil) {
        self.medicationTextField = tf;
    }
    
    // Medication is always NIL until editing is done.
    self.selectedMedication = nil;
    
    NSString *matchValue;
    if ([tf.text length] > 0) {
        matchValue = [tf.text stringByReplacingCharactersInRange:range withString:replacement];
    }
    else {
        matchValue = replacement;
    }
    // Get rid of any white space.
    matchValue = [matchValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    /*
    // Clear previous values.
    [self.tableData removeAllObjects];
    // Add matching values back in, if there are any.
    if ([matchValue length] > 0) {
        
        // Find and set the new matching patients.
        NSRange matchRange;
        matchRange.location = 0;
        matchRange.length = [matchValue length];
        NSString *index = [matchValue substringToIndex:1];
        NSArray *firstMatches = [self.sortedPatients getSectionForFirstNameKey:index];
        NSArray *lastMatches = [self.sortedPatients getSectionForLastNameKey:index];
        
        // Build a collection of all Patients whose full name is partially matched by the TextField text.
        for (Patient *p in firstMatches) {
            NSString *wholeName = [NSString stringWithFormat:@"%@%@", p.firstName, p.lastName];
            if ([wholeName length] >= matchRange.length
                && [wholeName compare:matchValue options:NSCaseInsensitiveSearch range:matchRange] == NSOrderedSame) {
                [self.tableData addObject:p];
            }
        }
        // Now add any remaining partial matches for the last name only.
        for (Patient *p in lastMatches) {
            if (![self.tableData containsObject:p]
                && [p.lastName length] >= matchRange.length
                && [p.lastName compare:matchValue options:NSCaseInsensitiveSearch range:matchRange] == NSOrderedSame) {
                [self.tableData addObject:p];
            }
        }
    }*/
    
    return YES;
}

#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:@"selectedMedication" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"useExistingMedication" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath:@"selectedMedication"];
        [self removeObserver:observer forKeyPath:@"useExistingMedication"];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
