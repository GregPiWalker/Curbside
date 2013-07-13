//
//  RxListDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RxListDataSource.h"
#import "TableCellFactory.h"
#import "NotificationArgs.h"
#import "Constants.h"
#import "Prescription.h"
#import "ModificationTracker.h"
#import "Visit.h"


static const float tableHeaderHeight = 44.0;
static NSString *const addPrescriptionLabel = @"Add Prescription";


@interface RxListDataSource ()

//-(void) populateWithPatientData;

-(void) subscribeToVisitPropertyChanges: (BOOL)yesNo;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

-(void) refreshRxCollection;

@end

@implementation RxListDataSource

@synthesize prescriptions;
@synthesize canSelectPrescriptions;
@synthesize isReloadNeeded;
@synthesize headingTextColor;
@synthesize extraRowCount;
@synthesize lastAddedIndexPath;
@synthesize tableView;
-(void) setTableView:(UITableView *)tv {
    if (tv == tableView) {
        return;
    }
    [tableView autorelease];
    tableView = [tv retain];
    if (tableView != nil) {
        tableView.dataSource = self;
        tableView.delegate = self;
    }
}

@synthesize isEditEnabled;
-(void) setIsEditEnabled:(BOOL)b {
    isEditEnabled = b;
    [self refreshRxCollection];
}

/// This is any PropertyChangePublisher that has a 'prescriptions' collection.
@synthesize dataOwner;
-(void) setDataOwner: (Visit *)value {
    if (value == dataOwner) {
        return;
    }
    if (dataOwner != nil) {
        [self subscribeToVisitPropertyChanges:NO];
    }
    [dataOwner autorelease];
    dataOwner = [value retain];
    
    if (dataOwner != nil) {
        self.prescriptions = [NSMutableArray arrayWithArray: value.prescriptions];
        self.extraRowCount = [self.prescriptions count];
        [self refreshRxCollection];
        [self subscribeToVisitPropertyChanges:YES];
    }
    else {
        [self.prescriptions removeAllObjects];
        self.extraRowCount = 0;
    }
    isReloadNeeded = YES;
}


#pragma mark - Methods

-(id) init {
    self = [super init];
    if (self) {
        isReloadNeeded = NO;
        canSelectPrescriptions = YES;
        tableView = nil;
        lastAddedIndexPath = nil;
        // Setting dataOwner also sets prescriptions.
        self.dataOwner = nil;
        // Just set a default color.  It can be overridden later.
        self.headingTextColor = [UIColor blackColor];
        isEditEnabled = NO;
        extraRowCount = 0;
    }
    return self;
}

/// This constructor is used when a prescription set already exists.
/// owner is anything that has a collection of prescriptions for this data source to preside over.
-(id) initWithPrescriptionOwner: (Visit *)owner {
    return [self initFor:nil withPrescriptionOwner:owner];
}

/// This constructor is used when a prescription set and tableView already exists.
/// owner is anything that has a collection of prescriptions for this data source to preside over.
-(id) initFor: (UITableView *)tv withPrescriptionOwner: (Visit *)owner {
    self = [super init];
    if (self) {
        isReloadNeeded = NO;
        lastAddedIndexPath = nil;
        self.tableView = tv;
        // Setting dataOwner also sets the prescriptions property.
        self.dataOwner = owner;
        // Just set a default color.  It can be overridden later.
        self.headingTextColor = [UIColor blackColor];
        isEditEnabled = NO;
        [self subscribeToVisitPropertyChanges: YES];
    }
    return self;
}

-(void) refreshRxCollection {
    if (isEditEnabled) { 
        if (![[self.prescriptions lastObject] isEqual: addPrescriptionLabel]) {
            [self.prescriptions addObject: addPrescriptionLabel];
            isReloadNeeded = YES;
        }
    }
    else if ([[self.prescriptions lastObject] isEqual: addPrescriptionLabel]) {
        [self.prescriptions removeLastObject];
        isReloadNeeded = YES;
    }
}

/// purgeUnfinishedRow
/// 
-(void) purgeUnfinishedRow {
    if (self.tableView && lastAddedIndexPath) {
        // Check to see if the last added prescription is incomplete, which indicates a cancellation.
        Prescription *lastRx = [self.prescriptions objectAtIndex:lastAddedIndexPath.row];
        // This test should fail if the applyChanges message has been called.
        if ([lastRx.medication isEqualToString:@""]) {
            // MUST delete the datasource row before trying to remove the table row.
            [self.prescriptions removeObjectAtIndex:lastAddedIndexPath.row];
            //[self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:lastAddedIndexPath] withRowAnimation:NO];
            //[self.tableView endUpdates];
            self.extraRowCount -= 1;
            // Send a notification so any listeners can respond as they need to.
            [self sendNotification:kTableRowRemovedNotification about: [NotificationArgs argsWithData: lastRx fromSender: self]];
        }
        [lastAddedIndexPath release];
        lastAddedIndexPath = nil;
    }
}

/// applyChanges
/// Set any outstanding editor changes onto the visit backing this DataSource.
/// dataOwner property must be set in order for this to succeed.
/// This will add and remove prescriptions with the ApplicationSupervisor.
///
-(ModificationTracker *) applyChanges {
    // Stop listening to Visit property changes since they were already handled directly.
    [self subscribeToVisitPropertyChanges: NO];
    
    ModificationTracker * mods = [[[ModificationTracker alloc] init] autorelease];
    // PRESCRIPTIONS SYNC
    NSMutableArray *deletions = [NSMutableArray array];
    NSArray *rxsCopy = [[self.dataOwner prescriptions] copy];
    // Sync deleted prescriptions with data owner.
    [rxsCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.prescriptions containsObject: obj]) {
            [dataOwner removePrescription: obj];
            // Delete the removed prescriptions.
            [deletions addObject: obj];
        }
    }];
    [rxsCopy release];
    [mods setDeletions: deletions ForClass: [Prescription class]];
    
    NSMutableArray *additions = [NSMutableArray array];
    rxsCopy = [NSMutableArray arrayWithArray: self.prescriptions];
    // Remove duplicates, leaving only new additions.
    [dataOwner.prescriptions enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSMutableArray*)rxsCopy removeObject: obj];
    }];
    // Add the remaining new prescriptions to the visit and AppSuper.
    for (Prescription *rx in rxsCopy) {
        if ([rx isKindOfClass: [Prescription class]]) {
            [dataOwner addPrescription: rx];
            // Add the new prescriptions.
            [additions addObject: rx];
        }
    }
    [mods setAdditions: additions ForClass: [Prescription class]];
    
    // Restart listening to Visit property changes now that direct changes are applied.
    [self subscribeToVisitPropertyChanges: YES];
    
    return mods;
}

-(void) reset {
    [self.prescriptions removeAllObjects];
    [self refreshRxCollection];
    self.extraRowCount = 0;
}

-(void) reloadTableData {
    if (isReloadNeeded) {
        [tableView reloadData];
        isReloadNeeded = NO;
    }
}


#pragma mark UITableViewDelegate Methods

/// editingStyleForRowAtIndexPath
///
-(UITableViewCellEditingStyle) tableView: (UITableView *)tv editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    if (isEditEnabled) {
        if ([[self.prescriptions objectAtIndex:indexPath.row] isEqual:@"Add Prescription"]) {
            // If it's the last row, show the insert button.
            return UITableViewCellEditingStyleInsert;
        }
        else {
            // Otherwise, show the delete button.
            return UITableViewCellEditingStyleDelete;
        }
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

-(void) tableView: (UITableView *)tv didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if ([self.prescriptions count] > indexPath.row && ![[self.prescriptions objectAtIndex:indexPath.row] isEqual:@"Add Prescription"]) {
        Prescription *rx = [self.prescriptions objectAtIndex: indexPath.row];
        if (rx) {
            [self sendNotification:kPrescriptionSelectedNotification about:[NotificationArgs argsWithData:rx fromSender:self]];
        }
    }
}

/// viewForHeaderInSection
/// This allows customized section headers.
//-(UIView *) tableView: (UITableView *)tv viewForHeaderInSection: (NSInteger)section {
//    static const float leftMargin = 10.0;
//    static const float topMargin = 0.0;
//    static const float topOffset = 10.0;
//    static const int fontSize = 19;
//	// create the parent view that will hold header Label.  This allows the label to have some padding.
//	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(tv.bounds.origin.x, topMargin, tv.bounds.size.width, tableHeaderHeight)] autorelease];
//	
//	// Create the label object.
//	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	headerLabel.backgroundColor = [UIColor clearColor];
//	headerLabel.opaque = NO;
//	headerLabel.textColor = headingTextColor;
//	//headerLabel.highlightedTextColor = [UIColor whiteColor];
//	headerLabel.font = [UIFont boldSystemFontOfSize: fontSize];
//	headerLabel.frame = CGRectMake(leftMargin, topOffset, tv.bounds.size.width, tableHeaderHeight - topOffset);
//	headerLabel.text = [self tableView:tv titleForHeaderInSection:section];
//    
//	[customView addSubview:headerLabel];
//    [headerLabel release];
//    
//	return customView;
//}
//
//-(CGFloat) tableView: (UITableView *)tv heightForHeaderInSection: (NSInteger)section {
//	
//    return tableHeaderHeight;
//}

#pragma mark UITableViewDataSource Methods

/** commitEditingStyle
 */
-(void) tableView: (UITableView *)tv commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    //CGRect tableFrame = tv.frame;
    //float cellHeight = [tv rowHeight];
    Prescription *rx;
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert: 
            // Increase the table height.
            //tableFrame.size.height += cellHeight;
            
            rx = [[Prescription alloc] init];
            // Add row as a place-holder to the end of the data collection for the given section.
            [self.prescriptions insertObject: rx atIndex: indexPath.row];
            [rx release];
            // Insert the new row in the UI control.
            [tv insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: NO];
            // Changes were made to the prescription collection, so mark it dirty. 
            // (must be after new row is added but before notice is sent)
            isReloadNeeded = YES;
            self.extraRowCount += 1;
            [lastAddedIndexPath release];
            lastAddedIndexPath = [[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] retain];
            [self sendNotification: kTableRowInsertedNotification about: [NotificationArgs argsWithData:rx fromSender:self]];
            break;
            
        case UITableViewCellEditingStyleDelete:
            // Reduce the table height.
            //tableFrame.size.height -= cellHeight;
            // Remove the selected row from the data collection for the given section.
            rx = [[self.prescriptions objectAtIndex: indexPath.row] retain];
            [self.prescriptions removeObjectAtIndex: indexPath.row];
            // Delete the row in the UI control.
            [tv deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: YES];
            // Changes were made to the prescription collection, so mark it dirty.
            // (must be after row removed but before notice is sent)
            isReloadNeeded = YES;
            self.extraRowCount -= 1;
            [self sendNotification: kTableRowRemovedNotification about: [NotificationArgs argsWithData:rx fromSender:self]];
            [rx release];
            break;
            
        default:
            break;
    }
    
    //tv.frame = tableFrame;
}

/** cellForRowAtIndexPath
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *textCellIdentifier = @"immutableTextCell";
    UITableViewCell *cell;
    NSString *description = nil;
    NSString *text = nil;
    BOOL isAddCellPlaceholder = NO;
    UITableViewCellAccessoryType accessoryType = (self.canSelectPrescriptions ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    // Need to know if it's the last row with an 'Add' label.
    if ([[self.prescriptions objectAtIndex:indexPath.row] isEqual:@"Add Prescription"]) {
        isAddCellPlaceholder = YES;
        description = [self.prescriptions objectAtIndex:indexPath.row];
    }
    else {
        // Get the cell text and description from the prescription.
        Prescription *rx = [self.prescriptions objectAtIndex:indexPath.row];
        description = rx.medication;
        text = [NSString stringWithFormat: @"%i refills", rx.numRefills];
    }
    
    // For immutable cells, or cells with a non-text editor.
    if (isAddCellPlaceholder) {
        cell = [TableCellFactory createAdditionPlaceHolderCellForTable: tv 
                                                        withIdentifier: @"addPlaceHolderCell"
                                                            firstLabel: description];
    }
    else {
        cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                          withIdentifier: textCellIdentifier 
                                                                 withTag: indexPath.row 
                                                       withAccessoryType: accessoryType
                                                           withCellStyle: UITableViewCellStyleDefault
                                                              firstLabel: description 
                                                             secondLabel: text];
        cell.editingAccessoryType = cell.accessoryType;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    // Tag the selected cell's ContentView with the row number.
    cell.contentView.tag = indexPath.row;
    
    return cell;
}

/** numberOfRowsInSection
 */
-(NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)sectionIndex {
    return [self.prescriptions count];
}

/// numberOfSectionsInTableView
///
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}


#pragma mark Memory Management

-(void) dealloc {
    [self subscribeToVisitPropertyChanges: NO];
    self.prescriptions = nil;
    self.dataOwner = nil;
    self.tableView = nil;
    self.headingTextColor = nil;
    [lastAddedIndexPath release];
    [super dealloc];
}


#pragma mark Event Handling

-(void) addTableRowInsertedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // Use a nil sender filter because the notifications are sent with data in addition to this data source.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kTableRowInsertedNotification object:nil];
}
-(void) addTableRowRemovedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // Use a nil sender filter because the notifications are sent with data in addition to this data source.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kTableRowRemovedNotification object:nil];
}
-(void) addPrescriptionSelectedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // Use a nil sender filter because the notifications are sent with data in addition to this data source.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPrescriptionSelectedNotification object:nil];
}

-(void) removeTableRowInsertedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kTableRowInsertedNotification object:nil];
}
-(void) removeTableRowRemovedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kTableRowRemovedNotification object:nil];
}
-(void) removePrescriptionSelectedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPrescriptionSelectedNotification object:nil];
}

/// observeValueForKeyPath
/// Respond to changes in the business object's prescription collection that backs this data source.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != self.dataOwner) {
        return;
    }
    
    NSNumber * kind = (NSNumber *)[change valueForKey:NSKeyValueChangeKindKey];
    NSIndexSet *indexes = [change valueForKey:NSKeyValueChangeIndexesKey];
    
    if ([keyPath isEqualToString:prescriptionsKey]) {
        NSUInteger index = [indexes firstIndex];
        switch ([kind intValue]) {
            case NSKeyValueChangeInsertion:
                while (index != NSNotFound) {
                    Prescription *rx = [[self.dataOwner valueForKey: prescriptionsKey] objectAtIndex: index];
                    [self.prescriptions insertObject: rx atIndex: index];
                    index = [indexes indexGreaterThanIndex: index];
                    [self sendNotification: kTableRowInsertedNotification about: [NotificationArgs argsWithData:rx fromSender:self]];
                }
                break;
                
            case NSKeyValueChangeRemoval:
                while (index != NSNotFound) {
                    // Get the Rx value from the local collection, not the data source since it was already deleted from there.
                    Prescription *rx = [self.prescriptions objectAtIndex: index];
                    [self.prescriptions removeObjectAtIndex: index];
                    index = [indexes indexGreaterThanIndex: index];
                    [self sendNotification: kTableRowRemovedNotification about: [NotificationArgs argsWithData:rx fromSender:self]];
                }
                break;
                
            default:
                break;
        }
    }
}

-(void) subscribeToVisitPropertyChanges: (BOOL)yesNo {
    // Only respond to property change notifications if this DataSource is not being edited directly.
    if (!isEditEnabled) {
        if (yesNo) {
            [self.dataOwner addPropertyChangeObserver:self];
        }
        else {
            @try {
                [self.dataOwner removePropertyChangeObserver:self];
            }
            @catch (NSException *exception) {
                // nothing
            }
        }
    }
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
