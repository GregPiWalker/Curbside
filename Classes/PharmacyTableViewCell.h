//
//  PharmacyTableViewCell.h
//  Curbside
//
//  Created by Greg Walker on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Pharmacy;
@class Contact;

@interface PharmacyTableViewCell : UITableViewCell {
    Pharmacy *pharmacy;
    UILabel *nameLabel;
    UILabel *addressLabel;
}

@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, readonly) NSString *nameText;
@property (nonatomic, readonly) NSString *addressText;

-(void) layoutLabels;

-(id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier andFontSize: (NSInteger)size;

@end
