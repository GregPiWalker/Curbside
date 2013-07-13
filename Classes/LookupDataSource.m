//
//  LookupDataSource.m
//  Curbside
//
//  Created by Greg Walker on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupDataSource.h"

@implementation LookupDataSource

@synthesize lookupTextField;
@synthesize numberOfVisibleRows;
@synthesize tableData;
@synthesize selectedItem;
@synthesize useExistingItem;
@dynamic numberOfRows;
-(NSInteger) numberOfRows {
    return [tableData count];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.useExistingItem = NO;
        self.selectedItem = nil;
        self.tableData = [NSMutableArray array];
    }
    
    return self;
}

-(void) reset {
    [self.tableData removeAllObjects];
    self.selectedItem = nil;
    self.useExistingItem = NO;
}

-(void) dealloc {
    self.lookupTextField = nil;
    self.selectedItem = nil;
    self.tableData = nil;
    [super dealloc];
}


#pragma mark UITableViewDataSource Methods

/// cellForRowAtIndexPath -- must be implemented in subclass.
///
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}

/// numberOfRowsInSection
///
-(NSInteger) tableView: (UITableView *)tv numberOfRowsInSection: (NSInteger)sectionIndex {
    // OK to resize table here since there is only one section.
    NSInteger numRows = self.numberOfRows;
    if (numRows <= numberOfVisibleRows) {
        // Resize tableView.
        CGRect tableFrame = tv.frame;
        tableFrame.size.height = tv.rowHeight * numRows;
        tv.frame = tableFrame;
    }
    
    return numRows;
}

/// sectionForSectionIndexTitle
///
-(NSInteger) tableView: (UITableView *)tv sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    return index;
}

/// titleForHeaderInSection
///
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    return @"";
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


#pragma mark UITableViewDelegate

/// didSelectRowAtIndexPath
///
-(void) tableView: (UITableView *)selectedTableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    id<NamedDataModel> selected = nil;
    if (self.lookupTextField) {
        // Find the item for the selected row.
        selected = [self.tableData objectAtIndex:indexPath.row];
        
        // Set the textField text to the text of the selected row.
        self.lookupTextField.text = [selected fullName];
        self.useExistingItem = YES;
    }
    // This will trigger an update for anyone listening to property changes.
    self.selectedItem = selected;
    // Dismiss the keyboard.
    [self.lookupTextField resignFirstResponder];
}


#pragma mark UITextFieldDelegate Methods

/// shouldChangeCharactersInRange -- must be implemented in subclass.
///
-(BOOL) textField: (UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacement {
    @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                   reason: [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo: nil];
}


#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath: selectedItemKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath: useExistingItemKey options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath: selectedItemKey];
        [self removeObserver:observer forKeyPath: useExistingItemKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

@end
