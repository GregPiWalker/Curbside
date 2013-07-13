//
//  HistoryDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryDataSource.h"


@implementation HistoryDataSource

#pragma mark Properties

@synthesize historyData;
@synthesize orderedFilteredDates;
@synthesize filteredDataGroups;
@synthesize isEditable;
@synthesize isReloadNeeded;
@synthesize selectedIndexPaths;

@synthesize searchPhrase;
-(void) setSearchPhrase: (NSString *)value {
    if (value && [searchPhrase isEqualToString: value]) {
        return;
    }
    [searchPhrase autorelease];
    searchPhrase = [value retain];
    
    //Set the filter data and reload the tableview.
    [self applySearchFilter];
    [self reloadTableData];
}

@synthesize tableView;
-(void) setTableView:(UITableView *)tv {
    if (tv == tableView) {
        return;
    }
    [tableView autorelease];
    tableView = [tv retain];
    if (tableView != nil) {
        tableView.dataSource = self;
    }
}


#pragma mark - Methods

-(id) init {
    self = [super init];
    if (self) {
        self.historyData = [NSMutableArray array];
        self.searchPhrase = @"";
        self.orderedFilteredDates = [NSMutableArray array];
        self.filteredDataGroups = [OrderedMutableDictionary dictionary];
        self.isEditable = NO;
        self.isReloadNeeded = NO;
        self.selectedIndexPaths = [NSArray array];
    }
    return self;
}

/** initWithHistory
 * This is just a base implementation that needs to be overridden.
 */
-(id) initWithHistory:(NSArray *)history {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

/**
 */
-(NSString *) sectionTitleFromDate: (NSDate *)sectionDate {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSMonthCalendarUnit | NSYearCalendarUnit fromDate: sectionDate];
    return [NSString stringWithFormat: @"%@ %i", [EnumsToStrings monthComponentToString: dateComponents], [dateComponents year]];
}

-(void) showDeletionDialog {
    UIAlertView *deleteView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" 
                                                         message:@"Deletion of this item is permanent." 
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel" 
                                               otherButtonTitles:@"Confirm", nil];
    [deleteView show];
    [deleteView release];
}

-(void) reloadTableData {
    if (isReloadNeeded) {
        [tableView reloadData];
        self.isReloadNeeded = NO;
    }
}

-(void) dealloc {
    self.orderedFilteredDates = nil;
    self.historyData = nil;
    self.selectedIndexPaths = nil;
    self.searchPhrase = nil;
    self.filteredDataGroups = nil;
    
    [super dealloc];
}


#pragma mark Search Filtering

///This is just a base implementation that needs to be overridden.
-(void) applySearchFilter {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

-(NSArray *) getFilteredSectionTitles {
    if (!searchPhrase || [searchPhrase length] == 0) {
        return [NSArray array];
    }
    
    // Return the sorted keys of the filtered collection.
    return [[self.filteredDataGroups allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


#pragma mark UISearchBarDelegate Methods

-(void) searchBarCancelButtonClicked: (UISearchBar *)sb {
    self.searchPhrase = nil;
    
    [tableView reloadData];
    self.isReloadNeeded = NO;
}

-(void) searchBar: (UISearchBar *)sb textDidChange: (NSString *)searchText {
    self.searchPhrase = searchText;
    [self applySearchFilter];
    [tableView reloadData];
    self.isReloadNeeded = NO;
}

-(void) searchBarSearchButtonClicked: (UISearchBar *)sb {
    // Just dismiss the keyboard;
    [sb resignFirstResponder];
}


#pragma mark UIAlertViewDelegate Methods

-(void) alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    // Only delete the patient if the Confirm button was clicked.
    if (alertView.cancelButtonIndex != buttonIndex) {
        for (NSIndexPath *path in self.selectedIndexPaths) {
            [self deleteItemAtIndexPath: path];
        }
    }
}


#pragma mark UITableView Content Management Methods

/**
 * This is just a base implementation that needs to be overridden.
 */
-(NSString *) cellDescriptionForTableView: (UITableView *)tv rowAtIndexPath: (NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

/// Add the specified history item to the data type that supports this data source.
-(void) addHistoryItem: (id)historyItem {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

/// Remove the specified history item from the data type that supports this data source.
-(BOOL) removeHistoryItem: (id)historyItem {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

/// Perform application-wide deletion of the item at the specified IndexPath.
-(void) deleteItemAtIndexPath: (NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}


#pragma mark UITableViewDataSource Methods

/** canEditRowAtIndexPath
 */
-(BOOL) tableView: (UITableView *)tv canEditRowAtIndexPath: (NSIndexPath *)indexPath {
    return isEditable;
}

/** cellForRowAtIndexPath
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    NSString *sectionTitle = [self tableView:tv titleForHeaderInSection:indexPath.section];
    
    UITableViewCell *cell = [TableCellFactory createHistoryCellForTable: tv withIdentifier:@"HistoryCell" 
                                                                withTag: indexPath.row
                                                             firstLabel: [self cellTextForTableView:tv atRow:indexPath.row withSectionTitle:sectionTitle]
                                                            secondLabel: [self cellDescriptionForTableView: tv atRow:indexPath.row withSectionTitle:sectionTitle]];
    // Customization???
    return cell;
}

/** sectionForSectionIndexTitle
 */
-(NSInteger) tableView: (UITableView *)tv sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    return index;
}

/** numberOfRowsInSection
 */
-(NSInteger) tableView: (UITableView *)tv numberOfRowsInSection: (NSInteger)sectionIndex {
    return [[filteredDataGroups objectForKey: [self tableView:tv titleForHeaderInSection:sectionIndex]] count];
}

/** titleForHeaderInSection
 */
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    return [[filteredDataGroups allKeys] objectAtIndex: sectionIndex];
    //return [self sectionTitleFromDate: sectionDate];
}

/** numberOfSectionsInTableView
 */
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tv {
    return [filteredDataGroups count];
}

/** sectionIndexTitlesForTableView
 */
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *)tv {
    // Return nil so that the index is not created.
    return nil;
}

/// cellTextForTableView
/// Default implementation: This should be implemented in a derived class.
-(NSString *) cellTextForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    //TODO: implement
    return @"";
}

///
/// Default implementation: This should be implemented in a derived class.
-(NSString *) cellDescriptionForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle {
    //TODO: implement
    return @"";
}

@end
