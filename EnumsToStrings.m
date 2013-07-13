//
//  EnumsToStrings.m
//  CurbSide
//
//  Created by Greg Walker on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnumsToStrings.h"


@implementation EnumsToStrings


+(NSString *) monthComponentToString: (NSDateComponents *)dateComponents {
    NSString *str;
    switch ([dateComponents month]) {
        case 1:
            str = @"January";
            break;
            
        case 2:
            str = @"February";
            break;
            
        case 3:
            str = @"March";
            break;
            
        case 4:
            str = @"April";
            break;
            
        case 5:
            str = @"May";
            break;
            
        case 6:
            str = @"June";
            break;
            
        case 7:
            str = @"July";
            break;
            
        case 8:
            str = @"August";
            break;
            
        case 9:
            str = @"September";
            break;
            
        case 10:
            str = @"October";
            break;
            
        case 11:
            str = @"November";
            break;
            
        case 12:
            str = @"December";
            break;
            
        default:
            str = @"";
            break;
    }
    
    return str;
}

//-(NSString *) yearComponentToString: (NSDateComponents *)dateComponents

@end
