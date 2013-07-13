//
//  PharmacyLookupDataSource.m
//  Curbside
//
//  Created by Greg Walker on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PharmacyLookupDataSource.h"
#import "Contact.h"
#import "Pharmacy.h"

@interface PharmacyLookupDataSource ()

-(void) populateList;

-(void) handlePharmacyCreated: (NSNotification *)notification;

-(void) handlePharmacyDeleted: (NSNotification *)notification;

-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end

@implementation PharmacyLookupDataSource

@synthesize pharmacyList;
@dynamic selectedPharmacy;
-(Pharmacy *) selectedPharmacy {
    return (Pharmacy *)selectedItem;
}
-(void) setSelectedPharmacy: (Pharmacy *)value {
    self.selectedItem = value;
}


- (id)init {
    self = [super init];
    if (self) {
        [self populateList];
        [self subscribeToAppNotifications: YES];
    }
    
    return self;
}

-(void) populateList {
    self.pharmacyList = [NSMutableArray array];
    for (Pharmacy *p in [ApplicationSupervisor instance].pharmacies) {
        [pharmacyList addObject: [[p copyExactly] autorelease]];
    }
}

-(void) dealloc {
    [self subscribeToAppNotifications: NO];
    self.pharmacyList = nil;
    
    // The super class handles memory of selectedItem and tableData.
    [super dealloc];
}


#pragma mark UITableViewDataSource Methods

/// cellForRowAtIndexPath
///
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    PharmacyTableViewCell *cell = [TableCellFactory createPharmacyCellForTable: tv
                                                                withIdentifier: @"SimplePharmacyCell" 
                                                                       withTag: indexPath.row];
    // set the pharmacy for this cell as specified by the data filtered from the PharmacyListDataSource.
    cell.pharmacy = [self.tableData objectAtIndex:indexPath.row];
    
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
    // Pharmacy is always NIL until editing is done.
    self.selectedPharmacy = nil;
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
        
        // Find and set the new matching pharmacies.
        NSRange matchRange;
        matchRange.location = 0;
        matchRange.length = [matchValue length];
                
        // Build a collection of all Pharmacies whose name is partially matched by the TextField text.
        for (Pharmacy *p in pharmacyList) {
            // Optionally, later I might add the address in so that it is searched too.
            NSString *wholeName = p.name;
            if ([wholeName length] >= matchRange.length
                && [wholeName compare:matchValue options:NSCaseInsensitiveSearch range:matchRange] == NSOrderedSame) {
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

-(void) handlePharmacyCreated: (NSNotification *)notification {
    Pharmacy *p = [notification object];
    [self.pharmacyList addObject: p];
}

-(void) handlePharmacyDeleted: (NSNotification *)notification {
    Pharmacy *p = [notification object];
    [self.pharmacyList removeObject: p];
    if (selectedItem == p) {
        self.selectedItem = nil;
    }
}

-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addPharmacyCreatedObserver:self withHandler:@selector(handlePharmacyCreated:)];
        // Don't listen to update: Assuming that the TableView will not be visible while a contact is updated.
        [[ApplicationSupervisor instance] addPharmacyDeletedObserver:self withHandler:@selector(handlePharmacyDeleted:)];
    }
    else {
        [[ApplicationSupervisor instance] removePharmacyCreatedObserver:self];
        [[ApplicationSupervisor instance] removePharmacyDeletedObserver:self];
    }
}

@end
