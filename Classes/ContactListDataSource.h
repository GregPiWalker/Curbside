//
//  ContactListDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Contact;
@class ModificationTracker;
@class OrderedMutableDictionary;


@interface ContactListDataSource : NSObject <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate> {
    NSMutableArray *contacts;
    OrderedMutableDictionary *contactData;
    NSString *sectionTitle;
    UITableView *tableView;
    UITextField *fieldBeingEdited;
    NSInteger currentSection;
    BOOL isEditEnabled;
    BOOL isReloadNeeded;
    // Array of Dictionary<Property name, Property value> accessed by section indexes.
    NSMutableArray *changedProperties;
}

/**
 */
@property (nonatomic, retain) NSMutableArray *contacts;

@property (nonatomic, readonly) Contact *currentContact;

@property (nonatomic, retain) OrderedMutableDictionary *contactData;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, assign) BOOL enableEdit;

/**
 */
@property (nonatomic, readonly) NSString *sectionTitle;

/**
 */
@property (nonatomic, retain) UITextField *fieldBeingEdited;

///
@property (nonatomic, retain) NSString *address;

///
@property (nonatomic, retain) NSString *city;

///
@property (nonatomic, retain) NSString *state;

///
@property (nonatomic, retain) NSString *phone;

///
@property (nonatomic, retain) NSString *email;

///
@property (nonatomic, retain) NSString *zip;

/**
 */
-(id) initWithContacts: (NSArray *)contacts;

-(void) dismissKeyboard;

-(void) selectTextFieldInRow: (NSInteger)row;

-(ModificationTracker *) applyChanges;

-(void) reloadTableData;

-(void) reset;

-(void) populateContacts: (NSArray *)data;
-(void) addContact: (Contact *)c;
//-(void) setContact: (Contact *)c forSection: (NSInteger)section;
-(void) removeContact: (Contact *)c;
-(void) removeAllContacts;

-(void) addPropertyChangeObserver: (NSObject *)observer;

-(void) removePropertyChangeObserver: (NSObject *)observer;

@end
