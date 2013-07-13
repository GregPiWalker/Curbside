//
//  VisitHistoryDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationSupervisor.h"
#import "HistoryDataSource.h"
#import "Utilities.h"
@class Patient;
@class Visit;


@interface VisitHistoryDataSource : HistoryDataSource <UISearchBarDelegate> {
    BOOL immutable;
//    NSMutableDictionary *filteredData;
//    NSString *searchPhrase;
}

@property (nonatomic, assign) BOOL immutable;

/// A dictionary of group title keys and array values containing section data.
//@property (nonatomic, retain) NSMutableDictionary *filteredData;
//
//@property (nonatomic, retain) NSString *searchPhrase;

-(Visit *) getVisitForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)path;


@end
