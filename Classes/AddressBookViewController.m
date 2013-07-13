    //
//  AddressBookViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressBookViewController.h"


@implementation AddressBookViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
 }
 
 - (id)init {
    self = [super initWithNibName: @"AddressBookView" bundle: nil];
    if (self) {
    // Custom initialization.
    self.title = @"Address Book";
    }
    return self;
 }

-(IBAction) viewAllContactsAction: (id)sender {
    ABPeoplePickerNavigationController *contactBrowser = [[ABPeoplePickerNavigationController alloc] init];
    
    contactBrowser.peoplePickerDelegate = self;
    //contactBrowser.displayedProperties = 
    
    [self presentModalViewController: contactBrowser animated:YES];
    
    [contactBrowser release];
}

-(IBAction) viewContactAction: (id)sender {
    [self showPersonByName: CFSTR("Greg")];
}

-(void) showPersonByName: (CFStringRef)name {
    // Fetch the address book.
    ABAddressBookRef addressBook = ABAddressBookCreate();
    // Search for the named person in the address book.
    NSArray *people = (NSArray *)ABAddressBookCopyPeopleWithName(addressBook, name);
    ABRecordRef person;
    
    // Display person's information if found in the address book.
    if ((people != nil) && [people count])
    {
        person = (ABRecordRef)[people objectAtIndex:0];
    }
    else 
    {
        // Otherwise, show an empty person.
        person = ABPersonCreate();
    }
    
    ABPersonViewController *contactViewer = [[ABPersonViewController alloc] init];
    contactViewer.personViewDelegate = self;
    contactViewer.displayedPerson = person;
    // Allow users to edit the person’s information
    contactViewer.allowsEditing = YES;
    contactViewer.displayedProperties = [NSArray arrayWithObjects: 
                                                                 [NSNumber numberWithInt: kABPersonPhoneProperty], 
                                                                 [NSNumber numberWithInt: kABPersonEmailProperty],
                                                                 [NSNumber numberWithInt: kABPersonBirthdayProperty], nil];
    
    [self.navigationController pushViewController:contactViewer animated:YES];

    [people release];
    CFRelease(addressBook);
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark ABPeoplePickerNavigationController Methods

-(BOOL) peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson: (ABRecordRef)person {
    return YES;
}

-(BOOL) peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson: (ABRecordRef)person 
                                property: (ABPropertyID)property 
                              identifier: (ABMultiValueIdentifier)identifier {
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

-(void) peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate Methods
-(BOOL) personViewController: (ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson: (ABRecordRef)person 
                                                                                                                property: (ABPropertyID)property 
                                                                                                                identifier: (ABMultiValueIdentifier)identifierForValue {
    return NO;
}
@end
