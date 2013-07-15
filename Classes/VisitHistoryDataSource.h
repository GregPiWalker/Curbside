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
}

@property (nonatomic, assign) BOOL immutable;


-(Visit *) getVisitForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)path;


@end
