//
//  AddressBookViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface AddressBookViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate> {

}

-(IBAction) viewAllContactsAction: (id)sender;
-(IBAction) viewContactAction: (id)sender;

/**
 Show the named person, if found, in the Address Book Person View.
 */
-(void) showPersonByName: (CFStringRef)name;

@end
