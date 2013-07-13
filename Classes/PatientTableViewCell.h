//
//  PatientTableViewCell.h
//  CurbSide
//
//  Created by Greg Walker on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Patient;


@interface PatientTableViewCell : UITableViewCell {
    Patient *patient;
    UILabel *fnameLabel;
    UILabel *lnameLabel;
    BOOL emphasisOnLastName;
}

@property (nonatomic, retain) Patient *patient;
@property (nonatomic, readonly) NSString *firstNameText;
@property (nonatomic, readonly) NSString *lastNameText;
@property (nonatomic, assign) BOOL emphasisOnLastName;

-(void) layoutLabels;

-(id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier andFontSize: (NSInteger)size;

@end
