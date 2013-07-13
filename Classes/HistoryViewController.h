//
//  HistoryViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewControllerBase.h"
#import "HistoryDataSource.h"


@interface HistoryViewController : ViewControllerBase <UITableViewDelegate> {
    HistoryDataSource *historyDataSource;
    UITableView *tableView;
}

@property (nonatomic, retain) HistoryDataSource *historyDataSource;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

/**
 */
-(id) initWithHistory: (NSArray *)history;

/**
 */
-(void) addHistoryItem: (id)historyItem;

/**
 */
-(BOOL) removeHistoryItem: (id)historyItem;

@end
