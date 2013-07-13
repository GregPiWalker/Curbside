    //
//  RxHistoryViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "RxHistoryViewController.h"
#import "MainViewController.h"


@interface RxHistoryViewController ()
-(void) viewWasPopped;
@end


@implementation RxHistoryViewController

#pragma mark - Methods

// The default initializer redirects to a custom init.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

/// The designated initializer. 
-(id) initWithHistory: (NSArray *)rxHistory {
    self = [super initWithNibName: @"RxHistoryView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Prescription History";
        wasViewPopped = NO;
        historyDataSource = [[RxHistoryDataSource alloc] initWithHistory:rxHistory];
    }
    return self;
}

/// viewWasPopped
///
-(void) viewWasPopped {    
    // Scroll to top
    [self.tableView setContentOffset: CGPointMake(0.0, 0.0)];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/** viewDidLoad
 */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Set the TableView's data source.
    self.tableView.dataSource = historyDataSource;
}

-(void) viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
        
    if (![[self.navigationController topViewController] isKindOfClass:[RxViewController class]]
        && ![[self.navigationController topViewController] isKindOfClass:[RxHistoryViewController class]]) {
        wasViewPopped = YES;
    }
}

-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (wasViewPopped) {
        [self viewWasPopped];
        wasViewPopped = NO;
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Memory Management

/**
 */
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    //TODO:
}

/**
 */
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
}

///
- (void)dealloc {
    [super dealloc];
    // historyDataSource is deallocated in super class.
}


#pragma mark UITableViewDelegate

-(void) tableView: (UITableView *)tv didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    RxHistoryDataSource *rxDataSource = (RxHistoryDataSource *)historyDataSource;
    Prescription *selectedPrescription = [rxDataSource getPrescriptionForTableView:tv atIndexPath:indexPath];
    RxViewController *rxVC = [[RxViewController alloc] initWithPrescription: selectedPrescription];
    [self.navigationController pushViewController:rxVC animated:YES];
    [rxVC release];
}


@end
