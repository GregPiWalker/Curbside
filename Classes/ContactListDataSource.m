//
//  ContactListDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactListDataSource.h"
#import "Contact.h"
#import "Constants.h"
#import "ObservableMutableArray.h"
#import "TableCellFactory.h"
#import "OrderedMutableDictionary.h"
#import "ModificationTracker.h"

static const NSInteger lastNextRowIndex = 5;
static NSString *const addressKey = @"address";
static NSString *const addressLabel = @"Street";
static NSString *const cityKey = @"city";
static NSString *const cityLabel = @"City";
static NSString *const stateKey = @"state";
static NSString *const stateLabel = @"State";
static NSString *const zipKey = @"zip";
static NSString *const zipLabel = @"Zip Code";
static NSString *const emailKey = @"email";
static NSString *const emailLabel = @"Email";
static NSString *const phoneKey = @"phone";
static NSString *const phoneLabel = @"Phone";

/**
 This Macro expands into Category Interface & Implementation for ContactListDataSource that add collection
 observation on the contacts property.
 */
//OBSERVABLE_MUTABLE_ARRAY(ContactListDataSource, Contacts, contacts)


@interface ContactListDataSource ()

-(NSString *) labelToKey: (NSString *)label;

-(void) subscribeToContactPropertyChanges: (BOOL)yesNo forContact: (Contact *)c;

@end


@implementation ContactListDataSource


#pragma mark Properties

@synthesize contactData;
@synthesize sectionTitle;
@synthesize fieldBeingEdited;
@synthesize enableEdit = isEditEnabled;
@synthesize contacts;

@synthesize tableView;
-(void) setTableView:(UITableView *)tv {
    if (tv == tableView) {
        return;
    }
    [tableView autorelease];
    tableView = [tv retain];
    if (tableView != nil) {
        tableView.dataSource = self;
    }
}

@dynamic address;
-(NSString *) address {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: addressKey]) {
        return [contactProps objectForKey: addressKey];
    }
    else {
        return ((Contact *)[contacts objectAtIndex: currentSection]).address;
    }
}
-(void) setAddress: (NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: addressKey];
}

@dynamic city;
-(NSString *) city {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: cityKey]) {
        return [contactProps objectForKey: cityKey];
    }
    else {
        return [[contacts objectAtIndex: currentSection] city];
    }
}
-(void) setCity:(NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: cityKey];
}

@dynamic state;
-(NSString *) state {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: stateKey]) {
        return [contactProps objectForKey: stateKey];
    }
    else {
        return ((Contact *)[contacts objectAtIndex: currentSection]).state;
    }
}
-(void) setState:(NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: stateKey];
}

@dynamic zip;
-(NSString *) zip {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: zipKey]) {
        return [contactProps objectForKey: zipKey];
    }
    else {
        return [[contacts objectAtIndex: currentSection] getZipAsString];
    }
}
-(void) setZip: (NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: zipKey];
}

@dynamic phone;
-(NSString *) phone {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: phoneKey]) {
        return [contactProps objectForKey: phoneKey];
    }
    else {
        return [[contacts objectAtIndex: currentSection] phone];
    }
}
-(void) setPhone: (NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: phoneKey];
}

@dynamic email;
-(NSString *) email {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    if ([[contactProps allKeys] containsObject: emailKey]) {
        return [contactProps objectForKey: emailKey];
    }
    else {
        return [[contacts objectAtIndex: currentSection] email];
    }
}
-(void) setEmail: (NSString *)value {
    NSMutableDictionary *contactProps = (NSMutableDictionary *)[changedProperties objectAtIndex: currentSection];
    [contactProps setValue: value forKey: emailKey];
}

@dynamic currentContact;
-(Contact *) currentContact {
    Contact *current = (Contact *)[contacts objectAtIndex: currentSection];
    // If modifications exist on the current contact, return a new object with the changes.
    if ([[changedProperties objectAtIndex: currentSection] count] > 0) {
        // Get a new Ident too.
        current = [[[Contact alloc] init] autorelease];
        current.address = self.address;
        current.city = self.city;
        current.state = self.state;
        current.zip = [self.zip integerValue];
        current.phone = self.phone;
        current.email = self.email;
    }
    // Otherwise, return the unchanged original object.
    return current;
}


#pragma mark - Methods

/// The designated initializer might be used by a XIB that loads an instance of this DataSource.
-(id) init {
    self = [super init];
    if (self) {
        isEditEnabled = NO;
        isReloadNeeded = NO;
        sectionTitle = @"Contact Details";
        self.contacts = [NSMutableArray array];
        changedProperties = [[NSMutableArray alloc] init];
        // Set up the contactData dictionary to point at the Property accessors.
        self.contactData = [OrderedMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects: [NSValue valueWithPointer:@selector(address)], 
                                                                            [NSValue valueWithPointer: @selector(city)], 
                                                                            [NSValue valueWithPointer: @selector(state)],
                                                                            [NSValue valueWithPointer: @selector(zip)], 
                                                                            [NSValue valueWithPointer: @selector(email)], 
                                                                            [NSValue valueWithPointer: @selector(phone)], 
                                                                            nil] 
                                                                   forKeys: [NSArray arrayWithObjects: addressLabel, cityLabel, stateLabel, zipLabel, emailLabel, phoneLabel, nil]];
    }
    return self;
}

-(id) initWithContacts: (NSArray *)data {
    // Start with the designated initializer.
    self = [self init];
    // Then do customizations.
    if (self) {
        // Set Contacts last, as this will trigger the PopulateWithContactData call.
        [self populateContacts: data];
    }
    return self;
}

/// Populate the contacts list and generate the collection modification notices.
-(void) populateContacts: (NSArray *)data {
    // Remove any previous data.
    if ([contacts count] > 0) {
        [self removeAllContacts];
    }
    // For each contact, add an empty mutable dictionary to hold any value changes to that contact.
    for (Contact *c in data) {
        [changedProperties addObject: [NSMutableDictionary dictionary]];
        // Also, subscribe to Contact changes.
        [self subscribeToContactPropertyChanges: YES forContact: c];
    }
    // Now add the new contacts to the list and send change notifications.
    NSMutableArray *proxyContacts = [self mutableArrayValueForKey: contactsKey];
    [proxyContacts addObjectsFromArray: data];
    // Indicate that the TableData needs to be reloaded now.
    isReloadNeeded = YES;
}

-(void) reloadTableData {
    if (isReloadNeeded) {
        [tableView reloadData];
        isReloadNeeded = NO;
    }
}

/// Resets the UI state, but does nothing with the data.
-(void) reset {
    for (NSMutableDictionary *d in changedProperties) {
        [d removeAllObjects];
    }
    isReloadNeeded = YES;
    
    // If a field is being edited, tell the field to resign status.
    if (self.fieldBeingEdited) {
        [self.fieldBeingEdited resignFirstResponder];
        self.fieldBeingEdited = nil;
    }
}

/** dismissKeyboard
 */
-(void) dismissKeyboard {
    // If a field is being edited, tell the field to resign status before applying changes.
    if (self.fieldBeingEdited) {
        [self.fieldBeingEdited resignFirstResponder];
        self.fieldBeingEdited = nil;
    }
}

-(void) selectTextFieldInRow: (NSInteger)row {
    // the user pressed the "Next" button, so select the next row.
    UITableViewCell *next = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection: 0]];
    for (UIView *sv in [next.contentView subviews]) {
        if ([sv isKindOfClass: [UITextField class]]) {
            self.fieldBeingEdited = (UITextField *)sv;
            [sv becomeFirstResponder];
            break;
        }
    }
}

-(NSString *) labelToKey: (NSString *)label {
    NSString *key = @"";
    if ([label isEqualToString:addressLabel]) {
        key = addressKey;
    }
    else if ([label isEqualToString:cityLabel]) {
        key = cityKey;
    }
    else if ([label isEqualToString:stateLabel]) {
        key = stateKey;
    }
    else if ([label isEqualToString:zipLabel]) {
        key = zipKey;
    }
    else if ([label isEqualToString:emailLabel]) {
        key = emailKey;
    }
    else if ([label isEqualToString:phoneLabel]) {
        key = phoneKey;
    }
    return key;
}

/// applyChanges
///
/// Set any outstanding editor changes onto the Contact object backing this DataSource.
/// For now, return an empty ModificationTracker.  If multiple Contacts are handled, this will change.
-(ModificationTracker *) applyChanges {
    // If a field is being edited, tell the field to resign status before applying changes.
    if (self.fieldBeingEdited) {
        [self.fieldBeingEdited resignFirstResponder];
        self.fieldBeingEdited = nil;
    }
    
    ModificationTracker *mods = [[[ModificationTracker alloc] init] autorelease];
    
    for (int i = 0; i < [contacts count]; i++) {
        Contact *contact = [contacts objectAtIndex: i];
        
        // Stop listening to Contact property changes since they were already handled directly.
        [self subscribeToContactPropertyChanges: NO forContact: contact];
        
        NSMutableDictionary *changes = [changedProperties objectAtIndex: i];
        // Sync contact info.
        for (NSString *propertyKey in changes) {
            if ([contact respondsToSelector: NSSelectorFromString(propertyKey)]) {
                [contact setValue: [changes objectForKey: propertyKey] forKey: propertyKey];
            }
        }
        // Since they have been applied, clear property changes.
        [changes removeAllObjects];
          
        // Restart listening to Contact property changes now that direct changes are applied.
        [self subscribeToContactPropertyChanges: YES forContact: contact];
    }
    
    return mods;
}

/// addContact
/// Add a contact to the collection and send a notification message.
-(void) addContact: (Contact *)c {
    if (c && ![self.contacts containsObject: c]) {
        NSMutableArray *proxyContacts = [self mutableArrayValueForKey: contactsKey];
        [proxyContacts addObject: c];
        // For each new contact, add an empty mutable dictionary to hold any value changes to that contact.
        [changedProperties addObject: [NSMutableDictionary dictionary]];
        isReloadNeeded = YES;
        // Subscribe to each new contact.
        [self subscribeToContactPropertyChanges: YES forContact: c];
    }
}

//-(void) setContact: (Contact *)c forSection: (NSInteger)section {
//    if (c && ![self.contacts containsObject: c] && section < [contacts count]) {
//        NSMutableArray *proxyContacts = [self mutableArrayValueForKey: contactsKey];
//        Contact *old = [proxyContacts objectAtIndex: section];
//        [self subscribeToContactPropertyChanges: NO forContact: old];
//        [proxyContacts removeObjectAtIndex: section];
//        [proxyContacts insertObject: c atIndex: section];
//        // Clear any changes for the object at the given index.
//        //[[changedProperties objectAtIndex: section] removeAllObjects];
//        //[self subscribeToContactPropertyChanges: YES forContact: c];
//    }
//}

/// removeContact
/// Remove a contact from the collection and send a notification message.
-(void) removeContact: (Contact *)c {
    NSInteger index = [self.contacts indexOfObject: c];
    if (index != NSNotFound) {
        NSMutableArray *proxyContacts = [self mutableArrayValueForKey: contactsKey];
        [proxyContacts removeObjectAtIndex: index];
        // Remove the pertinent change tracking object at the given index.
        [changedProperties removeObjectAtIndex: index];
        isReloadNeeded = YES;
        // Unsubscribe from the old contact.
        [self subscribeToContactPropertyChanges: NO forContact: c];
    }
}

-(void) removeAllContacts {
    // First, unsubscribe to all the existing contacts.
    for (Contact *c in contacts) {
        [self subscribeToContactPropertyChanges: NO forContact: c];
    }
    // Next, remove all of the change tracking data.
    [changedProperties removeAllObjects];
    // Finally, empty the contacts array and send notifications.
    NSMutableArray *proxyContacts = [self mutableArrayValueForKey: contactsKey];
    [proxyContacts removeAllObjects];
    isReloadNeeded = YES;
}

-(void) dealloc {
    self.contactData = nil;
    // Must unsubscribe from each Contact before nullifying the array.
    for (Contact *c in contacts) {
        [self subscribeToContactPropertyChanges: NO forContact: c];
    }
    self.contacts = nil;
    self.fieldBeingEdited = nil;
    [sectionTitle release];
    [changedProperties release];
    [super dealloc];
}

#pragma mark UITableViewDataSource Methods

/** canEditRowAtIndexPath
 */
//-(BOOL) tableView: (UITableView *)tv canEditRowAtIndexPath: (NSIndexPath *)indexPath {
//    return NO;
//}

/** cellForRowAtIndexPath
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *editableCellIdentifier = @"editableContactTextCell";
    static NSString *textCellIdentifier = @"contactTextCell";
    UITableViewCell *cell;
    NSString *key = [[contactData allKeys] objectAtIndex: indexPath.row];
    NSString *description = key;
    NSString *text = nil;
    BOOL isPhoneCell = [key isEqualToString:phoneLabel];
    BOOL isEmailCell = [key isEqualToString:emailLabel];
    BOOL isZipCell = [key isEqualToString:zipLabel];
    //BOOL isStateCell = [key isEqualToString:stateLabel];
    UITableViewCellStyle immutableCellStyle = UITableViewCellStyleValue1;
    UIKeyboardType keyboardType = UIKeyboardTypeDefault;
    UIReturnKeyType returnType = UIReturnKeyNext;
    UITextAutocapitalizationType capsType = UITextAutocapitalizationTypeWords;
    
    // Make sure to set the section number of the desired cell before probing for values.
    currentSection = indexPath.section;
    // Convert the stored NSValue into a Selector and then that into a value.
    NSValue *value = [contactData objectForKey: key];
    SEL selector = [value pointerValue];
    text = [self performSelector:selector];
    
    // Set a special keyboard type for certain fields.
    if (isPhoneCell) {
        keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        returnType = UIReturnKeyDone;
    }
    else if (isEmailCell) {
        keyboardType = UIKeyboardTypeEmailAddress;
        capsType = UITextAutocapitalizationTypeNone;
    }
    else if (isZipCell) {
        keyboardType = UIKeyboardTypeNumberPad;
    }

    // For immutable cells, or cells with a non-text editor.
    if (!isEditEnabled) {
        cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                          withIdentifier: textCellIdentifier
                                                                 withTag: indexPath.row
                                                       withAccessoryType: UITableViewCellAccessoryNone
                                                           withCellStyle: immutableCellStyle
                                                              firstLabel: description 
                                                             secondLabel: text];

    }
    else {
        cell = [TableCellFactory createEditableTextCellForTable: tv 
                                                 withIdentifier: editableCellIdentifier 
                                                   withDelegate: self
                                               withKeyboardType: keyboardType
                                              withReturnKeyType: returnType
                                         withCapitalizationType: capsType
                                                        withTag: indexPath.row
                                                     withIndent: 10
                                                     firstLabel: description 
                                                    secondLabel: text];
    }
    // Tag the selected cell's ContentView with the section number.
    cell.contentView.tag = indexPath.section;
    
    return cell;
}

/// sectionForSectionIndexTitle
///
-(NSInteger) tableView: (UITableView *)tv sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    return index;
}

/** numberOfRowsInSection
 */
-(NSInteger) tableView: (UITableView *)tv numberOfRowsInSection: (NSInteger)sectionIndex {
    // Each section has the same length.
    return [contactData count];
}

/// titleForHeaderInSection
///
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    //if (isEditEnabled) {
        return nil;
    //}
    //return sectionTitle;
}

/// numberOfSectionsInTableView
///
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tv {
    return [contacts count];
}

/// sectionIndexTitlesForTableView
///
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *)tv {
    // Return nil so that the index is not created.
    return nil;
}


#pragma mark UITextFieldDelegate Methods

/// textFieldShouldReturn
///
-(BOOL) textFieldShouldReturn: (UITextField *)textField {
    if (textField.tag == lastNextRowIndex) {
        // The user pressed done button, so dismiss the keyboard.
        [textField resignFirstResponder];
        if (textField == self.fieldBeingEdited) {
            self.fieldBeingEdited = nil;
        }
        return YES;
    }
    else {
        // the user pressed the "Next" button, so select the next row.
        [self selectTextFieldInRow: textField.tag + 1];
        return NO;
    }
}

/// textFieldDidBeginEditing
///
-(void) textFieldDidBeginEditing: (UITextField *)textField {
    self.fieldBeingEdited = textField;
}

/// textFieldDidEndEditing
///
/// Handles when a TextField is done being edited.  The new text value is entered into the data source
/// at the appropriate location.
-(void) textFieldDidEndEditing: (UITextField *)textField {
    NSString *newText = textField.text;
    // Obtain the row from the TextField's tag.
    NSInteger row = textField.tag;
    NSString *label = [[contactData allKeys] objectAtIndex: row];
    
    // Row index determines which property is set.
    if (row < [contactData count]) {
        //NSValue *value = [contactData objectForKey: label];
        //NSString *property = [self performSelector: [value pointerValue]];
        NSString *key = [self labelToKey: label];
        [self setValue: newText forKey: key];
    }
    
    self.fieldBeingEdited = nil;
}


#pragma mark Event Handling

/// observeValueForKeyPath
/// Handle changes to Contact Property values.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([contacts containsObject: object]) {
        isReloadNeeded = YES;
    }
}

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver: observer forKeyPath: fieldBeingEditedKey options: NSKeyValueObservingOptionNew context: self];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver: observer forKeyPath: fieldBeingEditedKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

///
-(void) subscribeToContactPropertyChanges: (BOOL)yesNo forContact: (Contact *)c {
    if (yesNo) {
        [c addPropertyChangeObserver:self];
    }
    else {
        @try {
            [c removePropertyChangeObserver:self];
        }
        @catch (NSException *ex) {
            // Nothing.
        }
    }
}

@end
