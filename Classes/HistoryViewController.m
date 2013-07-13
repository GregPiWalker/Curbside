//
//  HistoryViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"


@implementation HistoryViewController

@synthesize historyDataSource;
@synthesize tableView;

// init redirects to initWithHistory.
- (id)init {
    return [self initWithHistory:[NSArray array]];
}

/// initWithHistory
/// This is just a base implementation that needs to be overridden.
///
-(id) initWithHistory:(NSArray *)history {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

///
-(void) addHistoryItem: (id)historyItem {
    [self.historyDataSource addHistoryItem: historyItem];
}

///
-(BOOL) removeHistoryItem: (id)historyItem {
    return [self.historyDataSource removeHistoryItem: historyItem];
}

///
- (void)dealloc {
    self.historyDataSource = nil;
    self.tableView = nil;
    [super dealloc];
}

@end
