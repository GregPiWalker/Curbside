//
//  PatientsByNameDataSource.m
//  CurbSide
//
//  Created by Greg Walker on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatientsByNameDataSource.h"
#import "Constants.h"


@interface PatientsByNameDataSource ()

-(void) subscribeToAppNotifications: (BOOL)yesNo;

-(void) handleNameSortChanged: (NSNotification *)n;

-(void) handlePatientCellWillUpdate: (NSNotification *)notification;

-(void) presortSections;

-(NSMutableArray *) alphabetizeSection: (NSArray *)sectionData;

-(BOOL) tryInsertPatient: (Patient *)p withIndex: (NSString *)i byFirstName: (BOOL)byFirstName;

-(BOOL) tryRemovePatient: (Patient *)p withIndex: (NSString *)i byFirstName: (BOOL)byFirstName;

-(void) applySearchFilter;

-(BOOL) doesSearchPhraseMatchPatient: (Patient *)p;

//-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

@end


@implementation PatientsByNameDataSource


#pragma mark - Properties

@synthesize dataSortedOnFirstName;
@synthesize dataSortedOnLastName;
@synthesize sectionTitlesByFirstName;
@synthesize sectionTitlesByLastName;
@synthesize filteredData;
@synthesize searchPhrase;
-(void) setSearchPhrase: (NSString *)value {
    if (value && [searchPhrase isEqualToString: value]) {
        return;
    }
    [searchPhrase autorelease];
    searchPhrase = [value retain];
    
    //Set the filter data and reload the tableview.
    if (searchPhrase && [searchPhrase length] > 0) {
        [self applySearchFilter];
    }
    else {
        self.filteredData = nil;
    }
    [tableView reloadData];
}

@synthesize tableView;
-(void) setTableView: (UITableView *)tv {
    if (tv == tableView) {
        return;
    }
    [tableView autorelease];
    tableView = [tv retain];
    if (tableView != nil) {
        tableView.dataSource = self;
    }
}

@synthesize sortByLastName;
// Override sortByLastName setter to handle sorting.
-(void) setSortByLastName: (BOOL)b {
    if (sortByLastName != b) {
        sortByLastName =  b;
        // Re-sort
        [self presortSections];
    }
}


#pragma mark - Methods

-(id) init {
    self = [super init];
    if (self) {
        self.dataSortedOnFirstName = [NSMutableDictionary dictionary];
        self.dataSortedOnLastName = [NSMutableDictionary dictionary];
        self.sectionTitlesByFirstName = [NSMutableArray array];
        self.sectionTitlesByLastName = [NSMutableArray array];
        // Set the name sorting order based on the user-defined setting.
        switch ([ApplicationSupervisor instance].nameSortOrderSetting) {
            case ORDER_BY_LAST_NAME:
                sortByLastName = YES;
                break;
            case ORDER_BY_FIRST_NAME:
                sortByLastName = NO;
                break;
            default:
                sortByLastName = NO;
                break;
        }
        
        NSArray *patients = [ApplicationSupervisor instance].patients;
        for (Patient *p in patients) {
            [self addPatient:p];
        }
        // Patients were not necessarily added in sorted order.
        [self presortSections];
        
        [self subscribeToAppNotifications:YES];
    }
    return self;
}

-(NSArray *) getSectionReadonlyForFirstNameKey: (NSString *)key {
    if (searchPhrase && [searchPhrase length] > 0) {
        return [NSArray arrayWithArray:[self.filteredData objectForKey:[key capitalizedString]]];
    }
    else {
        return [NSArray arrayWithArray:[self.dataSortedOnFirstName objectForKey:[key capitalizedString]]];
    }
}

/// Gets the last name section data as a readonly array.  If a search phrase is active, the result is filtered accordingly.
-(NSArray *) getSectionReadonlyForLastNameKey: (NSString *)key {
    if (searchPhrase && [searchPhrase length] > 0) {
        return [NSArray arrayWithArray:[self.filteredData objectForKey:[key capitalizedString]]];
    }
    else {
        return [NSArray arrayWithArray:[self.dataSortedOnLastName objectForKey:[key capitalizedString]]];
    }
}

-(NSArray *) getFilteredSectionTitles {
    if (!searchPhrase || [searchPhrase length] == 0) {
        return [NSArray array];
    }
    
    // Return the sorted keys of the filtered collection.
    return [[self.filteredData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];;
}

-(void) applySearchFilter {
    if (searchPhrase && [searchPhrase length] > 0) {
        self.filteredData = [NSMutableDictionary dictionary];
        NSDictionary *searchData;
        if (sortByLastName) {
            searchData = self.dataSortedOnLastName;
        }
        else {
            searchData = self.dataSortedOnFirstName;
        }
        
        for (NSString *key in [searchData allKeys]) {
            // Complicated predicate that only returns Patient's whose names match the search terms.
            NSArray *values = [[searchData objectForKey: key] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:
                ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    Patient *p = (Patient *)evaluatedObject;
                    return [self doesSearchPhraseMatchPatient: p];
                }]];
            
            if (values && [values count] > 0) {
                [self.filteredData setObject:values forKey:key];
            }
        }
    }
}

-(BOOL) doesSearchPhraseMatchPatient: (Patient *)p {
    if (!searchPhrase || [searchPhrase length] == 0) {
        return YES;
    }
    
    NSMutableArray *referenceValues = [NSMutableArray arrayWithArray:[p.fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    // Get rid of null strings.
    [referenceValues filterUsingPredicate: [NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    NSMutableArray *searchComponents = [NSMutableArray arrayWithArray:[self.searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    // Get rid of null strings.
    [searchComponents filterUsingPredicate: [NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    
    for (int i = [searchComponents count] - 1; i >= 0; i--) {
        NSString *searchTerm = [searchComponents objectAtIndex:i];
        // Search every term and make sure each one appears somewhere in the Patient's full name.
        for (NSString *nameTerm in referenceValues) {
            // THIS NEXT LINE MAKES A SEARCH MATCH USING CONTAINMENT RATHER THAN STARTS-WITH.
            //if ([nameTerm containsCaseInsensitiveString:[searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
            if ([nameTerm hasPrefix: [searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] options: NSCaseInsensitiveSearch]) {
                [searchComponents removeObjectAtIndex:i];
                break;
            }
        }
    }
    // Return TRUE only if all search terms were present somewhere in the patient's full name.
    return [searchComponents count] == 0;
}

/**
 */
-(void) addPatient: (Patient *)newPatient {
    NSString *firstStartLetter = @"";
    if ([newPatient.firstName length] > 0) {
        firstStartLetter = [[newPatient.firstName substringToIndex:1] uppercaseString];
    }
    NSString *lastStartLetter = @"";
    if ([newPatient.lastName length] > 0) {
        lastStartLetter = [[newPatient.lastName substringToIndex:1] uppercaseString];
    }
    BOOL firstAdded = [self tryInsertPatient:newPatient withIndex:firstStartLetter byFirstName: YES];
    BOOL lastAdded = [self tryInsertPatient:newPatient withIndex:lastStartLetter byFirstName: NO];
    
    // Add to first name dictionary.
    if (!firstAdded) {
        // There is no first name, so must use last name.
        firstAdded = [self tryInsertPatient:newPatient withIndex:lastStartLetter byFirstName: YES];
    }
    
    // Then add to last name dictionary.
    if (!lastAdded) {
        //There is no last name, so must use first name.
        lastAdded = [self tryInsertPatient:newPatient withIndex:firstStartLetter byFirstName: NO];
    }
    
    //TODO: really, it should add to both cases or neither.  Just one indicates a logic failure.
    
    if (firstAdded || lastAdded) {
        // Need to rebuild the filtered data if there is an active search phrase.
        if (searchPhrase && [searchPhrase length] > 0) {
            [self applySearchFilter];
        }
        // Finally, reload the table data.
        [tableView reloadData];
    }
}

/**
 */
-(void) updatePatient: (Patient *)patient fromOldFirstName: (NSString *)oldFirst andLastName: (NSString *)oldLast {
    NSString *oldFirstStartLetter = @"";
    if ([oldFirst length] > 0) {
        oldFirstStartLetter = [[oldFirst substringToIndex:1] uppercaseString];
    }
    NSString *oldLastStartLetter = @"";
    if ([oldLast length] > 0) {
        oldLastStartLetter = [[oldLast substringToIndex:1] uppercaseString];
    }
    BOOL firstRemoved = NO;
    BOOL lastRemoved = NO;
    
    // If the first name was changed, try to remove patient from being referenced by old name, 
    // whether in the data sorted by first or last name..
    if ([oldFirst caseInsensitiveCompare:patient.firstName] != NSOrderedSame) {
        firstRemoved = [self tryRemovePatient:patient withIndex:oldFirstStartLetter byFirstName: YES];
        if (!firstRemoved) {
            firstRemoved = [self tryRemovePatient:patient withIndex:oldFirstStartLetter byFirstName: NO];
        }
    }
    // If the last name was changed, try to remove patient from being referenced by old name,
    // whether in the data sorted by last or first name.
    if ([oldLast caseInsensitiveCompare:patient.lastName] != NSOrderedSame) {
        lastRemoved = [self tryRemovePatient:patient withIndex:oldLastStartLetter byFirstName: NO];
        if (!lastRemoved) {
            lastRemoved = [self tryRemovePatient:patient withIndex:oldLastStartLetter byFirstName: YES];
        }
    }
    
    //TODO: really, it should remove from both cases or neither.  Just one indicates a logic failure.
    
    if (firstRemoved || lastRemoved) {
        // Add the patient back in, which will re-sort it's position.
        [self addPatient:patient];
        
        // Need to rebuild the filtered data if there is an active search phrase.
        if (searchPhrase && [searchPhrase length] > 0) {
            [self applySearchFilter];
        }
        // Finally, reload the table data.
        [tableView reloadData];
    }
}

/**
 */
-(void) removePatient: (Patient *)obsoletePatient {
    NSString *firstStartLetter = @"";
    if ([obsoletePatient.firstName length] > 0) {
        firstStartLetter = [[obsoletePatient.firstName substringToIndex:1] uppercaseString];
    }
    NSString *lastStartLetter = @"";
    if ([obsoletePatient.lastName length] > 0) {
        lastStartLetter = [[obsoletePatient.lastName substringToIndex:1] uppercaseString];
    }
    BOOL firstRemoved = [self tryRemovePatient:obsoletePatient withIndex:firstStartLetter byFirstName: YES];
    BOOL lastRemoved = [self tryRemovePatient:obsoletePatient withIndex:lastStartLetter byFirstName: NO];
    
    // First remove patient from the first name dictionary.
    if (!firstRemoved) {
        // There is no first name, so must use last name.
        firstRemoved = [self tryRemovePatient:obsoletePatient withIndex:lastStartLetter byFirstName: YES];
    }
    
    // Then remove patient from the first name dictionary.
    if (!lastRemoved) {
        //There is no last name, so must use first name.
        lastRemoved = [self tryRemovePatient:obsoletePatient withIndex:firstStartLetter byFirstName: NO];
    }
    
    //TODO: really, it should remove from both cases.  Just one indicates a logic failure.
    
    if (firstRemoved || lastRemoved) {
        // Need to rebuild the filtered data if there is an active search phrase.
        if (searchPhrase && [searchPhrase length] > 0) {
            [self applySearchFilter];
        }
        // Finally, reload the table data.
        [tableView reloadData];
    }
}

/// getPatientForPath
///
/// Tries to get the Patient from a the filtered set.  Otherwise, falls back on unfiltered data.
-(Patient *) getPatientForPath: (NSIndexPath *)path {
    Patient * p;
    NSArray *section;
    
    if (self.searchPhrase && [searchPhrase length] > 0) {
        section = [self.filteredData objectForKey: [[self getFilteredSectionTitles] objectAtIndex: path.section]];
    }
    else if (sortByLastName) {
        section = [self.dataSortedOnLastName objectForKey: [self.sectionTitlesByLastName objectAtIndex: path.section]];
    }
    else {
        section = [self.dataSortedOnFirstName objectForKey: [self.sectionTitlesByFirstName objectAtIndex: path.section]];
    }
    p = [section objectAtIndex: path.row];
    
    return p;
}

/// indexPathForPatient
///
/// Tries to find the index path for the given patient using a filtered data set.
-(NSIndexPath *) indexPathForPatient: (Patient *)p {
    NSString *firstStartLetter = @"";
    if ([p.firstName length] > 0) {
        firstStartLetter = [[p.firstName substringToIndex:1] uppercaseString];
    }
    NSString *lastStartLetter = @"";
    if ([p.lastName length] > 0) {
        lastStartLetter = [[p.lastName substringToIndex:1] uppercaseString];
    }
    NSInteger section = NSNotFound;
    NSInteger row = NSNotFound;
    
    if (self.searchPhrase && [searchPhrase length] > 0) {
        NSArray *sectionData = [self.filteredData objectForKey:lastStartLetter];
        if ([sectionData containsObject:p]) {
            section = [[self getFilteredSectionTitles] indexOfObject:lastStartLetter];
            row = [sectionData indexOfObject:p];
        }
        else {
            // Wasn't held by last name, try first.
            sectionData = [self.filteredData objectForKey: firstStartLetter];
            if ([sectionData containsObject:p]) {
                section = [[self getFilteredSectionTitles] indexOfObject:firstStartLetter];
                row = [sectionData indexOfObject:p];
            }
        }
    }
    else if (sortByLastName) {
        NSArray *sectionData = [self.dataSortedOnLastName objectForKey: lastStartLetter];
        if ([sectionData containsObject:p]) {
            section = [self.sectionTitlesByLastName indexOfObject:lastStartLetter];
            row = [sectionData indexOfObject:p];
        }
        else {
            // Wasn't held by last name, try first.
            sectionData = [self.dataSortedOnLastName objectForKey: firstStartLetter];
            if ([sectionData containsObject:p]) {
                section = [self.sectionTitlesByLastName indexOfObject:firstStartLetter];
                row = [sectionData indexOfObject:p];
            }
        }
    }
    else {
        NSArray *sectionData = [self.dataSortedOnFirstName objectForKey: firstStartLetter];
        if ([sectionData containsObject:p]) {
            section = [self.sectionTitlesByFirstName indexOfObject:firstStartLetter];
            row = [sectionData indexOfObject:p];
        }
        else {
            // Wasn't held by first name, try last.
            sectionData = [self.dataSortedOnFirstName objectForKey: lastStartLetter];
            if ([sectionData containsObject:p]) {
                section = [self.sectionTitlesByFirstName indexOfObject:lastStartLetter];
                row = [sectionData indexOfObject:p];
            }
        }
    }
    
    if (section != NSNotFound && row != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:section];
    }
    return nil;
}


#pragma mark UITableViewDataSource Methods

/**
 */
-(UITableViewCell *) tableView: (UITableView *)tv cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    PatientTableViewCell *cell = [TableCellFactory createSortablePatientCellForTable:tv withIdentifier:@"PatientListCell" withTag:indexPath.row];
    // set the patient for this cell as specified by the datasource.
    cell.patient = [self getPatientForPath: indexPath];
    cell.emphasisOnLastName = sortByLastName;
    
    return cell;
}

/**
 */
-(NSInteger) numberOfSectionsInTableView: (UITableView *)tv {
    if (self.searchPhrase && [searchPhrase length] > 0) {
        return [[self getFilteredSectionTitles] count];
    }
    else if (sortByLastName) {
        return [sectionTitlesByLastName count];
    }
    else {
        return [sectionTitlesByFirstName count];
    }
}

/**
 */
-(NSArray *) sectionIndexTitlesForTableView: (UITableView *)tv {
    if (self.searchPhrase && [searchPhrase length] > 0) {
        return [self getFilteredSectionTitles];
    }
    else if (sortByLastName) {
        return sectionTitlesByLastName;
    }
    else {
        return sectionTitlesByFirstName;
    }
}

/**
 */
-(NSInteger) tableView: (UITableView *)tv sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index {
    //TODO: this is wrong? fix it?
	return index;
}

/**
 */
-(NSInteger) tableView: (UITableView *)tv numberOfRowsInSection: (NSInteger)sectionIndex {
    NSArray *section;
    
    if (self.searchPhrase && [searchPhrase length] > 0) {
        NSString *firstLetter = [[self getFilteredSectionTitles] objectAtIndex: sectionIndex];
        section = [self.filteredData objectForKey: firstLetter];
    }
    else if (sortByLastName) {
        NSString *firstLetter = [sectionTitlesByLastName objectAtIndex: sectionIndex];
        section = [dataSortedOnLastName objectForKey: firstLetter];
    }
    else {
        NSString *firstLetter = [sectionTitlesByFirstName objectAtIndex: sectionIndex];
        section = [dataSortedOnFirstName objectForKey: firstLetter];
    }

    // return the count
    return [section count];
}

/**
 */
-(NSString *) tableView: (UITableView *)tv titleForHeaderInSection: (NSInteger)sectionIndex {
    if (self.searchPhrase && [searchPhrase length] > 0) {
        return [[self getFilteredSectionTitles] objectAtIndex: sectionIndex];
    }
    else if (sortByLastName) {
        return [sectionTitlesByLastName objectAtIndex: sectionIndex];
    }
    else {
        return [sectionTitlesByFirstName objectAtIndex: sectionIndex];
    }
}


#pragma mark Memory Management

-(void) dealloc {
    [self subscribeToAppNotifications:NO];
    self.dataSortedOnFirstName = nil;
    self.dataSortedOnLastName = nil;
    self.sectionTitlesByFirstName = nil;
    self.sectionTitlesByLastName = nil;
    self.searchPhrase = nil;
    self.filteredData = nil;
    self.tableView = nil;
    [super dealloc];
}


#pragma mark Private Methods

/**
 */
-(void) presortSections {
    if (sortByLastName) {
        for (NSString *sectionTitle in sectionTitlesByLastName) {
            NSArray *newSort = [self alphabetizeSection: [self.dataSortedOnLastName objectForKey: sectionTitle]];
            [self.dataSortedOnLastName setObject:newSort forKey:sectionTitle];
        }
    }
    else {
        for (NSString *sectionTitle in sectionTitlesByFirstName) {
            NSArray *newSort = [self alphabetizeSection: [self.dataSortedOnFirstName objectForKey: sectionTitle]];
            [self.dataSortedOnFirstName setObject:newSort forKey:sectionTitle];
        }
    }
}

/**
 Returns an alphabetized section of Patients on last name 1st and first name 2nd.
 */
-(NSMutableArray *) alphabetizeSection: (NSArray *)sectionArray {    
    return [NSMutableArray arrayWithArray: [sectionArray sortedArrayUsingSelector:@selector(compareByFullName:)]];
}

/**
 Try to insert a new patient in either the FirstName or LastName data using the given index character.
 */
-(BOOL) tryInsertPatient: (Patient *)p withIndex: (NSString *)i byFirstName: (BOOL)byFirstName {
    BOOL success = YES;
    if ([i length] > 0) {
        NSMutableArray *section;
        
        if (byFirstName) {
            section = [dataSortedOnFirstName valueForKey: i];
            
            if (section) {
                // Add the patient to the section data array.
                [section addObject: p];
                // Need to sort the contents in this section.
                [self.dataSortedOnFirstName setObject: [self alphabetizeSection: section] forKey: i];
            } 
            else {
                NSMutableArray *newData = [[NSMutableArray alloc] init];
                [newData addObject: p];
                [self.dataSortedOnFirstName setObject: newData forKey: i];
                // Need to rebuild and sort the indexable section titles.
                self.sectionTitlesByFirstName = [NSMutableArray arrayWithArray: [[dataSortedOnFirstName allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                [newData release];
            }
        }
        else {
            section = [dataSortedOnLastName valueForKey: i];
            
            if (section) {
                // Add the patient to the section data array.
                [section addObject: p];
                // Need to sort the contents in this section.
                [self.dataSortedOnLastName setObject: [self alphabetizeSection: section] forKey: i];
            } 
            else {
                NSMutableArray *newData = [[NSMutableArray alloc] init];
                [newData addObject: p];
                [self.dataSortedOnLastName setObject: newData forKey: i];
                // Need to rebuild and sort the indexable section titles.
                self.sectionTitlesByLastName = [NSMutableArray arrayWithArray: [[dataSortedOnLastName allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                [newData release];
            }     
        }
    }
    else {
        success = NO;
    }
    return success;
}

/**
 */
-(BOOL) tryRemovePatient: (Patient *)p withIndex: (NSString *)i byFirstName: (BOOL)byFirstName {
    BOOL success = YES;
    NSMutableArray *section;
    if (byFirstName) {
        section = [dataSortedOnFirstName valueForKey: i];
    }
    else {
        section = [dataSortedOnLastName valueForKey: i];
    }
    if (section) {
        // Remove the patient from the section data array.
        [section removeObject: p];
        // If removal leaves an empty section, remove it too.
        if ([section count] == 0) {
            if (byFirstName) {
                [self.dataSortedOnFirstName removeObjectForKey: i];
                [self.sectionTitlesByFirstName removeObject: i];
            }
            else {
                [self.dataSortedOnLastName removeObjectForKey: i];
                [self.sectionTitlesByLastName removeObject: i];
            }
        }
        section = nil;
    }
    else {
        success = NO;
    }
    return success;
}  


#pragma mark UISearchBarDelegate Methods

-(void) searchBarCancelButtonClicked: (UISearchBar *)sb {
    self.searchPhrase = nil;
}

-(void) searchBar: (UISearchBar *)sb textDidChange: (NSString *)searchText {
    self.searchPhrase = searchText;
}

-(void) searchBarSearchButtonClicked: (UISearchBar *)sb {
    // Just dismiss the keyboard;
    [sb resignFirstResponder];
}

#pragma mark Event Handling

-(void) addPropertyChangeObserver: (NSObject *)observer {
    [self addObserver:observer forKeyPath:sortByLastNamePropertyKey options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removePropertyChangeObserver: (NSObject *)observer {
    @try {
        [self removeObserver:observer forKeyPath:sortByLastNamePropertyKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Observation Exception: %@", exception);
    }
}

-(void) handlePatientCellWillUpdate: (NSNotification *)notification {
    if ([[notification object] isKindOfClass: [PatientTableViewCell class]]) {
        PatientTableViewCell *cell = (PatientTableViewCell *)[notification object];
        // Use the outdated first and last name held by the cell to update data collections with new patient name values.
        [self updatePatient:cell.patient fromOldFirstName:cell.firstNameText andLastName:cell.lastNameText];
    }
}

-(void) handleNameSortChanged: (NSNotification *)n {
    // Set the name sorting order based on the user-defined setting.
    switch ([ApplicationSupervisor instance].nameSortOrderSetting) {
        case ORDER_BY_LAST_NAME:
            self.sortByLastName = YES;
            break;
        case ORDER_BY_FIRST_NAME:
            self.sortByLastName = NO;
            break;
        default:
            self.sortByLastName = YES;
            break;
    }
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addTableViewCellWillUpdateObserver:self withHandler:@selector(handlePatientCellWillUpdate:) forNotificationName: kPatientTableCellTextWillUpdateNotification];
        [[ApplicationSupervisor instance] addNameSortSettingChangedObserver:self withHandler:@selector(handleNameSortChanged:)];
    }
    else {
        [[ApplicationSupervisor instance] removeTableViewCellWillUpdateObserver:self forNotificationName: kPatientTableCellTextWillUpdateNotification];
        [[ApplicationSupervisor instance] removeNameSortSettingChangedObserver:self];
    }
}

//-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
//    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
//}

@end
