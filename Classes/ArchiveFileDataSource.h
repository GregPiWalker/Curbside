//
//  ArchiveFileDataSource.h
//  Curbside
//
//  Created by Greg Walker on 7/13/13.
//
//

#import <Foundation/Foundation.h>

static NSString *const archiveFilesKey = @"archiveFiles";


@interface ArchiveFileDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> 

// The table view is set by the XIB when this class is instantiated.
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *archiveFiles;
@property (nonatomic, retain) NSString *selectedItem;

-(void) reloadData;
-(void) addPropertyChangeObserver: (NSObject *)observer;
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
