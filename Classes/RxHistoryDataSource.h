//
//  RxHistoryDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryDataSource.h"
#import "Visit.h"
#import "Prescription.h"


@interface RxHistoryDataSource : HistoryDataSource {
}

/**
 */
-(Prescription *) getPrescriptionForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)path;

@end
