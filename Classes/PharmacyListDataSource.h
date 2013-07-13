//
//  PharmacyListDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PharmacyListDataSource : NSObject <UITableViewDataSource> {
    @private
    UITableView *tableView;
}

@property (nonatomic, retain) UITableView *tableView;

@end
