//
//  ArchiveListViewController.h
//  Curbside
//
//  Created by Greg Walker on 7/13/13.
//
//

#import <UIKit/UIKit.h>
#import "ParentViewDelegate.h"

@class ArchiveFileDataSource;

@interface ArchiveListViewController : UIViewController <UIAlertViewDelegate> {
    ArchiveFileDataSource *dataSource;
}

//@property (nonatomic, retain) IBOutlet UITableView *tableView;

// The data source is set in the XIB when this ViewController is loaded.
@property (nonatomic, retain) IBOutlet ArchiveFileDataSource *dataSource;
@property (nonatomic, retain) id<ParentViewDelegate> parentView;


@end
