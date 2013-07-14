//
//  ArchiveFileDataSource.m
//  Curbside
//
//  Created by Greg Walker on 7/13/13.
//
//

#import "ArchiveFileDataSource.h"
#import "ApplicationSupervisor.h"
#import "Constants.h"
#import "TableCellFactory.h"
#import "OrderedMutableDictionary.h"


@implementation ArchiveFileDataSource


-(id) init {
    self = [super init];
    if (self) {
        self.archiveFiles = [NSArray array];
        self.selectedItem = nil;
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
    self.archiveFiles = nil;
}

-(void) reloadData {
    self.archiveFiles = [[ApplicationSupervisor instance] listArchiveFiles];
    self.selectedItem = nil;
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource Methods

/** cellForRowAtIndexPath
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"archiveFileCell";   
    
    NSString *label = [self.archiveFiles objectAtIndex:indexPath.row];
    UITableViewCell *cell = [TableCellFactory createImmutableTextCellForTable: tv
                                                               withIdentifier: cellIdentifier
                                                                      withTag: indexPath.row
                                                            withAccessoryType: UITableViewCellAccessoryNone
                                                                withCellStyle: UITableViewCellStyleValue1
                                                           withSelectionStyle: UITableViewCellSelectionStyleBlue
                                                                     andLabel: label];
    return cell;
}

/// sectionForSectionIndexTitle
///
//-(NSInteger) tableView: (UITableView *)tv sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
//    return index;
//}

/** numberOfRowsInSection
 */
-(NSInteger) tableView: (UITableView *)tv numberOfRowsInSection: (NSInteger)sectionIndex {
    // Each section has the same length.
    return [self.archiveFiles count];
}

/// titleForHeaderInSection
///
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    return nil;
}

/// numberOfSectionsInTableView
///
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tv {
    return 1;
}

/// sectionIndexTitlesForTableView
///
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *)tv {
    // Return nil so that the index is not created.
    return nil;
}


#pragma mark - UITableViewDelegate Methods

-(void) tableView: (UITableView *)tv didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    self.selectedItem = [self.archiveFiles objectAtIndex:indexPath.row];
}

-(UITableViewCellEditingStyle) tableView: (UITableView *)tv editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:selectedItemKey options:NSKeyValueObservingOptionNew context:self];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver: observer forKeyPath:selectedItemKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
