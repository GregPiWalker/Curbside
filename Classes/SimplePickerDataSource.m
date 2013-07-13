//
//  SimplePickerDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimplePickerDataSource.h"


@implementation SimplePickerDataSource


-(void) setData: (NSArray *)d {
    if (data == d) {
        return;
    }
    [data autorelease];
    data = [d retain];
}


-(NSString *) dataAtRow: (NSInteger)row {
    if (data && [data count] > row) {
        return [data objectAtIndex:row];
    }
    return @"";
}

#pragma mark UIPickerViewDataSource Methods

/// numberOfComponentsInPickerView
/// Always returns 1 so that only one column is created.
-(NSInteger) numberOfComponentsInPickerView: (UIPickerView *)pickerView {
    return 1;
}

/// numberOfRowsInComponent
-(NSInteger) pickerView: (UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return [data count];
}

-(void) dealloc {
    [data release];
    [super dealloc];
}

@end
