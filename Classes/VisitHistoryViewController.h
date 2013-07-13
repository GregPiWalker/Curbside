//
//  VisitHistoryViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationSupervisor.h"
#import "HistoryViewController.h"
#import "VisitHistoryDataSource.h"
#import "VisitViewController.h"
@class Visit;
@class Patient;


@interface VisitHistoryViewController : HistoryViewController {
    @private
    VisitViewController *visitViewController;
    UISearchBar *searchBar;
}

@property (nonatomic, retain) VisitViewController *visitViewController;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
