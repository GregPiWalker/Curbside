//
//  VisitHistoryDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VisitHistoryDataSource.h"
#import "Constants.h"
#import "Visit.h"
#import "Patient.h"


@interface VisitHistoryDataSource () 

-(void) sortHistoryData;

-(NSString *) findSectionKeyForItem: (id)historyItem;

-(void) subscribeToAppNotifications: (BOOL)yesNo;

-(void) handleVisitUpdated: (NSNotification *)notification;

-(void) handleDateSortSettingChanged: (NSNotification *)notification;

-(BOOL) doesSearchPhraseMatchVisit: (Visit *)v;

@end


@implementation VisitHistoryDataSource

@synthesize immutable;
//@synthesize filteredData;
//@synthesize searchPhrase;
//-(void) setSearchPhrase: (NSString *)value {
//    if (value && [searchPhrase isEqualToString: value]) {
//        return;
//    }
//    [searchPhrase release];
//    searchPhrase = [value retain];
//    
//    //Set the filter data and reload the tableview.
//    if (searchPhrase && [searchPhrase length] > 0) {
//        [self applySearchFilter];
//    }
//    else {
//        self.filteredData = nil;
//    }
//    [tableView reloadData];
//    self.isReloadNeeded = NO;
//}

#pragma mark Methods

-(id) init {
    return [self initWithHistory: [NSArray array]];
}

/** initWithHistory
 */
-(id) initWithHistory: (NSArray *)history {
    self = [super init];
    if (self) {  
        immutable = NO;
        if (history && [history count] > 0) {
            [historyData addObjectsFromArray: history];
            [self sortHistoryData];
            [self applySearchFilter];
            [self subscribeToAppNotifications: YES];
        }
    }
    return self;
}

/// sortHistoryData
/// This operates on the filtered data only.
-(void) sortHistoryData {
    NSArray *data = [NSArray arrayWithArray: historyData];
    [historyData removeAllObjects];
    NSComparisonResult sortOrder = [ApplicationSupervisor instance].dateSortOrderSetting;
    // First, sort and hold the collection of Visits by date.
    if (sortOrder == NSOrderedAscending) {
        [historyData addObjectsFromArray: [data sortedArrayUsingSelector: @selector(compare:)]];
    }
    else {
        [historyData addObjectsFromArray: [data sortedArrayUsingSelector: @selector(reverseCompare:)]];
    }
}

-(NSString *) findSectionKeyForItem: (id)historyItem {
    // Cannot obtain the section and date from the item because it's creation date may have been altered.
    
    // First remove the visit from the sectioned data collection.
    NSSet *sections = [filteredDataGroups keysOfEntriesPassingTest: ^BOOL(id key, id obj, BOOL *stop) {
        if ([((NSArray *)obj) containsObject: historyItem]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    // At most, one value held in the set.
    NSString *found = [sections anyObject];
    if (!found) {
        found = @"";
    }
    return found;
}

/**
 */
-(NSString *) cellDescriptionForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    NSArray *section = [filteredDataGroups objectForKey: sectionTitle];
    Visit *v = [section objectAtIndex: row];
    return v.patient.fullName;
}

-(NSString *) cellTextForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat: kDateTimeAmPmFormatterFormat];
    NSArray *section = [filteredDataGroups objectForKey: sectionTitle];
    Visit *v = [section objectAtIndex: row];
    return [dateFormatter stringFromDate: v.createdDateTime];
}

-(void) tableView: (UITableView *)tv commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            self.selectedIndexPaths = [NSArray arrayWithObject: indexPath];
            [self showDeletionDialog];
            break;
            
        default:
            self.selectedIndexPaths = [NSArray arrayWithObject: indexPath];
            break;
    }
}


#pragma mark HistoryDataSource Methods

/// addHistoryItem
///
-(void) addHistoryItem: (id)historyItem {
    Visit *v = (Visit *)historyItem;
    // First just add to the data collection and re-sort it.
    [historyData addObject: v];
    [self sortHistoryData];
    
    // If the new visit fits in the current search criteria, add it to the filtered data too.
    // This is verbose for the purpose of only having to re-sort one section rather than all of the sections.
    if ([self doesSearchPhraseMatchVisit: v]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        // Create a date using only the month and year, then add it to the collection if it's not already in there.
        NSDateComponents *dateComponents = [calendar components: NSMonthCalendarUnit | NSYearCalendarUnit fromDate: v.createdDateTime];
        NSComparisonResult sortOrder = [ApplicationSupervisor instance].dateSortOrderSetting;
        NSDate *sectionDate = [calendar dateFromComponents: dateComponents];
        NSString *sectionTitle = [self sectionTitleFromDate: sectionDate];
        
        // If no section yet exists for the Month/Year combo, create a new one.
        if (![orderedFilteredDates containsObject: sectionDate]) {
            [orderedFilteredDates addObject: sectionDate];
            
            if (sortOrder == NSOrderedAscending) {
                [orderedFilteredDates sortUsingSelector:@selector(compare:)];
            }
            else {
                [orderedFilteredDates sortUsingSelector:@selector(reverseCompare:)];
            }
            // Add a new empty section and key to the sectioned data collection.
            [filteredDataGroups setObject: [NSMutableArray array] forKey: sectionTitle];
        }
        
        // Add the visit to the sectioned data collection.
        NSMutableArray *section = [filteredDataGroups objectForKey: sectionTitle];
        [section addObject: v];
        // Finally, re-sort and assign the keyed section data array.
        if (sortOrder == NSOrderedAscending) {
            [filteredDataGroups setObject:[NSMutableArray arrayWithArray:[section sortedArrayUsingSelector:@selector(compare:)]] forKey:sectionTitle];
        }
        else {
            [filteredDataGroups setObject:[NSMutableArray arrayWithArray:[section sortedArrayUsingSelector:@selector(reverseCompare:)]] forKey:sectionTitle];
        }
        
        // Only the affected section was modified, just mark the view as dirty.
        self.isReloadNeeded = YES;
    }
}

/// Remove the specified history item from the data type that supports this data source.
-(BOOL) removeHistoryItem: (id)historyItem {
    BOOL success = NO;
    // First handle the pre-sorted data.
    if ([historyData containsObject: historyItem]) {
        [historyData removeObject: historyItem];
        success = YES;
    }
    
    // Keep the filtered search data up-to-date too. This is easier and less work than re-applying the search algorithm.
    NSString *sectionKey = [self findSectionKeyForItem: historyItem];
    NSMutableArray *filteredSection = [filteredDataGroups objectForKey: sectionKey];
    if (filteredSection) {
        [filteredSection removeObject: historyItem];
        // If the section is empty, clean house.
        if ([filteredSection count] == 0) {
            [filteredDataGroups removeObjectForKey: sectionKey];
            // Remove the date from the ordered filtered dates.
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: kMonthYearDateFormat];
            NSDate *sectionDate = [dateFormatter dateFromString: sectionKey];
            [dateFormatter release];
            [orderedFilteredDates removeObject: sectionDate];
        }
        self.isReloadNeeded = YES;
    }
    
    return success;
}

/// Perform application-wide deletion of the item at the specified IndexPath.
-(void) deleteItemAtIndexPath: (NSIndexPath *)indexPath {
    Visit *v = [[self getVisitForTableView: self.tableView atIndexPath: indexPath] retain];
    // The supporting data must have one cell less before the TableView is modified.
    [self removeHistoryItem: v];
    // Remove from the tableview.
    [self.tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: YES];
    // Notify the ApplicationSupervisor.
    [[ApplicationSupervisor instance] deleteVisit: v];
    [v release];
}

/**
 */
-(Visit *) getVisitForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)path {
    NSString *sectionTitle = [self tableView:tv titleForHeaderInSection:path.section];
    NSArray *section  = [filteredDataGroups objectForKey: sectionTitle];
    
    return [section objectAtIndex: path.row];
}


#pragma mark Search Filtering

-(void) applySearchFilter {
    [filteredDataGroups removeAllObjects];
    [orderedFilteredDates removeAllObjects];
    NSString *sectionTitle = nil;
    NSDate *sectionDate = nil;
    NSDateComponents *dateComponents = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (Visit *v in historyData) {
        if ([self doesSearchPhraseMatchVisit: v]) {
            dateComponents = [calendar components: NSMonthCalendarUnit | NSYearCalendarUnit fromDate: v.createdDateTime];
            // Create a date using only the month and year, then add it to the collection if it's not already in there.
            sectionDate = [calendar dateFromComponents: dateComponents];
            sectionTitle = [self sectionTitleFromDate: sectionDate];
            
            if (![orderedFilteredDates containsObject: sectionDate]) {
                // Create a new section title.
                [orderedFilteredDates addObject: sectionDate];
                // Add the new section key to the filtered sectioned data collection.
                [filteredDataGroups setObject: [NSMutableArray array] forKey: sectionTitle];
            }
            // Now add the visit to the filtered sectioned data collection.
            [[filteredDataGroups objectForKey: sectionTitle] addObject: v];
            
            self.isReloadNeeded = YES;
        }
    }
}

-(BOOL) doesSearchPhraseMatchVisit: (Visit *)v {
    if (!searchPhrase || [searchPhrase length] == 0) {
        return YES;
    }
    
    NSMutableArray *searchComponents = [NSMutableArray arrayWithArray:[self.searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    // Get rid of null strings from the search components.
    [searchComponents filterUsingPredicate: [NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    
    // First, make a search on the Patient's name.
    NSMutableArray *referenceValues = [NSMutableArray arrayWithArray:[v.patient.fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    // Get rid of null strings.
    [referenceValues filterUsingPredicate: [NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    // Now add date formatted and name symbol date-time values from the visit's creation date.
    [dFormatter setDateFormat: kTimeFormatterFormat];
    [referenceValues addObject: [dFormatter stringFromDate: v.createdDateTime]];
    [dFormatter setDateFormat: kDateFormatterFormat];
    [referenceValues addObject: [dFormatter stringFromDate: v.createdDateTime]];
    [dFormatter setDateFormat: kYearFormatterFormat];
    [referenceValues addObject: [dFormatter stringFromDate: v.createdDateTime]];
    [dFormatter setDateFormat: kMonthFormatterFormat];
    [referenceValues addObject: [dFormatter stringFromDate: v.createdDateTime]];
    [dFormatter setDateFormat: kDayFormatterFormat];
    [referenceValues addObject: [dFormatter stringFromDate: v.createdDateTime]];
    [dFormatter release];
    
    for (int i = [searchComponents count] - 1; i >= 0; i--) {
        NSString *searchTerm = [searchComponents objectAtIndex:i];
        // Search every term and make sure each one appears at the beginning of a value in the list of reference values.
        for (NSString *nameTerm in referenceValues) {
            if ([nameTerm hasPrefix: [searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] options: NSCaseInsensitiveSearch]) {
                [searchComponents removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    // Return a match only if all search terms were present as prefixes in the acceptable reference terms.
    return [searchComponents count] == 0;
}


#pragma mark Memory Management Methods
             
-(void) dealloc {
    [self subscribeToAppNotifications: NO];
    
    [super dealloc];
}


#pragma mark Event Handling

-(void) handleVisitUpdated: (NSNotification *)notification {
    // Only respond if this DataSource is editable (not immutable)
    if (!immutable) {
        // Only add it back in if it was found here in the first place.
        if ([self removeHistoryItem: [notification object]]) {
            [self addHistoryItem: [notification object]];
            [self.tableView reloadData];
        }
    }
}

-(void) handleDateSortSettingChanged: (NSNotification *)notification {
    [self sortHistoryData];
    [self applySearchFilter];
    [self reloadTableData];
}
         
 ///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addVisitUpdatedObserver: self withHandler: @selector(handleVisitUpdated:)];
        [[ApplicationSupervisor instance] addDateSortSettingChangedObserver: self withHandler: @selector(handleDateSortSettingChanged:)];
    }
    else {
        [[ApplicationSupervisor instance] removeVisitUpdatedObserver: self];
        [[ApplicationSupervisor instance] removeDateSortSettingChangedObserver: self];
    }
}

@end
