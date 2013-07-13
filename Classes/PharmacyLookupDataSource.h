//
//  PharmacyLookupDataSource.h
//  Curbside
//
//  Created by Greg Walker on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupDataSource.h"
#import "ContactListDataSource.h"
#import "PharmacyTableViewCell.h"
@class Contact;
@class Pharmacy;


@interface PharmacyLookupDataSource : LookupDataSource {
    NSMutableArray *pharmacyList;
}

@property (nonatomic, retain) Pharmacy *selectedPharmacy;

@property (nonatomic, retain) NSMutableArray *pharmacyList;

@end
