//
//  RxListDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyChangePublisher.h"
@class Visit;
@class ModificationTracker;

typedef struct {
    NSArray *added;
    NSArray *removed;
} RxSourceModifications;

@interface RxListDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    @private
    NSMutableArray *prescriptions;
    Visit *dataOwner;
    NSIndexPath *lastAddedIndexPath;
    UITableView *tableView;
    NSInteger extraRowCount;
    UIColor *headingTextColor;
    BOOL isEditEnabled;
    BOOL isReloadNeeded;
    BOOL canSelectPrescriptions;
}

@property (nonatomic, assign) BOOL isEditEnabled;

@property (nonatomic, assign) BOOL isReloadNeeded;

@property (nonatomic, assign) BOOL canSelectPrescriptions;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UIColor *headingTextColor;

@property (nonatomic, readonly) NSIndexPath *lastAddedIndexPath;

@property (nonatomic, retain) Visit *dataOwner;

@property (nonatomic, retain) NSMutableArray *prescriptions;

@property (nonatomic, assign) NSInteger extraRowCount;

/// This constructor is used when a prescription set already exists.
-(id) initWithPrescriptionOwner: (Visit *)owner;
/// This constructor is used when a prescription set and tableView already exists.
-(id) initFor: (UITableView *)tv withPrescriptionOwner: (Visit *)owner;

-(ModificationTracker *) applyChanges;

/// Reset the DataSource to initial state.
-(void) reset;

-(void) reloadTableData;

/// Purge a last data entry if it is empty, meaning that it was abandoned.
-(void) purgeUnfinishedRow;

-(void) addTableRowInsertedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) addTableRowRemovedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) addPrescriptionSelectedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removeTableRowInsertedObserver: (NSObject *)observer;
-(void) removeTableRowRemovedObserver: (NSObject *)observer;
-(void) removePrescriptionSelectedObserver: (NSObject *)observer;

@end
