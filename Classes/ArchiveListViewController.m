//
//  ArchiveListViewController.m
//  Curbside
//
//  Created by Greg Walker on 7/13/13.
//
//

#import "ArchiveListViewController.h"
#import "ApplicationSupervisor.h"
#import "Constants.h"
#import "ArchiveFileDataSource.h"
#import "OrderedMutableDictionary.h"

@interface ArchiveListViewController ()

-(void) viewWasPopped;
-(void) showImportConfirmDialog: (NSString *)fileName;
-(void) subscribeToDataSourceChanges: (BOOL)yesNo;

@end

@implementation ArchiveListViewController

@dynamic dataSource;
-(ArchiveFileDataSource *) dataSource {
    return dataSource;
}
-(void) setDataSource:(ArchiveFileDataSource *)value {
    if (value == dataSource) {
        return;
    }
    if (dataSource) {
        // unsubscribe from any current data source
        [self subscribeToDataSourceChanges:NO];
    }
    
    [dataSource autorelease];
    dataSource = [value retain];
    
    if (dataSource != nil) {
        [self subscribeToDataSourceChanges:YES];
    }
}

// The designated initializer redirects to init.
-(id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    return [self init];
}

-(id) init {
    self = [super initWithNibName: @"ArchiveFileListView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Data Archives";
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
    self.title = nil;
    self.parentView = nil;
    self.dataSource = nil;
}


#pragma mark - Alerts
-(void) showImportConfirmDialog: (NSString *)fileName {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Import Data"
                                                    message: [[@"Import from archive " stringByAppendingString:fileName] stringByAppendingString:@"?"]
                                                   delegate: self
                                          cancelButtonTitle: @"No"
                                          otherButtonTitles: @"Yes", nil];
    [alert show];
    [alert release];
}


#pragma mark UIAlertViewDelegate Methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Only import the data archive if the Yes button was clicked.
    if (alertView.cancelButtonIndex != buttonIndex) {
        // import the selected data
        [[ApplicationSupervisor instance] importDataFromFile:self.dataSource.selectedItem];
        // and then pop this view
        [self.parentView dismissChildView:self];
    }
    else {
        self.dataSource.selectedItem = nil;
    }
}



#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.dataSource reloadData];
}

-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self viewWasPopped];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// viewWasPopped
///
-(void) viewWasPopped {
    // Scroll to top
    [self.dataSource.tableView setContentOffset: CGPointMake(0.0, 0.0)];
    // clear selection
    self.dataSource.selectedItem = nil;
}


#pragma mark - Event Handling

-(void) subscribeToDataSourceChanges: (BOOL)yesNo {
    if (yesNo) {
        [self.dataSource addPropertyChangeObserver:self];
    }
    else {
        [self.dataSource removePropertyChangeObserver: self];
    }
}

/// observeValueForKeyPath
/// Handle changes to Data Source Property values.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == dataSource) {
        if ([keyPath isEqualToString: selectedItemKey]) {
            if (self.dataSource.selectedItem) {
                // open the confirmation dialog
                [self showImportConfirmDialog:self.dataSource.selectedItem];
            }
            else {
                // just deselect the row and stay put
                [self.dataSource.tableView deselectRowAtIndexPath:[self.dataSource.tableView indexPathForSelectedRow] animated:YES];
            }
        }
    }
}

@end
