//
//  MedicationLookupDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MedicationLookupDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
@private
    UITextField *medicationTextField;
    NSString *selectedMedication;
    NSMutableArray *tableData;
    BOOL useExistingMedication;
    NSInteger numberOfRows;
    NSInteger numberOfVisibleRows;
}

@property (nonatomic, retain) UITextField *medicationTextField;

@property (nonatomic, retain) NSString *selectedMedication;

@property (nonatomic, retain) NSMutableArray *tableData;

@property (nonatomic, assign) BOOL useExistingMedication;

@property (nonatomic, assign, readonly) NSInteger numberOfRows;

@property (nonatomic, assign) NSInteger numberOfVisibleRows;

///
-(void) addPropertyChangeObserver: (NSObject *)observer;

///
-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
