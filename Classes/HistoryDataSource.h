//
//  HistoryDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCellFactory.h"
#import "OrderedMutableDictionary.h"
#import "EnumsToStrings.h"


@interface HistoryDataSource : NSObject <UITableViewDataSource, UIAlertViewDelegate, UISearchBarDelegate> {
    NSMutableArray *historyData;
    NSMutableArray *orderedFilteredDates;
    OrderedMutableDictionary *filteredDataGroups;
    UITableView *tableView;
    NSArray *selectedIndexPaths;
    NSString *searchPhrase;
    BOOL isEditable;
    BOOL isReloadNeeded;
}

/// This is the sorted but unfiltered history item data.
@property (nonatomic, retain) NSMutableArray *historyData;

/// A collection of NSDate objects that provide the group header for a UITableView section.
@property (nonatomic, retain) NSMutableArray *orderedFilteredDates;

@property (nonatomic, assign) BOOL isEditable;

@property (nonatomic, assign) BOOL isReloadNeeded;

@property (nonatomic, retain) NSArray *selectedIndexPaths;

/// A dictionary of NSString keys representing table sections and array values containing section data.
@property (nonatomic, retain) OrderedMutableDictionary *filteredDataGroups;

@property (nonatomic, retain) NSString *searchPhrase;

///
-(id) initWithHistory:(NSArray *)history;

-(NSArray *) getFilteredSectionTitles;

-(void) applySearchFilter;

///
-(NSString *) cellTextForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle;

///
-(NSString *) cellDescriptionForTableView: (UITableView *)tv atRow: (NSInteger)row withSectionTitle: (NSString *)sectionTitle;

///
-(NSString *) sectionTitleFromDate: (NSDate *)date;

@property (nonatomic, retain) UITableView *tableView;

/// Add the specified history item to the data type that supports this data source.
-(void) addHistoryItem: (id)historyItem;

/// Remove the specified history item from the data type that supports this data source.
-(BOOL) removeHistoryItem: (id)historyItem;
/// Perform application-wide deletion of the item at the specified IndexPath.
-(void) deleteItemAtIndexPath: (NSIndexPath *)indexPath;

-(void) showDeletionDialog;

-(void) reloadTableData;

@end
