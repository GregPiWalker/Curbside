//
//  SimplePickerDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SimplePickerDataSource : NSObject <UIPickerViewDataSource> {
    NSArray *data;
}

-(void) setData: (NSArray *)d;

-(NSString *) dataAtRow: (NSInteger)row;

@end
