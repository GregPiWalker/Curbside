//
//  PharmacyViewController.h
//  Curbside
//
//  Created by Greg Walker on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewDelegate.h"
@class ContactListDataSource;
@class EditPharmacyViewController;
@class Pharmacy;
    
    
@interface PharmacyViewController : UIViewController {
@private
    Pharmacy *pharmacy;
    id<ParentViewDelegate> parentView;
    ContactListDataSource *contactsDataSource;
    EditPharmacyViewController *editPharmacyView;
    BOOL needsViewRefresh;
    BOOL wasViewPopped;
    UITextField *nameTextField;
    UITableView *contactInfoTableView;
    UILabel *nameLabel;
    UILabel *contactLabel;
    IBOutlet UITextField *addrTextField;
    IBOutlet UITextField *cityTextField;
    IBOutlet UITextField *zipTextField;
    IBOutlet UITextField *stateTextField;
    IBOutlet UITextField *phoneTextField;
    IBOutlet UITextField *emailTextField;
    UIBarButtonItem *editPharmacyButton;
}

@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) id<ParentViewDelegate> parentView;
@property (nonatomic, retain) EditPharmacyViewController *editPharmacyView;
@property (nonatomic, retain) IBOutlet ContactListDataSource *contactsDataSource;
@property (nonatomic, retain) IBOutlet NSString *name;

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITableView *contactInfoTableView;

@property (nonatomic, retain) IBOutlet UILabel *contactLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editPharmacyButton;

-(id) initWithPharmacy: (Pharmacy *)existingPharm;

-(IBAction) editPharmacyAction: (id)sender;

@end
