//
//  PatientDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatientDataSource.h"
#import "Constants.h"
#import "TableCellFactory.h"
#import "NotificationArgs.h"
#import "ModificationTracker.h"
#import "Patient.h"
#import "Prescription.h"
#import "Visit.h"
#import "Pharmacy.h"
#import "Contact.h"


static NSString *const firstNameKey = @"firstName";
static NSString *const lastNameKey = @"lastName";
static NSString *const addressKey = @"address";
static NSString *const cityKey = @"city";
static NSString *const stateKey = @"state";
static NSString *const zipKey = @"zip";
static NSString *const emailKey = @"email";
static NSString *const phoneKey = @"phone";
static NSString *const addPharmacyLabel = @"Add Pharmacy";
static NSString *const addAllergyLabel = @"Add Allergy";
static NSString *const addMedicationLabel = @"Add Medication";
static const NSInteger numStaticSections = 2;
/// This indicates the index of the last row for the "Next" keyboard button.
static const NSInteger lastNextRowIndex = 5;
/// This indicates the index of the last section for the "Next" keyboard button.
static const NSInteger lastNextSectionIndex = 1;


/**
 Provide an empty catagory to house private method definitions.
 */
@interface PatientDataSource ()

-(void) populateWithPatientData;

-(void) subscribeToPatientPropertyChanges: (BOOL)yesNo;

-(void) subscribeToAppNotifications: (BOOL)yesNo;

-(void) handleDateSortSettingChanged: (NSNotification *)notification;

-(void) handleVisitUpdated: (NSNotification *)notification;

-(void) handlePharmacyUpdated: (NSNotification *)notification;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

-(void) refreshPharmacyCollection;

-(void) postInsertRowAtIndexPath: (NSIndexPath *)indexPath;

-(void) postRemoveRow;

-(void) sortPriorVisitsByDate;

-(void) selectTextFieldAtIndex: (NSIndexPath *)index;

-(UITableViewCell *) cellForPersonalInfoSectionOfTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath;

-(UITableViewCell *) cellForAllergyAndMedSectionsOfTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath;

-(UITableViewCell *) cellForVisitSectionOfTableView: (UITableView *)tv atRow: (NSInteger)row;

-(UITableViewCell *) cellForPharmacySectionOfTableView: (UITableView *)tv atRow: (NSInteger)row;

@end


@implementation PatientDataSource


#pragma mark - Properties

@synthesize isReloadNeeded;
@synthesize longPressHandler;
@synthesize sectionedData;
@synthesize orderedSectionTitles;
@synthesize isEditing;
@synthesize fieldBeingEdited;
@synthesize isObservingPatient;
@synthesize extraRowCount;
@synthesize lastAddedIndexPath;
@synthesize allergies;
@synthesize pharmacies;
@synthesize priorVisits = visits;
@synthesize medications;
@synthesize isEditEnabled;

@synthesize canSelectVisits;
-(BOOL) canSelectVisits {
    return (canSelectVisits && !isEditEnabled);
}

@dynamic extraSectionCount;
-(NSInteger) extraSectionCount {
    if (tableView == nil) {
        return 0;
    }
    return [self numberOfSectionsInTableView:tableView] - numStaticSections;
}

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

/// This is any PropertyChangePublisher that has a 'prescriptions' collection.
//@synthesize dataOwner;
//-(void) setDataOwner:(NSObject<PropertyChangePublisher> *)dO {
//    if (dO == dataOwner) {
//        return;
//    }
//    if (dataOwner != nil) {
//        [self subscribeToPrescriptionPropertyChanges:NO];
//    }
//    [dataOwner autorelease];
//    dataOwner = [dO retain];
//    
//    if (dataOwner != nil) {
//        self.prescriptions = [NSMutableArray arrayWithArray:[dO valueForKey:prescriptionsKey]];
//        self.extraRowCount = [self.prescriptions count];
//        [self refreshRxCollection];
//        [self subscribeToPrescriptionPropertyChanges:YES];
//    }
//    else {
//        [self.prescriptions removeAllObjects];
//        self.extraRowCount = 0;
//    }
//    self.isReloadNeeded = YES;
//}

@synthesize patient;
/** Custom Patient propety setter keeps the event subscriptions fresh. */
-(void) setPatient:(Patient *)p {
    if (patient == p) {
        return;
    }
    if (patient != nil) {
        // Unsubscribe from the old patient
        [self subscribeToPatientPropertyChanges: NO];
    }
    [patient autorelease];    
    patient = [p retain];
    
    [self refreshPharmacyCollection];
    [self refreshSectionHeadings];
    if (patient != nil) {
        self.isReloadNeeded = YES;
        [self populateWithPatientData];
        // Subscribe to the new patient.
        [self subscribeToPatientPropertyChanges: YES];
    }
}

@dynamic firstName;

-(NSString *) firstName {
    if ([[changedProperties allKeys]  containsObject: firstNameKey]) {
        return [changedProperties objectForKey: firstNameKey];
    }
    else {
        return patient.firstName;
    }
}

-(void) setFirstName: (NSString *)value {
    [changedProperties setValue: value forKey: firstNameKey];
}

@dynamic lastName;

-(NSString *) lastName {
    if ([[changedProperties allKeys]  containsObject: lastNameKey]) {
        return [changedProperties objectForKey: lastNameKey];
    }
    else {
        return patient.lastName;
    }
}

-(void) setLastName: (NSString *)value {
    [changedProperties setValue: value forKey: lastNameKey];
}

@dynamic dateOfBirth;

-(NSString *) dateOfBirth {
    if ([[changedProperties allKeys]  containsObject: dateOfBirthKey]) {
        return [changedProperties objectForKey: dateOfBirthKey];
    }
    else {
        return [patient getBirthdayAsString];
    }
}

-(void) setDateOfBirth: (NSString *)value {
    [changedProperties setValue: value forKey: dateOfBirthKey];
}

@dynamic age;

-(NSString *) age {
    return [patient ageAsString];
}

@dynamic address;

-(NSString *) address {
    if ([[changedProperties allKeys]  containsObject: addressKey]) {
        return [changedProperties objectForKey: addressKey];
    }
    else {
        return patient.contactInfo.address;
    }
}

-(void) setAddress: (NSString *)value {
    [changedProperties setValue: value forKey: addressKey];
}

@dynamic city;

-(NSString *) city {
    if ([[changedProperties allKeys]  containsObject: cityKey]) {
        return [changedProperties objectForKey: cityKey];
    }
    else {
        return patient.contactInfo.city;
    }
}

-(void) setCity:(NSString *)value {
    [changedProperties setValue: value forKey: cityKey];
}

@dynamic state;

-(NSString *) state {
    if ([[changedProperties allKeys]  containsObject: stateKey]) {
        return [changedProperties objectForKey: stateKey];
    }
    else {
        return patient.contactInfo.state;
    }
}

-(void) setState:(NSString *)value {
    [changedProperties setValue: value forKey: stateKey];
}

@dynamic zip;

-(NSString *) zip {
    if ([[changedProperties allKeys]  containsObject: zipKey]) {
        return [changedProperties objectForKey: zipKey];
    }
    else {
        return [patient.contactInfo getZipAsString];
    }
}

-(void) setZip: (NSString *)value {
    [changedProperties setValue: value forKey: zipKey];
}

@dynamic phone;

-(NSString *) phone {
    if ([[changedProperties allKeys]  containsObject: phoneKey]) {
        return [changedProperties objectForKey: phoneKey];
    }
    else {
        return patient.contactInfo.phone;
    }
}

-(void) setPhone: (NSString *)value {
    [changedProperties setValue: value forKey: phoneKey];
}

@dynamic email;

-(NSString *) email {
    if ([[changedProperties allKeys]  containsObject: emailKey]) {
        return [changedProperties objectForKey: emailKey];
    }
    else {
        return patient.contactInfo.email;
    }
}

-(void) setEmail: (NSString *)value {
    [changedProperties setValue: value forKey: emailKey];
}

@dynamic personalInfoLabel;
-(NSString *) personalInfoLabel {
    return personalInfoLabel;
}

@dynamic allergiesLabel;
-(NSString *) allergiesLabel {
    return allergiesLabel;
}

@dynamic pharmaciesLabel;
-(NSString *) pharmaciesLabel {
    return pharmaciesLabel;
}

@dynamic medicationsLabel;
-(NSString *) medicationsLabel {
    return medicationsLabel;
}

@dynamic visitHistoryLabel;
-(NSString *) visitHistoryLabel {
    return visitHistoryLabel;
}


#pragma mark - Methods

/**
 Initialize a PatientDataSource without any Patient data yet.  TableCells default to editable.
 */
-(id) init {
    self = [self initWithPatient: nil allowCellEdit: YES];
    
    return self;
}

/**
 Initialize a PatientDataSource using the given Patient.  TableCell editability is set to isEditable value.
 */
-(id) initWithPatient: (Patient *)p allowCellEdit: (BOOL)allowEdit {
    self = [super init];
    if (self) {
        self.isReloadNeeded = NO;
        lastAddedIndexPath = nil;
        isEditEnabled = allowEdit;
        self.isEditing = NO;
        canSelectVisits = YES;
        changedProperties = [[NSMutableDictionary alloc] init];
        groupedPropertyNames = [[NSArray arrayWithObjects: [NSArray arrayWithObjects: firstNameKey, lastNameKey, dateOfBirthKey, nil],
                                 [NSArray arrayWithObjects: addressKey, cityKey, stateKey, zipKey, emailKey, phoneKey, nil],
                                 nil] retain];
        [self subscribeToAppNotifications: YES];
        // Set Patient last, as this will trigger the PopulateWithPatientData call.
        self.patient = p;
    }
    return self;
}

/** applyChanges
 Set any outstanding editor changes onto the Patient object backing this DataSource.
 */
-(ModificationTracker *) applyChanges {
    // If a field is being edited, tell the field to resign status before applying changes.
    if (self.fieldBeingEdited) {
        [self.fieldBeingEdited resignFirstResponder];
        self.fieldBeingEdited = nil;
    }
    
    // Stop listening to Patient property changes since they were already handled directly.
    [self subscribeToPatientPropertyChanges:NO];
    
    ModificationTracker * mods = [[[ModificationTracker alloc] init] autorelease];
    
    // Sync personal and contact info.
    for (NSString *propertyKey in changedProperties) {
        if ([patient respondsToSelector: NSSelectorFromString(propertyKey)]) {
            [patient setValue: [changedProperties objectForKey: propertyKey] forKey: propertyKey];
        }
        else if ([patient.contactInfo respondsToSelector: NSSelectorFromString(propertyKey)]) {
            [patient.contactInfo setValue: [changedProperties objectForKey: propertyKey] forKey: propertyKey];
        }
    }
    // Since they have been applied, clear property changes.
    [changedProperties removeAllObjects];
    
    // ALLERGY SYNC
    NSArray *algsCopy = [patient.allergies copy];
    // Sync deleted allergies.
    [algsCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![self.allergies containsObject:obj]) {
                [patient removeAllergy:obj];
            }
        }];
    [algsCopy release];
    algsCopy = [NSMutableArray arrayWithArray: self.allergies];
    // Remove duplicates, leaving only new additions.
    [patient.allergies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSMutableArray*)algsCopy removeObject:obj];
    }];
    // Add the new allergies to the patient.
    for (NSString *allergy in algsCopy) {
        if (![allergy isEqualToString: @""] && ![allergy isEqualToString: [algsCopy lastObject]]) {
            //[proxyAllergies addObject: allergy];
            [patient addAllergy:allergy];
        }
    }
    
    // MEDICATION SYNC
    NSArray *medsCopy = [patient.medications copy];
    // Sync deleted medications.
    [medsCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![self.medications containsObject:obj]) {
                [patient removeMedication:obj];
            }
        }];
    [medsCopy release];
    medsCopy = [NSMutableArray arrayWithArray: self.medications];
    // Remove duplicates, leaving only new additions.
    [patient.medications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSMutableArray*)medsCopy removeObject:obj];
    }];
    // Add the new medications to the patient.
    for (NSString *medication in medsCopy) {
        // This prevents the "Add Medication" cell from being used.
        if (![medication isEqualToString: @""] && ![medication isEqualToString: [medsCopy lastObject]]) {
            [self.patient addMedication:medication];
        }
    }
    
    // PHARMACY SYNC
    NSArray *pharmsCopy = [patient.pharmacies copy];
    NSMutableArray *changes = [NSMutableArray array];
    // Sync any deleted pharmacies with the Patient and the ApplicationSupervisor.
    [pharmsCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.pharmacies containsObject:obj]) {
            // Remove the Pharmacy from the Patient's list, which will also decrement the Pharm reference count.
            [patient removePharmacy: (Pharmacy *)obj];
            // Set a new default if necessary.
            if (patient.defaultPharmacy == nil && [patient.pharmacies count] > 0) {
                patient.defaultPharmacy = [patient.pharmacies objectAtIndex:0];
            }
            // Only include the Pharmacy to be deleted if its reference count is now zero.
            if (((Pharmacy *)obj).referenceCount == 0) {
                [changes addObject: obj];
            }
        }
    }];
    if ([changes count] > 0) {
        [mods setDeletions: changes ForClass: [Pharmacy class]];
        [changes removeAllObjects];
    }
    [pharmsCopy release];
    pharmsCopy = [NSMutableArray arrayWithArray: self.pharmacies];
    // Remove duplicates, leaving only new additions.
    [patient.pharmacies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSMutableArray*)pharmsCopy removeObject:obj];
    }];
    // Add the new pharmacies to the patient and the ApplicationSupervisor.
    for (id pharmacy in pharmsCopy) {
        // Prevent the "Add Pharmacy" cell from being used.
        if ([pharmacy isKindOfClass: [Pharmacy class]]) {
            // Add the Pharmacy to the Patient's list, which also increments the Pharmacy reference count.
            [self.patient addPharmacy: (Pharmacy *)pharmacy];
            // Only include the Pharmacy to be created if it does not yet exist.
            if (nil == [[ApplicationSupervisor instance] pharmacyWithIdent: ((Pharmacy *)pharmacy).ident]) {
                [changes addObject: pharmacy];
            }
        }
    }
    if ([changes count] > 0) {
        [mods setAdditions: changes ForClass: [Pharmacy class]];
    }
    
    // Restart listening to Patient property changes now that direct changes are applied.
    [self subscribeToPatientPropertyChanges:YES];
    
    return mods;
}

/// forgetChanges
///
/// Forget all changes marked for the Patient object backing this DataSource.
-(void) forgetChanges {
    [changedProperties removeAllObjects];
    
    if (patient) {
        self.pharmacies = [NSMutableArray arrayWithArray: patient.pharmacies];
        self.medications = [NSMutableArray arrayWithArray: patient.medications];
        self.allergies = [NSMutableArray arrayWithArray: patient.allergies];
    }
    else {
        [self.pharmacies removeAllObjects];
        [self.medications removeAllObjects];
        [self.allergies removeAllObjects];
    }
    
    if (isEditEnabled) {
        [self.pharmacies addObject: addPharmacyLabel];
        [self.medications addObject: addMedicationLabel];
        [self.allergies addObject: addAllergyLabel];
    }
    
    // If a field is being edited, tell the field to resign status.
    if (self.fieldBeingEdited) {
        [self.fieldBeingEdited resignFirstResponder];
        self.fieldBeingEdited = nil;
    }
}

///  
-(void) refreshSectionHeadings {
    // Reset the array on every refresh to ensure that the sections always fall in the same order.
    self.orderedSectionTitles = [NSMutableArray arrayWithObjects: personalInfoLabel, contactInfoLabel, nil];
    
    if ([self.allergies count] > 0) {
        [self.orderedSectionTitles addObject:allergiesLabel];
    }
    if ([self.medications count] > 0) {
        [self.orderedSectionTitles addObject:medicationsLabel];
    }
    if ([self.pharmacies count] > 0) {
        [self.orderedSectionTitles addObject:pharmaciesLabel];
    }
    // Visits are only visible when not in edit mode.
    if (!isEditEnabled && [self.priorVisits count] > 0) {
        [self.orderedSectionTitles addObject:visitHistoryLabel];
    }
}

-(void) refreshPharmacyCollection {
    if (isEditEnabled) { 
        if (![[self.pharmacies lastObject] isEqual:addPharmacyLabel]) {
            [self.pharmacies addObject: addPharmacyLabel];
            self.isReloadNeeded = YES;
        }
    }
    else if ([[self.pharmacies lastObject] isEqual:addPharmacyLabel]) {
        [self.pharmacies removeLastObject];
        self.isReloadNeeded = YES;
    }
}

-(void) reset {
    [self.pharmacies removeAllObjects];
    //TODO: SEE IF THIS NEXT LINE IS NEEDED.  IT WAS MISSING UNTIL LATE MAY....
    [self forgetChanges];
    [self refreshPharmacyCollection];
    [self refreshSectionHeadings];
    self.extraRowCount = 0;
}

-(void) reloadTableData {
    if (isReloadNeeded) {
        [tableView reloadData];
        self.isReloadNeeded = NO;
    }
}

-(void) selectTextFieldAtIndex: (NSIndexPath *)index {
    // the user pressed the "Next" button, so select the next row.
    UITableViewCell *next = [tableView cellForRowAtIndexPath: index];
    for (UIView *sv in [next.contentView subviews]) {
        if ([sv isKindOfClass: [UITextField class]]) {
            self.fieldBeingEdited = (UITextField *)sv;
            [sv becomeFirstResponder];
            break;
        }
    }
}

/** populateWithPatientData
 */
-(void) populateWithPatientData {
    NSArray *personalDataKeys;
    NSArray *personalDataValues;
    // Clear any outstanding marked changes.
    [changedProperties removeAllObjects];
    
    if (isEditEnabled) {
        // Dont show age while editing since it's auto-calculated.
        personalDataKeys = [NSArray arrayWithObjects: @"First Name", @"Last Name", @"Date of Birth", nil];
        personalDataValues = [NSMutableArray arrayWithObjects: [NSValue valueWithPointer:@selector(firstName)], 
                                                              [NSValue valueWithPointer:@selector(lastName)], 
                                                              [NSValue valueWithPointer:@selector(dateOfBirth)], 
                                                              nil];
    }
    else {
        personalDataKeys = [NSArray arrayWithObjects: @"First Name", @"Last Name", @"Date of Birth", @"Age", nil];
        personalDataValues = [NSMutableArray arrayWithObjects: [NSValue valueWithPointer:@selector(firstName)], 
                                                              [NSValue valueWithPointer:@selector(lastName)], 
                                                              [NSValue valueWithPointer:@selector(dateOfBirth)],
                                                              [NSValue valueWithPointer:@selector(age)], 
                                                              nil];
    }
    
    self.sectionedData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          // The personal info is entered as a <Dictionary <[keys], [value selectors]>>
                          [NSDictionary dictionaryWithObjectsAndKeys: 
                                                    personalDataKeys, kDataGroupKeys,
                                                    personalDataValues, kDataGroupValues,
                                                    nil], personalInfoLabel,
                          // The contact info is entered as a <Dictionary <[keys], [value selectors]>>
                          [NSDictionary dictionaryWithObjectsAndKeys: 
                                                    [NSArray arrayWithObjects: @"Street", @"City", @"State", @"Zip", @"Email", @"Phone", nil], kDataGroupKeys,
                                                    [NSMutableArray arrayWithObjects: [NSValue valueWithPointer:@selector(address)], 
                                                                                     [NSValue valueWithPointer:@selector(city)], 
                                                                                     [NSValue valueWithPointer:@selector(state)], 
                                                                                     [NSValue valueWithPointer:@selector(zip)], 
                                                                                     [NSValue valueWithPointer:@selector(email)], 
                                                                                     [NSValue valueWithPointer:@selector(phone)], 
                                                                                     nil], kDataGroupValues,
                                                    nil], contactInfoLabel,
                          nil];
    
    // Need to track how many rows to resize the table by.
    NSInteger addCount = 0;
    
    // Populate allergies.
    if ([patient.allergies count] > 0) {
        addCount += [patient.allergies count];
        self.allergies = [NSMutableArray arrayWithArray: patient.allergies];
    }
    else {
        self.allergies = [NSMutableArray array];
    }
    if (isEditEnabled) {
        [self.allergies addObject: addAllergyLabel];
    }
    [sectionedData setObject: [NSValue valueWithPointer:@selector(allergies)] forKey: allergiesLabel];
    
    // Populate current medications.
    if ([patient.medications count] > 0) {
        addCount += [patient.medications count];
        self.medications = [NSMutableArray arrayWithArray: patient.medications];
    }
    else {
        self.medications = [NSMutableArray array];
    }
    if (isEditEnabled) {
        [self.medications addObject: addMedicationLabel];
    }
    [sectionedData setObject: [NSValue valueWithPointer:@selector(medications)] forKey: medicationsLabel];
    
    // Populate pharmacies.
    if ([patient.pharmacies count] > 0) {
        addCount += [patient.pharmacies count];
        self.pharmacies = [NSMutableArray arrayWithArray:patient.pharmacies];
    }
    else {
        self.pharmacies = [NSMutableArray array];
    }
    if (isEditEnabled) {
        [self.pharmacies addObject: addPharmacyLabel];
    }
    [sectionedData setObject: [NSValue valueWithPointer:@selector(pharmacies)] forKey: pharmaciesLabel];
    
    // Visit history is only visible on the immutable view.
    if (!isEditEnabled) {
        // Populate visit history.
        if ([patient.priorVisits count] > 0) {
            addCount += [patient.priorVisits count];
            self.priorVisits = [NSMutableArray arrayWithArray: patient.priorVisits];
            [self sortPriorVisitsByDate];
        }
        else {
            self.priorVisits = [NSMutableArray array];
        }
        [sectionedData setObject: [NSValue valueWithPointer:@selector(priorVisits)] forKey: visitHistoryLabel];
    }
    
    self.extraRowCount = addCount;
    [self refreshSectionHeadings];
}

/// postInsertRowAtIndexPath
///
/// Take care of tasks that must occur after a row is inserted in the TableView, including
/// sending a notification of the change.
-(void) postInsertRowAtIndexPath: (NSIndexPath *)indexPath {
    self.extraRowCount += 1;
    [lastAddedIndexPath release];
    lastAddedIndexPath = [[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] retain];
    // Notify observers of the change.  Observer will handle the view resize.
    [self sendNotification:kTableRowInsertedNotification about:self];
}

/// postRemoveRowAtIndexPath
///
/// Take care of tasks that must occur after a row is removed in the TableView, including
/// sending a notification of the change.
-(void) postRemoveRow {
    self.extraRowCount -= 1;
    // Notify observers of the change.  Observer will handle the view resize.
    [self sendNotification:kTableRowRemovedNotification about:self];
}

/** indexPathOfBirthdayCell
 */
-(NSIndexPath *) indexPathOfBirthdayCell {
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

-(NSIndexPath *) indexPathOfStateCell {
    return [NSIndexPath indexPathForRow:2 inSection:1];
}

-(NSIndexPath *) indexPathOfZipCell {
    return [NSIndexPath indexPathForRow:3 inSection:1];
}

-(NSIndexPath *) indexPathOfEmailCell {
    return [NSIndexPath indexPathForRow:4 inSection:1];
}

-(NSIndexPath *) indexPathOfPhoneCell {
    return [NSIndexPath indexPathForRow:5 inSection:1];
}

-(void) insertRowForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath {
    if (tv == tableView) {
        // Insert the new row in the UI control.
        [tv insertRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation: YES];
        [self postInsertRowAtIndexPath:indexPath];
    }
}

-(void) removeRowForTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath {
    if (tv == tableView) {
        // Delete the row in the UI control.
        [tv deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: YES];
        [self postRemoveRow];
    }
}

-(NSInteger) sectionNumberForSectionTitle: (NSString *)sectionTitle {
    if ([self.orderedSectionTitles containsObject:sectionTitle]) {
        return [self.orderedSectionTitles indexOfObject:sectionTitle];
    }
    return NSNotFound;
}

-(id) dataItemForIndexPath: (NSIndexPath *)indexPath {
    if ([self.orderedSectionTitles count] >= indexPath.section) {
        NSValue *value = [self.sectionedData objectForKey:[self.orderedSectionTitles objectAtIndex:indexPath.section]];
        NSMutableArray *section = [self performSelector: [value pointerValue]];
        if ([section count] >= indexPath.row) {
            return [section objectAtIndex:indexPath.row];
        }
    }
    return nil;
}
     
//-(void) resizeTableView: (UITableView *)tv byHeight: (NSInteger)height {
//    CGRect newFrame = self.tableView.frame;
//    newFrame.size.height += height;
//    self.tableView.frame = newFrame;
//}

/// I don't think this is necessary anymore, since I delayed the Pharm row creation until the
/// AppSupervisor gets the createPharm message.
-(void) purgeUnfinishedRow {
    if (self.tableView && lastAddedIndexPath) {
        // Check to see if the last added pharmacy is incomplete, which indicates a cancellation.
        id lastPharm = [self.pharmacies objectAtIndex:lastAddedIndexPath.row];
        if ([lastPharm isKindOfClass:[NSString class]] && [lastPharm isEqualToString:@""]) {
            // MUST delete the datasource row before trying to remove the table row.
            [self.pharmacies removeObjectAtIndex:lastAddedIndexPath.row];
            //[self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:lastAddedIndexPath] withRowAnimation:NO];
            //[self.tableView endUpdates];
            self.extraRowCount -= 1;
            // Send a notification so any listeners can respond as they need to.
            [self sendNotification:kTableRowRemovedNotification about:lastPharm];
        }
        [lastAddedIndexPath release];
        lastAddedIndexPath = nil;
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

-(void) sortPriorVisitsByDate {
    NSComparisonResult sortOrder = [ApplicationSupervisor instance].dateSortOrderSetting;
    if (sortOrder == NSOrderedAscending) {
        [self.priorVisits sortUsingSelector:@selector(compare:)];
    }
    else {
        [self.priorVisits sortUsingSelector:@selector(reverseCompare:)];
    }
    isReloadNeeded = YES;
}


#pragma mark UITableViewDelegate Methods

/// editingStyleForRowAtIndexPath
///
-(UITableViewCellEditingStyle) tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only make certain collections have delete buttons.
    if ([allergiesLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]]
        || [pharmaciesLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]]
        || [medicationsLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]]) {
        if (indexPath.row + 1 == [self tableView:tv numberOfRowsInSection:indexPath.section]) {
            // If it's the last row, show the insert button.
            return UITableViewCellEditingStyleInsert;
        }
        else {
            // Otherwise, show the delete button.
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark UITableViewDataSource Methods

/** canEditRowAtIndexPath
 */
-(BOOL) tableView: (UITableView *)tv canEditRowAtIndexPath: (NSIndexPath *)indexPath {
    // Only make the collections have delete buttons and be indented.
    if (isEditEnabled &&
        ([allergiesLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]]
        || [pharmaciesLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]]
        || [medicationsLabel isEqual: [self.orderedSectionTitles objectAtIndex:indexPath.section]])) {
        return YES;
    }
    return NO;
}

//-(void) resizeViewForTable: (UITableView*)tableView atIndexPath: (NSIndexPath *)indexPath {
//    CGRect tvFrame = tableView.frame;
//    
//    // Make the TableView bounds grow with the cell.
//    tvFrame.size.height += tableView.rowHeight;
//}

/** commitEditingStyle
 */
-(void) tableView: (UITableView *)tv commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex:indexPath.section];
    NSValue *value = [sectionedData objectForKey: sectionTitle];
    NSMutableArray *section = [self performSelector: [value pointerValue]];
    
    // If a field is being edited when an edit button is pressed, tell the field to resign it's position.
    [self dismissKeyboard];
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert:
            if ([sectionTitle isEqualToString:pharmaciesLabel]) {
                // Create a new Pharmacy.
                Pharmacy *newPharm = [[Pharmacy alloc] init];
                // Send a request to show the EditPharmacyView.  A new row will be added by the event handler.
                [self sendNotification:kShowPharmacyViewNotification about: [NotificationArgs argsWithData:newPharm fromSender:self]];
                [newPharm release];
            }
            else {
                // Add blank row as a place-holder to the end of the data collection for the given section.
                [section insertObject: @"" atIndex: indexPath.row];
                // Add a row to the UI.  This must be done now for
                // in-place edited data so that a row of text is ready for the user.
                [self insertRowForTableView:tv atIndexPath:indexPath];
            }
            break;
            
        case UITableViewCellEditingStyleDelete:
//            if ([sectionTitle isEqualToString:pharmaciesLabel]) {
//                Pharmacy *pharm = [pharmacies objectAtIndex:indexPath.row];
//            }

            // Must remove the row from the data structure first, before changing the UI.
            [section removeObjectAtIndex: indexPath.row];
            // Remove the selected row from the UI for the given section.
            [self removeRowForTableView:tv atIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

/** cellForRowAtIndexPath
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex: indexPath.section];
    
    if ([sectionTitle isEqual: allergiesLabel] || [sectionTitle isEqual: medicationsLabel]) {
        cell = [self cellForAllergyAndMedSectionsOfTableView:tv atIndexPath:indexPath];
    }
    else if ([sectionTitle isEqual: pharmaciesLabel]) {
        cell = [self cellForPharmacySectionOfTableView:tv atRow:indexPath.row];
    }
    else if ([sectionTitle isEqual: visitHistoryLabel]) {
        cell = [self cellForVisitSectionOfTableView:tv atRow:indexPath.row];
    }
    else { 
        cell = [self cellForPersonalInfoSectionOfTableView:tv atIndexPath:indexPath];
    }
    
    // Tag the selected cell's ContentView with the section number.
    cell.contentView.tag = indexPath.section;
    
    return cell;
}
                
-(UITableViewCell *) cellForPersonalInfoSectionOfTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"patientTextCell";
    static NSString *editableCellIdentifier = @"editablePatientTextCell";
    UITableViewCell *cell;
    NSString *description = nil;
    NSString *text = nil;
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex: indexPath.section];
    BOOL isBirthdayCell = [[self indexPathOfBirthdayCell] isEqual: indexPath];
    BOOL isPhoneCell = [[self indexPathOfPhoneCell] isEqual: indexPath];
    BOOL isEmailCell = [[self indexPathOfEmailCell] isEqual: indexPath];
    BOOL isZipCell = [[self indexPathOfZipCell] isEqual: indexPath];
    //BOOL isStateCell = [[self indexPathOfStateCell] isEqual: indexPath];
    BOOL isCellEditable = (isEditEnabled && !isBirthdayCell);
    UITableViewCellStyle immutableCellStyle = UITableViewCellStyleValue1;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    UIKeyboardType keyboardType = UIKeyboardTypeDefault;
    UIReturnKeyType returnType = UIReturnKeyNext;
    UITextAutocapitalizationType capsType = UITextAutocapitalizationTypeWords;
    
    // Keys and values are held in a nested Dictionary. Section key is in an array of strings.
    // Section value is in an array of value selectors.
    NSArray *sectionKeys = [[sectionedData objectForKey: sectionTitle] objectForKey: kDataGroupKeys];
    NSArray *sectionValues = [[sectionedData objectForKey: sectionTitle] objectForKey: kDataGroupValues];
    description = [sectionKeys objectAtIndex: indexPath.row];
    // Convert the stored NSValue into a Selector and then that into a value.
    NSValue *value = [sectionValues objectAtIndex: indexPath.row];
    SEL selector = [value pointerValue];
    text = [self performSelector:selector];
    
    // Set a special keyboard type for certain fields.
    if (isPhoneCell) {
        //keyboardType = UIKeyboardTypePhonePad;
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
    
    if (!isCellEditable) {
        // For immutable cells, or cells with a non-text editor.
        cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                         withIdentifier: cellIdentifier
                                                                withTag: indexPath.row
                                                      withAccessoryType: accessoryType
                                                          withCellStyle: immutableCellStyle
                                                             firstLabel: description 
                                                            secondLabel: text];
        // Allow birthday cell to be selected while the DatePicker is visible for editing.
        if (isEditEnabled && isBirthdayCell) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
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
    
    return cell;
}

-(UITableViewCell *) cellForAllergyAndMedSectionsOfTableView: (UITableView *)tv atIndexPath: (NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"patientTextCell";
    static NSString *editableCellIdentifier = @"editablePatientTextCell";
    UITableViewCell *cell;
    NSString *description = nil;
    NSString *text = nil;
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex: indexPath.section];
    
    // For medications or allergies, section value is a selector that retrieves an array of string values.
    NSValue *value = [sectionedData objectForKey: sectionTitle];
    NSArray *section = [self performSelector: [value pointerValue]];
    BOOL isAddCellPlaceholder = (isEditEnabled && indexPath.row == [section count] - 1);
    
    description = [section objectAtIndex: indexPath.row];
    text = description;
    
    // Set cell style depending on the role of the cell.
    if (isAddCellPlaceholder) {
        // A special case for the row that invites user to add item.
        cell = [TableCellFactory createAdditionPlaceHolderCellForTable: tv 
                                                        withIdentifier: cellIdentifier
                                                            firstLabel: description];
    }
    else if (isEditEnabled) {
        // The editable case.
        cell = [TableCellFactory createEditableTextCellForTable: tv 
                                                 withIdentifier: editableCellIdentifier 
                                                   withDelegate: self
                                               withKeyboardType: UIKeyboardTypeDefault
                                              withReturnKeyType: UIReturnKeyDone
                                         withCapitalizationType: UITextAutocapitalizationTypeWords
                                                        withTag: indexPath.row
                                                     withIndent: 10
                                                     firstLabel: description 
                                                    secondLabel: text];
    }
    else {
        // The static case.
        cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                         withIdentifier: cellIdentifier
                                                                withTag: indexPath.row
                                                      withAccessoryType: UITableViewCellAccessoryNone
                                                          withCellStyle: UITableViewCellStyleDefault
                                                             firstLabel: description 
                                                            secondLabel: text];
    }
    
    return cell;
}

-(UITableViewCell *) cellForVisitSectionOfTableView: (UITableView *)tv atRow: (NSInteger)row {
    static NSString *cellIdentifier = @"visitTextCell";
    UITableViewCell *cell = nil;
    NSString *description = nil;
    NSString *text = nil;
    UITableViewCellAccessoryType accessoryType = (self.canSelectVisits ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    // When cell holds visit history, section value is a selector that retrieves an array of objects.
    NSValue *value = [sectionedData objectForKey: visitHistoryLabel];
    // Here, section is an array of either Visit or Pharmacy objects.
    NSArray *section = [self performSelector: [value pointerValue]];
    
    Visit *v = (Visit *)[section objectAtIndex: row];
    // Description is Visit number.
    NSInteger index = row + 1;
    // Use the sort order setting.
    if ([ApplicationSupervisor instance].dateSortOrderSetting == NSOrderedDescending) {
        // If descending dates, reverse the count.
        index = [self.priorVisits count] - row;
    }
    description = [NSString stringWithFormat:@"%i. ", index];
    // Text is Visit dateTime
    text = [v getCreationDateTimeAsString];
    
    cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                     withIdentifier: cellIdentifier
                                                            withTag: row
                                                  withAccessoryType: accessoryType
                                                      withCellStyle: UITableViewCellStyleValue1
                                                         firstLabel: description 
                                                        secondLabel: text];
        
    return cell;
}

-(UITableViewCell *) cellForPharmacySectionOfTableView: (UITableView *)tv atRow: (NSInteger)row {
    static NSString *cellIdentifier = @"pharmacyCell";
    UITableViewCell *cell;
    NSString *description = nil;
    NSString *text = nil;
    BOOL isDefaultPharmacy = NO;
    UITableViewCellStyle immutableCellStyle = UITableViewCellStyleSubtitle;//UITableViewCellStyleValue1;
    
    NSValue *value = [sectionedData objectForKey: pharmaciesLabel];
    // Here, section is an array of Pharmacy objects.
    NSArray *section = [self performSelector: [value pointerValue]];
    BOOL isAddCellPlaceholder = (isEditEnabled && row == [section count] - 1);
    
    // Set cell style depending on the role of the cell.
    if (isAddCellPlaceholder) {
        description = [section objectAtIndex: row];
        // A special case for the row that invites user to add item.
        cell = [TableCellFactory createAdditionPlaceHolderCellForTable: tv 
                                                        withIdentifier: @"addPlaceholderCell"
                                                            firstLabel: description];
    }
    else {
        Pharmacy *pharm = (Pharmacy *)[section objectAtIndex: row];
        if (pharm && [pharm isKindOfClass:[Pharmacy class]]) {
            // Description is pharmacy name.
            description = pharm.name;
            // Text is simple contact description.
            text = [pharm.contactInfo simplifiedDescription];
            
            if ([patient.pharmacies count] == 1 || patient.defaultPharmacy == pharm) {
                isDefaultPharmacy = YES;
            }
        }
        
        if (!isEditEnabled && isDefaultPharmacy) {
            // A special case for the patient's default pharmacy.
            cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                             withIdentifier: @"defaultPharmacyCell"
                                                                    withTag: row
                                                          withAccessoryType: UITableViewCellAccessoryDisclosureIndicator
                                                              withCellStyle: immutableCellStyle
                                                          withImageFilePath: [[NSBundle mainBundle] pathForResource:rsrcBlueCheckmarkImage ofType:@"png"]
                                                                 firstLabel: description 
                                                                secondLabel: text];
        }
        else {
            // The normal case.
            cell = [TableCellFactory createImmutableDoubleLabelCellForTable: tv 
                                                             withIdentifier: cellIdentifier
                                                                    withTag: row
                                                          withAccessoryType: UITableViewCellAccessoryDisclosureIndicator
                                                              withCellStyle: immutableCellStyle
                                                                 firstLabel: description 
                                                                secondLabel: text];
            
        }
        // Setup a long-press gesture handler.
        if (longPressHandler) {
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:longPressHandler action:@selector(handleLongPress:)];
            [cell addGestureRecognizer:longPressRecognizer];        
            [longPressRecognizer release];
        }
        else {
            NSArray *recognizers = [cell gestureRecognizers];
            for (UIGestureRecognizer *recognizer in recognizers) {
                [cell removeGestureRecognizer:recognizer];
            }
        }
    }
    
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
    id section = [sectionedData objectForKey: [orderedSectionTitles objectAtIndex: sectionIndex]];
    if (section == nil) {
        return 0;
    }
    
    if ([section isKindOfClass:[NSValue class]]) {
        section = [self performSelector: [section pointerValue]];
    }
    if ([section isKindOfClass: [NSDictionary class]]) {
        return [[(NSDictionary *)section objectForKey: kDataGroupKeys] count];
    }
    else {
        return [(NSArray *)section count];
    }
}

/// titleForHeaderInSection
///
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    return [orderedSectionTitles objectAtIndex: sectionIndex];
}

/// numberOfSectionsInTableView
///
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tv {
    return [orderedSectionTitles count];
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
    // The Cell's ContentView has the textField's section number.
    NSInteger sectionTag = textField.superview.tag;
    NSInteger textFieldTag = textField.tag;
    // Only the first two sections give possibility of 'Next' button.
    if (sectionTag > 1 || (sectionTag == lastNextSectionIndex && textFieldTag == lastNextRowIndex)) {
        // The user pressed done button, so dismiss the keyboard.
        [textField resignFirstResponder];
        if (textField == self.fieldBeingEdited) {
            self.fieldBeingEdited = nil;
        }
        return YES;
    }
    else {
        NSIndexPath *dobPath = [self indexPathOfBirthdayCell];
        // the user pressed the "Next" button, so select the next row.
        // If at the last field in a section or next field would be the DateOfBirth field, skip to next section.
        if (textFieldTag + 1 > [self tableView: tableView numberOfRowsInSection: sectionTag]
            || (sectionTag == dobPath.section && textFieldTag + 1 == dobPath.row)) {
            // First field in next section.
            sectionTag++;
            textFieldTag = 0;
        }
        else {
            // Next field in same section.
            textFieldTag++;
        }
        [self selectTextFieldAtIndex: [NSIndexPath indexPathForRow: textFieldTag inSection: sectionTag]];
        return NO;
    }
}

/// textFieldDidBeginEditing
///
-(void) textFieldDidBeginEditing: (UITextField *)textField {
    self.isEditing = YES;
    self.fieldBeingEdited = textField;
    NSInteger section = textField.superview.tag;
    NSInteger row = textField.tag;
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex: section];
    
    if (row < [self.allergies count] && [allergiesLabel isEqualToString: sectionTitle]) {
        // If an EXISTING allergy is being edited, remove it and add it back when edit is complete.
        [self.allergies removeObjectAtIndex: row];
    }
    else if (row < [self.medications count] && [medicationsLabel isEqualToString: sectionTitle]) {
        // If an EXISTING medication is being edited, remove it and add it back when edit is complete.
        [self.medications removeObjectAtIndex: row];
    }
}

/// textFieldDidEndEditing
///
/// Handles when a TextField is done being edited.  The new text value is entered into the data source
/// at the appropriate location.
-(void) textFieldDidEndEditing: (UITextField *)textField {
    self.isEditing = NO;
    
    NSString *newText = textField.text;
    // Obtain the section number from the Cell view's tag and the row from the TextField's tag.
    NSInteger section = textField.superview.tag;
    NSInteger row = textField.tag;
    NSString *sectionTitle = [orderedSectionTitles objectAtIndex: section];
    
    // Section index determines how the properties are accessed.
    if (section < [groupedPropertyNames count]) {
        NSString *property = [[groupedPropertyNames objectAtIndex: section] objectAtIndex: row];
        [self setValue: newText forKey: property];
    }
    else if ([allergiesLabel isEqualToString: sectionTitle]) {
        // The old allergy was already removed by textFieldDidBeginEditing, so just add the new value.
        [self.allergies insertObject: newText atIndex: row];
    }
    else if ([medicationsLabel isEqualToString: sectionTitle]) {
        // The old medication was already removed by textFieldDidBeginEditing, so just add the new value.
        [self.medications insertObject: newText atIndex: row];
    }

    self.fieldBeingEdited = nil;
}


#pragma mark Memory Management

-(void) dealloc {
    [self subscribeToAppNotifications: NO];
    // This unsubscribes to patient property changes.
    self.patient = nil;
    self.fieldBeingEdited = nil;
    self.allergies = nil;
    self.pharmacies = nil;
    self.priorVisits = nil;
    self.medications = nil;
    self.sectionedData = nil;
    self.orderedSectionTitles = nil;
    self.longPressHandler = nil;
    [changedProperties release];
    [groupedPropertyNames release];
    [lastAddedIndexPath release];
    [super dealloc];
}


#pragma mark Event Handling

///
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Patient *p = (Patient *)object;
    if (p != self.patient) {
        return;
    }
    
    NSNumber * kind = (NSNumber *)[change valueForKey:NSKeyValueChangeKindKey];
    NSIndexSet *indexes = [change valueForKey:NSKeyValueChangeIndexesKey];
    
    if ([keyPath isEqualToString:dateOfBirthKey]) {
        self.dateOfBirth = [p getBirthdayAsString];
    }
    else if ([keyPath isEqualToString:@"contactInfo.address"]) {
        self.address = p.contactInfo.address;
    }
    else if ([keyPath isEqualToString:@"contactInfo.city"]) {
        self.city = p.contactInfo.city;
    }
    else if ([keyPath isEqualToString:@"contactInfo.state"]) {
        self.state = p.contactInfo.state;
    }
    else if ([keyPath isEqualToString:@"contactInfo.zip"]) {
        self.zip = [p.contactInfo getZipAsString];
    }
    else if ([keyPath isEqualToString:@"contactInfo.phone"]) {
        self.phone = p.contactInfo.phone;
    }
    else if ([keyPath isEqualToString:@"contactInfo.email"]) {
        self.email = p.contactInfo.email;
    }
    else if ([keyPath isEqualToString:allergiesKey]) {
        NSUInteger index = [indexes firstIndex];
        switch ([kind intValue]) {
            case NSKeyValueChangeInsertion:
                while (index != NSNotFound) {
                    if (![self.allergies containsObject:[patient.allergies objectAtIndex:index]]) {
                        [self.allergies insertObject:[patient.allergies objectAtIndex:index] atIndex:index];
                        
                        NSInteger section;
                        // Having trouble reloading only a single section when it's new, so split it out.
                        if ([self.allergies count] == 1) {
                            // Refresh the section headings immediately so that the new section index becomes available.
                            [self refreshSectionHeadings];
                        }
                        section = [self sectionNumberForSectionTitle:allergiesLabel];
                        [self postInsertRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
                        
                        //self.isReloadNeeded = YES;
                        
                    }
                    index = [indexes indexGreaterThanIndex: index];
                }
                // Update for new section.
                if ([self.allergies count] == 1) {
                    [self refreshSectionHeadings];
                }
                break;
                
            case NSKeyValueChangeRemoval:
                while (index != NSNotFound) {
                    [self.allergies removeObjectAtIndex: index];
                    [self postRemoveRow];
                    //self.isReloadNeeded = YES;
                    index = [indexes indexGreaterThanIndex: index];
                }
                // update for empty section.
                if ([self.allergies count] == 0) {
                    [self refreshSectionHeadings];
                }
                break;
                
//            case NSKeyValueChangeReplacement:
//                NSLog(@"Received notification of Replacement for allergies");
//                [self.allergies removeAllObjects];
//                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:medicationsKey]) {
        NSUInteger index = [indexes firstIndex];
        switch ([kind intValue]) {
            case NSKeyValueChangeInsertion:
                while (index != NSNotFound) {
                    if (![self.medications containsObject:[patient.medications objectAtIndex:index]]) {
                        [self.medications insertObject:[patient.medications objectAtIndex:index] atIndex:index];
                        
                        NSInteger section;
                        // Having trouble reloading only a single section when it's new, so split it out.
                        if ([self.medications count] == 1) {
                            // Refresh the section headings immediately so that the new section index becomes available.
                            [self refreshSectionHeadings];
                        }
                        section = [self sectionNumberForSectionTitle:medicationsLabel];
                        [self postInsertRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
                        
                        //self.isReloadNeeded = YES;
                    }
                    index = [indexes indexGreaterThanIndex: index];
                }
                // Update for new section.
                if ([self.medications count] == 1) {
                    [self refreshSectionHeadings];
                }
                break;
                
            case NSKeyValueChangeRemoval:
                while (index != NSNotFound) {
                    [self.medications removeObjectAtIndex: index];
                    [self postRemoveRow];
                    //self.isReloadNeeded = YES;
                    index = [indexes indexGreaterThanIndex: index];
                }
                // Update for empty section.
                if ([self.medications count] == 0) {
                    [self refreshSectionHeadings];
                }
                break;
                
            default:
                break;
        }
        [self refreshSectionHeadings];
    }
    else if ([keyPath isEqualToString:pharmaciesKey]) {
        NSUInteger index = [indexes firstIndex];
        switch ([kind intValue]) {
            case NSKeyValueChangeInsertion:
                // Addition here is different then Allergies & Medications sections, since it is caused by another view.
                while (index != NSNotFound) {
                    Pharmacy *pharm = [patient.pharmacies objectAtIndex:index];
                    // Add to the supporting data structure first.
                    [self.pharmacies insertObject:pharm atIndex:index];
                    
                    NSInteger section;
                    // Having trouble reloading only a single section when it's new, so split it out.
                    if ([self.pharmacies count] == 1) {
                        // Refresh the section headings immediately so that the new section index becomes available.
                        [self refreshSectionHeadings];
                        section = [self sectionNumberForSectionTitle:pharmaciesLabel];
                        // Set the flag so that the reload doesn't fail.
                        isReloadNeeded = YES;
                        [self reloadTableData];
                    }
                    else {
                        section = [self sectionNumberForSectionTitle:pharmaciesLabel];
                        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:NO];
                    }
                    [self postInsertRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
                    index = [indexes indexGreaterThanIndex: index];
                }
                break;
                
            case NSKeyValueChangeRemoval:
                while (index != NSNotFound) {
                    [self.pharmacies removeObjectAtIndex: index];
                    [self postRemoveRow];
                    index = [indexes indexGreaterThanIndex: index];
                }
                // Update for removed section.
                if ([self.pharmacies count] == 0) {
                    [self refreshSectionHeadings];
                }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:priorVisitsKey]) {
        NSUInteger index = [indexes firstIndex];
        switch ([kind intValue]) {
            case NSKeyValueChangeInsertion:
                // Addition here is different then Allergies & Medications sections, since it is caused by another view.
                while (index != NSNotFound) {
                    Visit *v = [patient.priorVisits objectAtIndex:index];
                    // Add to the supporting data structure first.
                    // I assume that it's less expensive to just add one item and re-sort than to do my own sort-insert,
                    // because the array is already mostly sorted.
                    [self.priorVisits addObject: v];
                    [self sortPriorVisitsByDate];
                    
                    // Refresh the data, either by section or wholely.
                    NSInteger section;
                    // Having trouble reloading only a single section when it's new, so split it out.
                    if ([self.priorVisits count] == 1) {
                        // Refresh the section headings immediately so that the new section index becomes available.
                        [self refreshSectionHeadings];
                        section = [self sectionNumberForSectionTitle:visitHistoryLabel];
                        // sortPriorVisitsByDate has set the required flag.
                        [self reloadTableData];
                    }
                    else {
                        section = [self sectionNumberForSectionTitle:visitHistoryLabel];
                        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:NO];
                    }
                    [self postInsertRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
                    index = [indexes indexGreaterThanIndex: index];
                }
                break;
                
            case NSKeyValueChangeRemoval:
                while (index != NSNotFound) {
                    [self.priorVisits removeObjectAtIndex: index];
                    [self postRemoveRow];
                    index = [indexes indexGreaterThanIndex: index];
                }
                // Update for removed section.
                if ([self.priorVisits count] == 0) {
                    [self refreshSectionHeadings];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        [self setValue:[p valueForKey:keyPath] forKey:keyPath];
    }
}

-(void) handleVisitUpdated: (NSNotification *)notification {
    // For now, only respond to App-wide event if this DataSource is immutable.
    if (!isEditEnabled) {
        // Only add it back in if it was found here in the first place.
        if ([self.priorVisits containsObject: [notification object]]) {
            [self sortPriorVisitsByDate];
            [self reloadTableData];
        }
    }
}

-(void) handlePharmacyUpdated: (NSNotification *)notification {
    // Pharmacy editing view is only a child of immutable PharmacyViews.
    if (!isEditEnabled) {
        if ([self.pharmacies containsObject: [notification object]]) {
            isReloadNeeded = YES;
            [self reloadTableData];
        }
    }
}
                        
-(void) handleDateSortSettingChanged: (NSNotification *)notification {
    [self sortPriorVisitsByDate];
    [self reloadTableData];
}

///
-(void) subscribeToPatientPropertyChanges: (BOOL)yesNo {
    // Only respond to property change notifications if this DataSource is not being edited directly.
    if (yesNo && !isObservingPatient) {
        isObservingPatient = YES;
        [patient addPropertyChangeObserver:self];
    }
    else if (!yesNo && isObservingPatient) {
        isObservingPatient = NO;
        @try {
            [patient removePropertyChangeObserver:self];
        }
        @catch (NSException *ex) {
            // Nothing.
        }
    }
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addDateSortSettingChangedObserver: self withHandler: @selector(handleDateSortSettingChanged:)];
        [[ApplicationSupervisor instance] addVisitUpdatedObserver: self withHandler: @selector(handleVisitUpdated:)];
        [[ApplicationSupervisor instance] addPharmacyUpdatedObserver: self withHandler: @selector(handlePharmacyUpdated:)];
    }
    else {
        [[ApplicationSupervisor instance] removeDateSortSettingChangedObserver: self];
        [[ApplicationSupervisor instance] removeVisitUpdatedObserver: self];
        [[ApplicationSupervisor instance] removePharmacyUpdatedObserver: self];
    }
}

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath: isReloadNeededKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath: fieldBeingEditedKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath: isEditingKey options:NSKeyValueObservingOptionNew context:nil];
    //[self addObserver:observer forKeyPath: @"initExtraRowCount" options:NSKeyValueObservingOptionNew context:nil];
}
/// Add an observer for notifications about new table rows being inserted.
-(void) addTableRowInsertedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // added with object=self filter works here because the notification is sent with self as the object.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kTableRowInsertedNotification object:self];
}
-(void) addTableRowRemovedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // added with object=self filter works here because the notification is sent with self as the object.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kTableRowRemovedNotification object:self];
}
-(void) addShowPharmacyViewRequestObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    // The object filter has to be empty here because a pharmacy is sent as the notification object.
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kShowPharmacyViewNotification object:nil];
} 

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath: isReloadNeededKey];
        [self removeObserver:observer forKeyPath: fieldBeingEditedKey];
        [self removeObserver:observer forKeyPath: isEditingKey];
        //[self removeObserver:observer forKeyPath:@"initExtraRowCount"];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}       
-(void) removeTableRowInsertedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kTableRowInsertedNotification object:self];
}
-(void) removeTableRowRemovedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kTableRowRemovedNotification object:self];
}
-(void) removeShowPharmacyViewRequestObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kShowPharmacyViewNotification object:nil];
}

-(void) stopObservingPatientNotifications {
    [self subscribeToPatientPropertyChanges: NO];
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
