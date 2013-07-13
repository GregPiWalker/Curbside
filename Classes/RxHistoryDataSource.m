//
//  RxHistoryDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RxHistoryDataSource.h"


@interface RxHistoryDataSource () 

-(void) populateHistoryData: (NSArray *)data;
    
@end


@implementation RxHistoryDataSource


#pragma mark Methods

-(id) init {
    return [self initWithHistory: [NSArray array]];
}

/** initWithHistory
 */
-(id) initWithHistory: (NSArray *)history {
    self = [super init];
    if (self) {
        if (history && [history count] > 0) {
            [self populateHistoryData: history];
        }
    }
    return self;
}

/** populateHistoryData
 */
-(void) populateHistoryData:(NSArray *)data {
    [sectionedData removeAllObjects];
    [orderedSectionDates removeAllObjects];
    
    // First, sort the lot of them.
    NSArray *sortedByDate = [[data sortedArrayUsingSelector: @selector(compare:)] retain];
    
    // Then build section titles from the sorted Prescriptions.
    NSString *sectionTitle;
    for (Prescription *rx in sortedByDate) {
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSMonthCalendarUnit | NSYearCalendarUnit fromDate: rx.visit.createdDateTime];
        sectionTitle = [NSString stringWithFormat: @"%@ %i", [EnumsToStrings monthComponentToString: dateComponents], [dateComponents year]];
        // Create a date using only the month and year, then add it to the collection if it's not already in there.
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDate *sectionDate = [gregorian dateFromComponents: dateComponents];
        
        if (![orderedSectionDates containsObject: sectionDate]) {
            // Create a new section title.
            [orderedSectionDates addObject: sectionDate];
            // Add the new section key to the sectioned data collection.
            [sectionedData setObject: [NSMutableArray array] forKey: sectionTitle];
        }
        // Now add the prescription to the sectioned data collection.
        [[sectionedData objectForKey: sectionTitle] addObject: rx];
    }
    
    [sortedByDate release];
}

/**
 */
-(NSString *) cellDescriptionForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    Prescription *rx = [[sectionedData objectForKey: sectionTitle] objectAtIndex:row];
    return rx.visit.patient.fullName;
}

-(NSString *) cellTextForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat: kDateTimeFormatterFormat];
    Prescription *rx = [[sectionedData objectForKey: sectionTitle] objectAtIndex: row];
    return [dateFormatter stringFromDate: rx.visit.createdDateTime];
}

/// Add a prescription to the data type that supports this data source.
-(void) addHistoryItem: (id)historyItem {
    Prescription *rx = (Prescription *)historyItem;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSMonthCalendarUnit | NSYearCalendarUnit fromDate: rx.visit.createdDateTime];
    NSString *sectionTitle = [NSString stringWithFormat: @"%@ %i", [EnumsToStrings monthComponentToString: dateComponents], [dateComponents year]];
    // Create a date using only the month and year, then add it to the collection if it's not already in there.
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDate *sectionDate = [gregorian dateFromComponents: dateComponents];
    
    if (![orderedSectionDates containsObject: sectionDate]) {
        [orderedSectionDates addObject: sectionDate];
        // Now need to re-sort orderedSectionDates collection.
        self.orderedSectionDates = [NSMutableArray arrayWithArray:[orderedSectionDates sortedArrayUsingSelector: @selector(compare:)]];
        // Add the new section key to the sectioned data collection.
        [sectionedData setObject: [NSMutableArray array] forKey: sectionTitle];
    }
    // Add the prescription to the sectioned data collection.
    NSMutableArray *section = [sectionedData objectForKey: sectionTitle];
    [section addObject: rx];
    // Finally, re-sort and assign the keyed section data array.
    [sectionedData setObject:[NSMutableArray arrayWithArray:[section sortedArrayUsingSelector:@selector(compare:)]] forKey:sectionTitle];
}

/// Remove a prescription from the data type that supports this data source.
-(BOOL) removeHistoryItem: (id)historyItem {
    //TODO:
    return NO;
}

/// Perform application-wide deletion of the item at the specified IndexPath.
-(void) deleteItemAtIndexPath: (NSIndexPath *)indexPath {
    //TODO:
}

/**
 */
-(Prescription *) getPrescriptionForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)path {
    NSString *sectionTitle = [self tableView:tv titleForHeaderInSection:path.section];
    Prescription *rx = [[sectionedData objectForKey: sectionTitle] objectAtIndex: path.row];
    return rx;
}


#pragma mark Memory Management Methods

-(void) dealloc {
    [super dealloc];
}

@end
