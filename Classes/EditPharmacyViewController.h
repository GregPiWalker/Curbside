//
//  EditPharmacyViewController.h
//  CurbSide
//
//  Created by Greg Walker on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerBase.h"
#import "ParentViewDelegate.h"
@class PharmacyLookupDataSource;
@class ContactListDataSource;
@class Pharmacy;
@class Contact;


@interface EditPharmacyViewController : ViewControllerBase <UITextFieldDelegate> {
    @private
    Pharmacy *pharmacy;
    id<ParentViewDelegate> parentView;
    ContactListDataSource *contactListDataSource;
    PharmacyLookupDataSource *pharmacyLookupDataSource;
    BOOL isNewPharmacy;
    BOOL needsViewRefresh;
    NSInteger maxLookupTableRows;
    UIView *controlBeingEdited;
    UIScrollView *scrollView;
    UIView *scrollContentView;
    UIBarButtonItem *saveButton;
    UIBarButtonItem *dismissEditorButton;
    UIButton *deletePharmacyButton;
    UITextField *nameTextField;
    UITableView *contactInfoTableView;
    UITableView *autocompleteTableView;
    UILabel *nameLabel;
    UILabel *contactLabel;
}

@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) id<ParentViewDelegate> parentView;
@property (nonatomic, retain) IBOutlet ContactListDataSource *contactListDataSource;
@property (nonatomic, retain) IBOutlet PharmacyLookupDataSource *pharmacyLookupDataSource;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL isNewPharmacy;
@property (nonatomic, retain) UIView *controlBeingEdited;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *scrollContentView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissEditorButton;
@property (nonatomic, retain) IBOutlet UIButton *deletePharmacyButton;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITableView *contactInfoTableView;
@property (nonatomic, retain) IBOutlet UITableView *autocompleteTableView;
@property (nonatomic, retain) IBOutlet UILabel *contactLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

-(IBAction) savePharmacyAction: (id)sender;

-(IBAction) nameEditingEndAction: (id)sender;

-(IBAction) dismissKeyboardAction: (id)sender;

-(id) initWithNewPharmacy: (Pharmacy *)newPharm;

-(id) initForEditWithPharmacy: (Pharmacy *)existingPharm;

-(void) addPharmacySavedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePharmacySavedObserver: (NSObject *)observer;

-(void) addPharmacyReferencedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler;
-(void) removePharmacyReferencedObserver: (NSObject *)observer;

@end
