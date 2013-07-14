//
//  LookupDataSource.h
//  Curbside
//
//  Created by Greg Walker on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCellFactory.h"
#import "ApplicationSupervisor.h"
#import "NamedDataModel.h"


static NSString *const useExistingItemKey = @"useExistingItem";


@interface LookupDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
@protected
    UITextField *lookupTextField;
    NSMutableArray *tableData;
    NSInteger numberOfVisibleRows;
    id<NamedDataModel> selectedItem;
    BOOL useExistingItem;
}

@property (nonatomic, retain) UITextField *lookupTextField;

/// This is an array of the data that currently populates the UITableView.
@property (nonatomic, retain) NSMutableArray *tableData;

@property (nonatomic, assign) NSInteger numberOfVisibleRows;

@property (nonatomic, assign, readonly) NSInteger numberOfRows;

@property (nonatomic, retain) id<NamedDataModel> selectedItem;

@property (nonatomic, assign) BOOL useExistingItem;

-(void) reset;

///
-(void) addPropertyChangeObserver: (NSObject *)observer;

///
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
