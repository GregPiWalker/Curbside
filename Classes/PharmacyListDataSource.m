//
//  PharmacyListDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PharmacyListDataSource.h"


@implementation PharmacyListDataSource


@synthesize tableView;
-(void) setTableView:(UITableView *)tv {
    if (tv == tableView) {
        return;
    }
    [tableView release];
    tableView = [tv retain];
    if (tableView != nil) {
        tableView.dataSource = self;
    }
}

@end
