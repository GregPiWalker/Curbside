//
//  ApplicationSupervisor.m
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ApplicationSupervisor.h"
#import "OrderedMutableDictionary.h"
#import "Constants.h"
#import "FileArchiveResult.h"
#import "Patient.h"
#import "Contact.h"
#import "Visit.h"
#import "Pharmacy.h"
#import "Prescription.h"
#import "Medication.h"


/**
 An empty category to provide private methods.
 */
@interface ApplicationSupervisor ()

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

-(void) subscribeToSettingsChangedNotifications: (BOOL)yesNo;

-(NSString *) getDataFilePathForFile: (NSString *)fileName;

-(NSString *) getDataDirectoryPath;

/// Provided for backward compatibility.
-(NSString *) getDocumentFilePathForFile: (NSString *)fileName;

/// Perform an upgrade to the current App version's data format.
-(void) upgrade;
/// Upgrade app from qualities of v1.1 and prior to v1.2 qualities. (Introduced v1.2)
/// Moves data files out of Documents folder into a private location.
-(void) upgrade1pt1To1pt2;
/// Try to move or copy, but don't force it. This is used for App Upgrades.
-(BOOL) moveOrCopyFileFrom: (NSString *)from to: (NSString *)to;

-(void) makeBackupOfDataFile: (NSString *)filename usingCopy: (BOOL)useCopy;
-(void) restoreBackupOfDataFile: (NSString *)filename withForce: (BOOL)forceIt;

-(void) initSingleton;

-(void) loadData;
/// Get rid of orphaned data, which could be visits, pharmacies or prescriptions.
-(void) dropOrphanedData;

/// Deserialize archive data into data model instances, then import them and save changes.
-(BOOL) importDataModelsFromArchiveWithData: (NSData *)data;

-(NSDictionary *) deserializeData: (NSData *)fileData ForKey: (NSString *)filenameKey;

-(void) checkData: (NSMutableDictionary *)data andCorrect: (BOOL)doCorrect;

-(void) safeLoadPatients;
-(void) safeLoadVisits;
-(void) safeLoadPharmacies;
-(void) safeLoadPrescriptions;

-(void) loadSettings;

-(void) loadPatients;
-(void) loadVisits;
-(void) loadPrescriptions;
-(void) loadPharmacies;

-(id) findDefaultSettingForKey: (NSString *)settingKey;

-(void) handlePreferenceSettingsChanged: (NSNotification *)n;

/// A private Patient Create method to allow changes while deferring data store saves.
-(BOOL) createPatientWithoutSave: (Patient *)p;

/// Import new patient records from the given collection into the main data store.
/// If successful, Patient data is saved.
/// This is not synchronized.
-(void) importPatientRecordsFrom: (NSDictionary *)toBeMerged;

/// A private Pharmacy Create method to allow changes while deferring data store saves.
-(BOOL) createPharmacyWithoutSave: (Pharmacy *)p;
/// A private Pharmacy Delete method to allow changes while deferring data store saves.
-(BOOL) deletePharmacyWithoutSave: (Pharmacy *)p;
/// Import new Pharmacy records from the given collection into the main data store.
/// If successful, Pharmacy data is saved.
/// This is not synchronized.
-(void) importPharmacyRecordsFrom: (NSDictionary *)toBeMerged;

/// A private Prescription Create method to allow changes while deferring data store saves.
-(BOOL) createPrescriptionWithoutSave: (Prescription *)p;
/// A private Prescription Delete method to allow changes while deferring data store saves.
-(BOOL) deletePrescriptionWithoutSave: (Prescription *)p;
/// Import new prescription records from the given collection into the main data store.
/// If successful, Prescription data is saved.
/// This is not synchronized.
-(void) importPrescriptionRecordsFrom: (NSDictionary *)toBeMerged;

/// A private Visit Create method to allow changes while deferring data store saves.
-(BOOL) createVisitWithoutSave: (Visit *)v;
/// A private Visit Delete method to allow changes while deferring data store saves.
-(BOOL) deleteVisitWithoutSave: (Visit *)v;
/// Import new visit records from the given collection into the main data store.
/// If successful, Visit data is saved.
/// This is not synchronized.
-(void) importVisitRecordsFrom: (NSDictionary *)toBeMerged;

@end


@implementation ApplicationSupervisor

#pragma mark - Class Methods

    // calling this macro will make the ApplicationSupervisor a singleton.
    SYNTHESIZE_SINGLETON_FOR_CLASS(ApplicationSupervisor);


#pragma mark - Instance Properties

@synthesize themeManager;
@synthesize autoGenerateVisitReport;
-(BOOL) autoGenerateVisitReport {
    return (autoGenerateVisitReport && [self.userEmailAddressSetting length] > 0);
}

@synthesize userEmailAddressSetting;
-(NSString *) userEmailAddressSetting {
    return [userEmailAddressSetting stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@dynamic releaseVersionString;
-(NSString *) releaseVersionString {
    return (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

@dynamic nameSortOrderSetting;
-(NameSortOrder) nameSortOrderSetting {
    return nameSortOrderSetting;
}
-(void) setNameSortOrderSetting: (NameSortOrder)value {
    if (value != nameSortOrderSetting) {
        // Set the value.
        nameSortOrderSetting = value;
        // Apply the sort order.
        [self sendNotification: kNameSortSettingChangedNotification about:nil];
    }
}

@dynamic dateSortOrderSetting;
-(NSComparisonResult) dateSortOrderSetting {
    return dateSortOrderSetting;
}
-(void) setDateSortOrderSetting: (NSComparisonResult)value {
    if (value != dateSortOrderSetting) {
        // Set the value.
        dateSortOrderSetting = value;
        // Apply the sort order.
        [self sendNotification: kDateSortSettingChangedNotification about:nil];
    }
}

@dynamic currentThemeSetting;
-(VisualTheme) currentThemeSetting {
    return themeManager.currentTheme;
}
-(void) setCurrentThemeSetting: (VisualTheme)value {
    if (value != themeManager.currentTheme) {
        // Set the theme.
        themeManager.currentTheme = value;
        // Apply the theme.
        [self sendNotification: kThemeSettingChangedNotification about:nil];
    }
}

@dynamic patients;
-(NSArray *) patients {
    if (patients == nil) {
        [self loadData];
    }
    return [NSArray arrayWithArray:[patients allValues]];
}

@dynamic visits;
-(NSArray *) visits {
    if (visits == nil) {
        [self loadData];
    }
    return [NSArray arrayWithArray:[visits allValues]];
}

@dynamic pharmacies;
-(NSArray *) pharmacies {
    if (pharmacies == nil) {
        [self loadData];
    }
    return [NSArray arrayWithArray:[pharmacies allValues]];
}

@dynamic prescriptions;
-(NSArray *) prescriptions {
    if (prescriptions == nil) {
        [self loadData];
    }
    return [NSArray arrayWithArray:[prescriptions allValues]];
}


#pragma mark - Instance Methods

/// Perform any custom initialization required for this Singleton's instance.
-(void) initSingleton {    
    // Init the themeManager.
    themeManager = [[VisualThemeManager alloc] init];
    
    [self subscribeToSettingsChangedNotifications: YES];
    
    // Load all the saved user data.
    [self loadData];
    
    // Load settings and preferences.
    [self loadSettings];
}

-(NSString *) getDataDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *dataDir = [paths objectAtIndex:0];
    dataDir = [dataDir stringByAppendingPathComponent: kCurbsideDataDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath: dataDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath: dataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dataDir;
}

-(NSString *) getDataFilePathForFile: (NSString *)fileName {
    return [[self getDataDirectoryPath] stringByAppendingPathComponent: fileName];
}

/// Provided for backward compatibility.
-(NSString *) getDocumentFilePathForFile: (NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    return [docsDir stringByAppendingPathComponent: fileName];
}

-(void) loadData {
    @synchronized(self) {
        [self upgrade];
        
        // Pharmacies must load before Patients.
        [self loadPharmacies];
        // Prescriptions must load before Visits.
        [self loadPrescriptions];
        // Visits must load before Patients.
        [self loadVisits];
        // Patients must load last.
        [self loadPatients];
    }
}

/// Get rid of orphaned data. For now, only check pharmacies and prescriptions.
-(void) dropOrphanedData {
    @synchronized(self) {
        @try {
            // Remove excess Pharmacies.
            NSMutableArray *referencedPharms = [NSMutableArray array];
            for (Patient *p in [patients allValues]) {
                [referencedPharms addObjectsFromArray: p.pharmacies];
            }
            NSArray *junkPharms = [self.pharmacies filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:
                ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([referencedPharms containsObject: evaluatedObject]) {
                        return NO;
                    }
                    return YES;
                }]];
            if ([junkPharms count] > 0) {
                for (Pharmacy *pharm in junkPharms) {
                    [pharmacies removeObjectForKey: pharm.ident];
                    NSLog(@"Removed an orphaned Pharmacy: %@", pharm);
                }
                [self savePharmacyData];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"Failed to drop orphaned Pharmacy data.");
        }
        
        @try {
            // Now remove excess Prescriptions.
            NSMutableArray *referencedRxs = [NSMutableArray array];
            for (Visit *v in [visits allValues]) {
                [referencedRxs addObjectsFromArray: v.prescriptions];
            }
            NSArray *junkRxs = [self.prescriptions filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:
                 ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                     if ([referencedRxs containsObject: evaluatedObject]) {
                         return NO;
                     }
                     return YES;
                 }]];
            if ([junkRxs count] > 0) {
                for (Prescription *rx in junkRxs) {
                    [prescriptions removeObjectForKey: rx.ident];
                    NSLog(@"Removed an orphaned Prescription: %@", rx);
                }
                [self savePrescriptionData];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"Failed to drop orphaned Prescription data.");
        }
    }
}

/// Primary upgrade method.
-(void) upgrade {
    [self upgrade1pt1To1pt2];
}

/// Upgrade app from qualities of v1.1 and prior to v1.2 qualities. (Introduced v1.2)
/// Moves data files out of Documents folder into a private location.
-(void) upgrade1pt1To1pt2 {
    // Migrate all data files to their new location.
    BOOL moved = NO;
    NSError *ioError = nil;
    NSString *oldDir = [self getDocumentFilePathForFile: kCurbsideDocsDir];
    // Move patients.dar file.
    moved = [self moveOrCopyFileFrom: [oldDir stringByAppendingPathComponent: kPatientsFileName]
                                  to: [self getDataFilePathForFile: kPatientsFileName]];
    // Move visits.dar file.
    moved = [self moveOrCopyFileFrom: [oldDir stringByAppendingPathComponent: kVisitsFileName]
                                  to: [self getDataFilePathForFile: kVisitsFileName]];
    // Move prescriptions.dar file.
    moved = [self moveOrCopyFileFrom: [oldDir stringByAppendingPathComponent: kPrescriptionsFileName]
                                  to: [self getDataFilePathForFile: kPrescriptionsFileName]];
    // Move pharmacies.dar file.
    moved = [self moveOrCopyFileFrom: [oldDir stringByAppendingPathComponent: kPharmaciesFileName]
                                  to: [self getDataFilePathForFile: kPharmaciesFileName]];
    
    // Delete the "Documents/Curbside" directory.
    [[NSFileManager defaultManager] removeItemAtPath: oldDir error: &ioError];
}

/// Try to move or copy, but don't force it.
-(BOOL) moveOrCopyFileFrom: (NSString *)from to: (NSString *)to {
    NSError *moveError = nil;
    NSError *copyError = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath: to]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: from]) {
            [[NSFileManager defaultManager] moveItemAtPath: from toPath: to error: &moveError];
            if (moveError) {
                // try to copy instead.
                [[NSFileManager defaultManager] copyItemAtPath: from toPath: to error: &copyError];
            }
            if (!copyError && !moveError) {
                return YES;
            }
        }
    }
    return NO;
}

-(void) checkData: (NSMutableDictionary *)data andCorrect: (BOOL)doCorrect {
    NSMutableArray *invalids = [[NSMutableArray alloc] init];
    [data enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop) {
        if (![key isEqualToString: [object ident]]) {
            NSLog(@"WARNING: Key-Value mismatch: %@ != %@", key, object);
            [invalids addObject:key];
        }
    }];
    if (doCorrect) {
        for (id key in invalids) {
            [data removeObjectForKey:key];
        }
    }
    [invalids release];
}

-(void) unloadData {
    [prescriptions release];
    prescriptions = nil;
    [patients release];
    patients = nil;
    [visits release];
    visits = nil;
    [pharmacies release];
    pharmacies = nil;
}

/// Create an archive of the Curbside data files and optionally save it to the shared Documents folder.
/// Returns the FileArchiveResult of the newly created data archive, or nil on failure.
///
/// refer to: http://www.raywenderlich.com/1948/how-integrate-itunes-file-sharing-with-your-ios-app
///      and: http://meandmark.com/blog/2010/10/working-with-cocoa-file-packages/
-(FileArchiveResult *) archiveCurbsideData {
    // For now, put this here. Discard orphaned data before backup.
    [self dropOrphanedData];
    
    FileArchiveResult *result = nil;
    NSString *dataDir = [self getDataDirectoryPath];
    NSError *ioError = nil;
    NSURL *dataDirUrl = [NSURL fileURLWithPath: dataDir];
    
    @synchronized(self) {
        // This must be synchronized along with the actual data read ops.
        NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL: dataDirUrl options: NSFileWrapperReadingImmediate error: &ioError];
        
        if (!ioError) {
            BOOL isCompressed = YES;
            NSDate *creationDate = [NSDate date];
            
            // Set the name of the container dir.
            [dirWrapper setPreferredFilename: kArchiveContainerName];
            // Turn the wrapper into a data stream.  This automatically grabs all the contained files too.
            NSData *archive = [dirWrapper serializedRepresentation];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: kDateTimeAmPmEscapedFormatterFormat];
            NSString *filename = [kArchiveContainerName stringByAppendingFormat: @"_%@", [formatter stringFromDate: creationDate]];
            [formatter release];
            
            // Now gzip the data stream.
            @try {
                archive = [archive zlibDeflate];
                filename = [filename stringByAppendingPathExtension: extCompressedArchive];
            }
            @catch (NSException *ex) {
                NSLog(@"Compression failed. Archive will not be compressed.");
                // If gzip failed, just write the uncompressed file out.
                filename = [filename stringByAppendingPathExtension: extArchive];
                isCompressed = NO;
            }
            
            result = [[[FileArchiveResult alloc] initWithFilename: filename andData: archive andCreationDate: creationDate isCompressed: isCompressed] autorelease];
        }
        else {
            NSLog(@"Error creating data directory wrapper: %@", ioError.localizedDescription);
        }
        
        [dirWrapper release];
    }
    
    return result;
}

/// Save the given data archive result to a backup file in the app's Documents directory.
-(void) saveArchiveToDisk: (FileArchiveResult *)archiveResult {
    if (archiveResult && archiveResult.archiveData && archiveResult.fileName) {
        NSError *ioError = nil;
        NSString *archiveFilePath = [self getDocumentFilePathForFile: archiveResult.fileName];
        // Write the archive to the Documents dir.  writeToFile will overwrite anything that is already there with same name.
        if (![archiveResult.archiveData writeToFile: archiveFilePath options: NSAtomicWrite error: &ioError] || ioError) {
            NSLog(@"ERROR: archiving Curbside data failed.\n%@", ioError.localizedDescription);
            // Get rid of leftovers.
            if ([[NSFileManager defaultManager] fileExistsAtPath: archiveFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath: archiveFilePath error: &ioError];
            }
        }
    }
}

/// Open and import data from a Curbside archive specified by the given URL.
-(BOOL) importDataFromUrl: (NSURL *)srcUrl {
    BOOL success = YES;
    
    NSString *message = nil;
    if ([[srcUrl lastPathComponent] hasSuffix: extArchive] || [[srcUrl lastPathComponent] hasSuffix: extCompressedArchive]) {
        @try {
            NSData *data = [NSData dataWithContentsOfURL: srcUrl];
            // If the data is compressed, unzip it.
            if ([[srcUrl lastPathComponent] hasSuffix: extCompressedArchive]) {
                data = [data gzipInflate];
            }
            [self importDataModelsFromArchiveWithData: data];
        }
        @catch (NSException *ex) {
            success = NO;
            message = [NSString stringWithFormat: @"File %@ corrupted.", srcUrl];
        }
    }
    else {
        success = NO;
        message = [NSString stringWithFormat: @"File %@ unrecognized.", srcUrl];
    }
    
    //TODO: move this somewhere else.
    if (!success) {
        NSLog(@"%@", message);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Data Import Failed" 
                                                            message: message
                                                           delegate: nil 
                                                  cancelButtonTitle: @"Ok" 
                                                  otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    
    return success;
}

/// Deserialize archive data into data model instances, then import them and save changes.
-(BOOL) importDataModelsFromArchiveWithData: (NSData *)data {
    BOOL success = NO;
    
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation: data];
    
    if ([dirWrapper isDirectory]) {
        
        @synchronized(self) {
            NSDictionary *wrappers = [dirWrapper fileWrappers];
            // File import order is crucial, same as loadData.
            // Pharmacies load first.
            NSFileWrapper *wrapper = [wrappers objectForKey: kPharmaciesFileName];
            if (wrapper) {
                NSDictionary *dataDict = [self deserializeData: [wrapper regularFileContents] ForKey: pharmaciesKey];
                [self importPharmacyRecordsFrom: dataDict];
                success = YES;
            }
            // Then prescriptions load.
            wrapper = [wrappers objectForKey: kPrescriptionsFileName];
            if (wrapper) {
                NSDictionary *dataDict = [self deserializeData: [wrapper regularFileContents] ForKey: prescriptionsKey];
                [self importPrescriptionRecordsFrom: dataDict];
                success = YES;
            }
            // Then visits load.
            wrapper = [wrappers objectForKey: kVisitsFileName];
            if (wrapper) {
                NSDictionary *dataDict = [self deserializeData: [wrapper regularFileContents] ForKey: visitsKey];
                [self importVisitRecordsFrom: dataDict];
                success = YES;
            }
            // Patients load last.
            wrapper = [wrappers objectForKey: kPatientsFileName];
            if (wrapper) {
                NSDictionary *dataDict = [self deserializeData: [wrapper regularFileContents] ForKey: patientsKey];
                [self importPatientRecordsFrom: dataDict];
                success = YES;
            }
        }
    }
    [dirWrapper release];
    
    if (success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Data Import Complete" 
                                                            message: @"Archived data has been imported into Curbside." 
                                                           delegate: nil 
                                                  cancelButtonTitle: @"Ok" 
                                                  otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    
    return success;
}

-(NSDictionary *) deserializeData: (NSData *)fileData ForKey: (NSString *)filenameKey {
    NSDictionary *dict = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: fileData];
    
    dict = [unarchiver decodeObjectForKey: filenameKey];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    if (dict == nil) {
        dict = [NSDictionary dictionary];
    }
    
    return dict;
}

-(void) makeBackupOfDataFile: (NSString *)filename usingCopy: (BOOL)useCopy {
    NSError *ioError = nil;
    NSString *filePath = [self getDataFilePathForFile: filename];
    NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
    // If old file exists, move it to temp file.
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath: tmpPath error: &ioError];
        if (useCopy) {
            [[NSFileManager defaultManager] copyItemAtPath: filePath toPath: tmpPath error: &ioError];
        }
        else {
            [[NSFileManager defaultManager] moveItemAtPath: filePath toPath: tmpPath error: &ioError];
        }
        
        if (ioError) {
            //TODO: warning
        }
    }
    else {
        NSLog(@"The file %@ to be backed up does not exist.", filename);
    }
}

-(void) restoreBackupOfDataFile: (NSString *)filename withForce: (BOOL)forceIt {
    NSError *ioError = nil;
    NSString *filePath = [self getDataFilePathForFile: filename];
    NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
    
    // Remove the old target if it exists, Force is declared, AND the source file exists too.
    if (forceIt && [[NSFileManager defaultManager] fileExistsAtPath: filePath]
        && [[NSFileManager defaultManager] fileExistsAtPath: tmpPath]) {
        [[NSFileManager defaultManager] removeItemAtPath: filePath error: &ioError];
    }
    // Perform the move if the target name is free.
    if (ioError && ![[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        ioError = nil;
        [[NSFileManager defaultManager] moveItemAtPath: tmpPath toPath: filePath error: &ioError];
    }
    if (ioError) {
        //TODO:
    }
}

-(void) dealloc {
    NSLog(@"Dealloc in class %@", [self class]);
    // Stop observing changes in the Settings app.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    [themeManager release];
    themeManager = nil;
    self.userEmailAddressSetting = nil;
    [self unloadData];
    // Finally, get rid of reference to self.
    instance = nil;
    
    [super dealloc];
}


#pragma mark - Application Settings Management

-(void) addThemeSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kThemeSettingChangedNotification object:nil];
}
-(void) removeThemeSettingChangedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kThemeSettingChangedNotification object:nil];
}

-(void) addNameSortSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kNameSortSettingChangedNotification object:nil];
}
-(void) removeNameSortSettingChangedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kNameSortSettingChangedNotification object:nil];
}

-(void) addDateSortSettingChangedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kDateSortSettingChangedNotification object:nil];
}
-(void) removeDateSortSettingChangedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kDateSortSettingChangedNotification object:nil];
}

-(void) loadSettings {
    NSMutableDictionary *registerValues = [NSMutableDictionary dictionaryWithCapacity: 5];
    
    // First try to load the settings from UserDefaults.  If that fails, get the setting's default value from the PLIST.
    NSDictionary *savedSettings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    id value = [savedSettings objectForKey: kThemeSetting];
    if (value) {
        self.currentThemeSetting = [value integerValue];
        [registerValues setObject: value forKey: kThemeSetting];
    }
    else {
        self.currentThemeSetting = [[self findDefaultSettingForKey: kThemeSetting] integerValue];
        [registerValues setObject: [NSNumber numberWithInteger: self.currentThemeSetting] forKey: kThemeSetting];
    }
    
    value = [savedSettings objectForKey: kNameSortSetting];
    if (value) {
        self.nameSortOrderSetting = [value integerValue];
        [registerValues setObject: value forKey: kNameSortSetting];
    }
    else {
        self.nameSortOrderSetting = [[self findDefaultSettingForKey: kNameSortSetting] integerValue];
        [registerValues setObject: [NSNumber numberWithInteger: self.nameSortOrderSetting] forKey: kNameSortSetting];
    }
    
    value = [savedSettings objectForKey: kDateSortSetting];
    if (value) {
        self.dateSortOrderSetting = [value integerValue];
        [registerValues setObject: value forKey: kDateSortSetting];
    }
    else {
        self.dateSortOrderSetting = [[self findDefaultSettingForKey: kDateSortSetting] integerValue];
        [registerValues setObject: [NSNumber numberWithInteger: self.dateSortOrderSetting] forKey: kDateSortSetting];
    }
    
    value = [savedSettings objectForKey: kReportEmailSetting];
    if (value) {
        self.userEmailAddressSetting = (NSString *)value;
        [registerValues setObject: value forKey: kReportEmailSetting];
    }
    else {
        self.userEmailAddressSetting = [self findDefaultSettingForKey: kReportEmailSetting];
        [registerValues setObject: self.userEmailAddressSetting forKey: kReportEmailSetting];
    }
    
    value = [savedSettings valueForKey: kAutoGenerateReportSetting];
    if (value) {
        self.autoGenerateVisitReport = [[NSUserDefaults standardUserDefaults] boolForKey: kAutoGenerateReportSetting];
        [registerValues setObject: value forKey: kAutoGenerateReportSetting];
    }
    else {
        id obj = [self findDefaultSettingForKey: kAutoGenerateReportSetting];
        self.autoGenerateVisitReport = [obj boolValue];
        [registerValues setObject: obj forKey: kAutoGenerateReportSetting];
    }
    
    // Temporarily disable handling of settings changes so that it doesn't do a feedback loop.
    [self subscribeToSettingsChangedNotifications: NO];
    
    // This has to be done for each initialization according to NSUserDefaults User Reference.
    // It only sets a value on those settings that are missing a value.
    [[NSUserDefaults standardUserDefaults] registerDefaults: registerValues];
    // Saves any changes to the NSUserDefaults domain to disk.
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Re-enable the settings subscription.
    [self subscribeToSettingsChangedNotifications: YES];
}

-(id) findDefaultSettingForKey: (NSString *)settingKey {
    id defaultSetting = nil;
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPath = [[rootPath stringByAppendingPathComponent: dirSettingsBundle] stringByAppendingPathComponent: fileSettingsPlist];
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile: settingsPath];
    
    NSArray *prefContainer = [settingsDict objectForKey: kPreferenceContainerKey];
    NSArray *preference = [prefContainer filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *prefKey = [evaluatedObject objectForKey: kPreferenceKey];
        if ([prefKey isEqualToString: settingKey]) {
            return YES;
        }
        return NO;
    }]];
    
    if ([preference count] > 0) {
        defaultSetting = [[preference objectAtIndex: 0] valueForKey: kPreferenceValue];
    }
    
    return defaultSetting;
}


#pragma mark - Patient Management

-(void) addPatientCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPatientCreatedNotification object:nil];
}
-(void) removePatientCreatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPatientCreatedNotification object:nil];
}

-(void) addPatientUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPatientUpdatedNotification object:nil];
}
-(void) removePatientUpdatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPatientUpdatedNotification object:nil];
}

-(void) addPatientDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPatientDeletedNotification object:nil];
}
-(void) removePatientDeletedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPatientDeletedNotification object:nil];
}

//-(void) loadPatients {
//    @synchronized(self) {
//        NSMutableData *patientData = [[NSMutableData alloc] initWithContentsOfFile:[self getDataFilePathForFile:kPatientsFileName]];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:patientData];
//        
//        patients = [[unarchiver decodeObjectForKey:patientsKey] retain];
//        
//        [unarchiver finishDecoding];
//        [unarchiver release];
//        [patientData release];
//        
//        if (patients == nil) {
//            patients = [[NSMutableDictionary alloc] init];        
//            [self savePatientData];
//        }
//        else {
//            patients = [[NSMutableDictionary dictionaryWithDictionary:[patients autorelease]] retain];
//#ifdef DEBUG
//            [self checkData: patients andCorrect: YES];
//#endif
//        }
//    }
//}

-(void) safeLoadPatients {
    @synchronized(self) {
        [self loadPatients];
    }
}

-(void) loadPatients {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile: [self getDataFilePathForFile: kPatientsFileName]];
    patients = [[NSMutableDictionary dictionaryWithDictionary: [self deserializeData: fileData ForKey: patientsKey]] retain];
    [fileData release];
    
#ifdef DEBUG
    [self checkData: patients andCorrect: YES];
#endif
}


-(BOOL) hasIdenticalPatient: (Patient *)p {
    if ([p isKindOfClass:[Patient class]]) {
        __block BOOL wasFound = NO;
        [patients enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([(Patient *)obj isEquivalent: p] && [key isEqualToString: [p ident]]) {
                NSLog(@"An existing patient was found to be identical with ident: %@", key);
                wasFound = YES;
                *stop = YES;
            }
        }];
        return wasFound;
    }
    return NO;
}

-(BOOL) hasEquivalentPatient: (Patient *)p {
    if ([p isKindOfClass:[Patient class]]) {  
        __block BOOL wasFound = NO;
        [patients enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([(Patient *)obj isEquivalent: p] && ![key isEqualToString: [p ident]]) {
                NSLog(@"An existing patient was found to have the same name and DOB, but different idents.  Existing %@ matches other %@", key, p.ident);
                wasFound = YES;
                *stop = YES;
            }
        }];
        return wasFound;
    }
    return NO;
}

/// Import new patient records from the given collection into the main data store.
/// If successful, Patient data is saved.
/// This is not synchronized.
-(void) importPatientRecordsFrom: (NSDictionary *)toBeMerged {
    int size = [patients count];
    // Make a backup of the data file before trying to merge.
    [self makeBackupOfDataFile: kPatientsFileName usingCopy: YES];
    NSLog(@"%@", toBeMerged);
    @try {
        [toBeMerged enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([patients objectForKey: key]) {
                NSLog(@"Disregarding %@. A Patient with that ident already exists.", obj);
            }
            else {
#ifdef DEBUG
                NSLog(@"\tImporting %@", obj);
#endif
                [self createPatientWithoutSave: obj];
            }
        }];
        
        if ([patients count] > size) {
            [self savePatientData];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR: failed to import Patient data.\n%@", ex);
        // Restore the data from the backup file.
        [self restoreBackupOfDataFile: kPatientsFileName withForce: YES];
    }
}

-(void) savePatientData {
    @synchronized(self) {
        NSMutableData *patientData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:patientData];
        
        [archiver encodeObject:patients forKey:patientsKey];
        [archiver finishEncoding];
        
        NSError *ioError = nil;
        NSString *filePath = [self getDataFilePathForFile: kPatientsFileName];
        NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
        [self makeBackupOfDataFile: kPatientsFileName usingCopy: NO];
        
        if (![patientData writeToFile:filePath atomically:YES]) {
            // Move temp file back to normal file.
            [self restoreBackupOfDataFile: kPatientsFileName withForce: YES];
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            // All is fine.  Just remove the leftover backup file.
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&ioError];
        }
        
        [archiver release];
        [patientData release];
    }
}

-(void) createPatient: (Patient *)p {
    if ([self createPatientWithoutSave: p]) {
        [self savePatientData];
    }
}
-(BOOL) createPatientWithoutSave: (Patient *)p {
    if ([p isKindOfClass:[Patient class]]) {
        [patients setObject:p forKey:p.ident];
        [self sendNotification: kPatientCreatedNotification about: p];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Patient class.", [p class]);
        return NO;
    }
}
-(void) updatePatient: (Patient *)p {
    if ([p isKindOfClass:[Patient class]]) {
        [self savePatientData];
    
        [self sendNotification: kPatientUpdatedNotification about: p];
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Patient class.", [p class]);
    }
}
-(void) deletePatient: (Patient *)p {
    if ([p isKindOfClass:[Patient class]]) {
        // Delete all of this patient's Visit data, which will delete related Prescription data too.
        NSArray *obsoleteVisits = [[self.visits filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"patient == %@", p]] retain];
        if ([obsoleteVisits count] > 0) {
            int rxCount = 0;
            for (Visit *v in obsoleteVisits) {
                // Grab the visit's Rx count before deleting it.
                rxCount += [v.prescriptions count];
                [self deleteVisitWithoutSave: v];
            }
            if (rxCount > 0) {
                // Save prescription data since some items were deleted.
                [self savePrescriptionData];
            }
            // Save visit data now that all visits are deleted.
            [self saveVisitData];
            // Patient references were modified, but don't need to save patient data here, since it will be done at the end.
        }
        [obsoleteVisits release];

        // Delete all of this patient's Pharmacy data.
        NSArray *obsoletePharmacies = [[NSArray arrayWithArray: p.pharmacies] retain];
        if ([obsoletePharmacies count] > 0) {
            for (Pharmacy *pharm in obsoletePharmacies) {
                [self deletePharmacyWithoutSave:pharm];
            }
            [self savePharmacyData];
        }
        [obsoletePharmacies release];

        // Now delete the Patient.
        [patients removeObjectForKey:p.ident];
        [self savePatientData];
    
        [self sendNotification: kPatientDeletedNotification about: p];
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Patient class.", [p class]);
    }
}


#pragma mark - Visit Management

-(void) addVisitCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kVisitCreatedNotification object:nil];
}
-(void) removeVisitCreatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kVisitCreatedNotification object:nil];
}

-(void) addVisitUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kVisitUpdatedNotification object:nil];
}
-(void) removeVisitUpdatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kVisitUpdatedNotification object:nil];
}

-(void) addVisitDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kVisitDeletedNotification object:nil];
}
-(void) removeVisitDeletedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kVisitDeletedNotification object:nil];
}

//-(void) safeLoadVisits {
//    @synchronized(self) {
//        NSMutableData *visitData = [[NSMutableData alloc] initWithContentsOfFile:[self getDataFilePathForFile:kVisitsFileName]];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:visitData];
//        
//        visits = [[unarchiver decodeObjectForKey:visitsKey] retain];
//        
//        [unarchiver finishDecoding];
//        [unarchiver release];
//        [visitData release];
//        
//        if (!visits) {
//            // Use an OrderedMutableDictionary so that the order objects are added is maintained.
//            visits = [[OrderedMutableDictionary alloc] init];
//            [self saveVisitData];
//        }
//        else {
//#ifdef DEBUG
//            [self checkData: visits andCorrect: YES];
//#endif
//        }
//    }
//}

-(void) safeLoadVisits {
    @synchronized(self) {
        [self loadVisits];
    }
}

-(void) loadVisits {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile: [self getDataFilePathForFile: kVisitsFileName]];
    visits = [[OrderedMutableDictionary orderedDictionaryWithDictionary: [self deserializeData: fileData ForKey: visitsKey]] retain];
    [fileData release];
    
#ifdef DEBUG
    [self checkData: visits andCorrect: YES];
#endif
}

-(void) importVisitRecordsFrom: (NSDictionary *)toBeMerged {
    int size = [visits count];
    // Make a backup of the data file before trying to merge.
    [self makeBackupOfDataFile: kVisitsFileName usingCopy: YES];
    
    @try {
        [toBeMerged enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([visits objectForKey: key]) {
            NSLog(@"Disregarding %@. A Visit with that ident already exists.", obj);
        }
        else {
#ifdef DEBUG
            NSLog(@"\tImporting %@", obj);
#endif
            [self createVisitWithoutSave: obj];
        }
        }];
        
        if ([visits count] > size) {
            [self saveVisitData];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR: failed to import Visit data.\n%@", ex);
        // Restore the data from the backup file.
        [self restoreBackupOfDataFile: kVisitsFileName withForce: YES];
    }
}

-(void) saveVisitData {
    @synchronized(self) {
        NSMutableData *visitData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:visitData];
        
        [archiver encodeObject:visits forKey:visitsKey];
        [archiver finishEncoding];
        
        NSError *ioError = nil;
        NSString *filePath = [self getDataFilePathForFile: kVisitsFileName];
        NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
        [self makeBackupOfDataFile: kVisitsFileName usingCopy: NO];
        
        if (![visitData writeToFile:filePath atomically:YES]) {
            // Move temp file back to normal file.
            [self restoreBackupOfDataFile: kVisitsFileName withForce: YES];
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            // All is fine.  Just remove the leftover backup file.
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&ioError];
        }
        
        [archiver release];
        [visitData release];
    }
}

-(Visit *) visitWithIdent: (NSString *)ident {
    return [visits objectForKey: ident];
}

-(void) createVisit: (Visit *)v {
    if ([self createVisitWithoutSave:v]) {
        [self saveVisitData];
    }
}
-(BOOL) createVisitWithoutSave: (Visit *)v {
    if ([v isKindOfClass:[Visit class]]) {
        [visits setObject:v forKey:v.ident];
        [self sendNotification: kVisitCreatedNotification about: v];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Visit class.", [v class]);
        return NO;
    }
}

-(void) updateVisit: (Visit *)v {
    if ([v isKindOfClass:[Visit class]]) {
        [self sendNotification: kVisitUpdatedNotification about: v];
        [self saveVisitData];
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Visit class.", [v class]);
    }
}

-(void) deleteVisits: (NSArray *)vizits {
    int rxCount = 0;
    for (Visit *v in vizits) {
        // Grab the visit's Rx count before deleting it.
        rxCount += [v.prescriptions count];
        [self deleteVisitWithoutSave: v];
    }
    if (rxCount > 0) {
        // Save prescription data since some items were deleted.
        [self savePrescriptionData];
    }
    // Save patient data because patient references to the visit were changed.
    [self savePatientData];
    [self saveVisitData];
}
-(void) deleteVisit: (Visit *)v {
    int rxCount = [v.prescriptions count];
    if ([self deleteVisitWithoutSave: v]) {
        if (rxCount > 0) {
            // Save prescription data since some items were deleted.
            [self savePrescriptionData];
        }
        // Save patient data because patient references to the visit were changed.
        [self savePatientData];
        [self saveVisitData];
    }
}
-(BOOL) deleteVisitWithoutSave: (Visit *)v {
    if ([v isKindOfClass:[Visit class]]) {
        // Delete all of this visit's prescriptions.
        NSArray *obsoleteRxs = [[self.prescriptions filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"visit == %@", v]] retain];
        if ([obsoleteRxs count] > 0) {
            for (Prescription *p in obsoleteRxs) {
                [self deletePrescriptionWithoutSave: p];
            }
            // Postpone the saving of prescription data.
        }
        [obsoleteRxs release];
        
        // Delete the reference held by the owning Patient. (Careful, this erases the patient reference too.)
        [v.patient removeVisit: v];
        // Postpone the saving of patient data.
        
        // Now delete the Visit.
        [visits removeObjectForKey: v.ident];
        // Postpone the saving of visit data.
        [self sendNotification: kVisitDeletedNotification about: v];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Visit class.", [v class]);
        return NO;
    }
}


#pragma mark - Prescription Management

-(void) addPrescriptionCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPrescriptionCreatedNotification object:nil];
}
-(void) removePrescriptionCreatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPrescriptionCreatedNotification object:nil];
}

-(void) addPrescriptionUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPrescriptionUpdatedNotification object:nil];
}
-(void) removePrescriptionUpdatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPrescriptionUpdatedNotification object:nil];
}

-(void) addPrescriptionDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPrescriptionDeletedNotification object:nil];
}
-(void) removePrescriptionDeletedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPrescriptionDeletedNotification object:nil];
}

//-(void) safeLoadPrescriptions {
//    @synchronized(self) {
//        NSMutableData *rxData = [[NSMutableData alloc] initWithContentsOfFile:[self getDataFilePathForFile:kPrescriptionsFileName]];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:rxData];
//        
//        prescriptions = [[unarchiver decodeObjectForKey:prescriptionsKey] retain];
//        
//        [unarchiver finishDecoding];
//        [unarchiver release];
//        [rxData release];
//        
//        if (!prescriptions) {
//            prescriptions = [[OrderedMutableDictionary alloc] init];
//            [self savePrescriptionData];
//        }
//        else {
//#ifdef DEBUG
//            [self checkData: prescriptions andCorrect: YES];
//#endif
//        }
//    }
//}

-(void) safeLoadPrescriptions {
    @synchronized(self) {
        [self loadPrescriptions];
    }
}

-(void) loadPrescriptions {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile: [self getDataFilePathForFile: kPrescriptionsFileName]];
    prescriptions = [[OrderedMutableDictionary orderedDictionaryWithDictionary: [self deserializeData: fileData ForKey: prescriptionsKey]] retain];
    [fileData release];
    
#ifdef DEBUG
    [self checkData: prescriptions andCorrect: YES];
#endif
}

-(void) importPrescriptionRecordsFrom: (NSDictionary *)toBeMerged {
    int size = [prescriptions count];
    // Make a backup of the data file before trying to merge.
    [self makeBackupOfDataFile: kPrescriptionsFileName usingCopy: YES];
    
    @try {
        [toBeMerged enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([prescriptions objectForKey: key]) {
                NSLog(@"Disregarding %@. A Prescription with that ident already exists.", obj);
            }
            else {
#ifdef DEBUG
                NSLog(@"\tImporting %@", obj);
#endif
                [self createPrescriptionWithoutSave: obj];
            }
        }];
        
        if ([prescriptions count] > size) {
            [self savePrescriptionData];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR: failed to import Prescription data.\n%@", ex);
        // Restore the data from the backup file.
        [self restoreBackupOfDataFile: kPrescriptionsFileName withForce: YES];
    }
}

-(void) savePrescriptionData {
    @synchronized(self) {
        NSMutableData *rxData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:rxData];
        
        [archiver encodeObject:prescriptions forKey:prescriptionsKey];
        [archiver finishEncoding];
        
        NSError *ioError = nil;
        NSString *filePath = [self getDataFilePathForFile: kPrescriptionsFileName];
        NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
        [self makeBackupOfDataFile: kPrescriptionsFileName usingCopy: NO];
        
        if (![rxData writeToFile:filePath atomically:YES]) {
            // Move temp file back to normal file.
            [self restoreBackupOfDataFile: kPrescriptionsFileName withForce: YES];
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            // All is fine.  Just remove the leftover backup file.
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&ioError];
        }
        
        [archiver release];
        [rxData release];
    }
}

-(Prescription *) prescriptionWithIdent: (NSString *)ident {
    return [prescriptions objectForKey: ident];
}

-(void) createPrescription: (Prescription *)p {
    if ([self createPrescriptionWithoutSave:p]) {
        [self savePrescriptionData];
    }
}
-(void) createPrescriptions: (NSArray *)rxs {
    int numSaved = 0;
    for (Prescription *rx in rxs) {
        if ([self createPrescriptionWithoutSave: rx]) numSaved++;
    }
    if (numSaved > 0) {
        [self savePrescriptionData];
    }
}
-(BOOL) createPrescriptionWithoutSave: (Prescription *)p {
    if ([p isKindOfClass:[Prescription class]]) {
        [prescriptions setObject:p forKey:p.ident];
        [self sendNotification:kPrescriptionCreatedNotification about:p];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Prescription class.", [p class]);
        return NO;
    }
}

-(void) updatePrescription: (Prescription *)p {
    if ([p isKindOfClass:[Prescription class]]) {
        [self sendNotification:kPrescriptionUpdatedNotification about:p];
        [self savePrescriptionData];
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Prescription class.", [p class]);
    }
}

-(void) deletePrescription: (Prescription *)p {
    if ([self deletePrescriptionWithoutSave:p]) {
        [self savePrescriptionData];
    }
}
-(void) deletePrescriptions: (NSArray *)rxs {
    int numDeleted = 0;
    for (Prescription *rx in rxs) {
        if ([self deletePrescriptionWithoutSave: rx]) numDeleted++;
    }
    if (numDeleted > 0) {
        [self savePrescriptionData];
    }
}
-(BOOL) deletePrescriptionWithoutSave: (Prescription *)p {
    if ([p isKindOfClass:[Prescription class]]) {
        [prescriptions removeObjectForKey:p.ident];
        [self sendNotification:kPrescriptionDeletedNotification about:p];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Prescription class.", [p class]);
        return NO;
    }
}


#pragma mark - Pharmacy Management

-(void) addPharmacyCreatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPharmacyCreatedNotification object:nil];
}
-(void) removePharmacyCreatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPharmacyCreatedNotification object:nil];
}

-(void) addPharmacyUpdatedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPharmacyUpdatedNotification object:nil];
}
-(void) removePharmacyUpdatedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPharmacyUpdatedNotification object:nil];
}

-(void) addPharmacyDeletedObserver: (NSObject *)observer withHandler: (SEL)notificationHandler {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:kPharmacyDeletedNotification object:nil];
}
-(void) removePharmacyDeletedObserver: (NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kPharmacyDeletedNotification object:nil];
}

//-(void) safeLoadPharmacies {
//    @synchronized(self) {
//        NSMutableData *pharmacyData = [[NSMutableData alloc] initWithContentsOfFile:[self getDataFilePathForFile:kPharmaciesFileName]];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pharmacyData];
//        
//        pharmacies = [[unarchiver decodeObjectForKey:pharmaciesKey] retain];
//        
//        [unarchiver finishDecoding];
//        [unarchiver release];
//        [pharmacyData release];
//        
//        if (!pharmacies) {
//            pharmacies = [[NSMutableDictionary alloc] init];
//            [self savePharmacyData];
//        }
//        else {
//            pharmacies = [[NSMutableDictionary dictionaryWithDictionary:[pharmacies autorelease]] retain];
//#ifdef DEBUG
//            [self checkData: pharmacies andCorrect: YES];
//#endif
//        }
//    }
//}

-(void) safeLoadPharmacies {
    @synchronized(self) {
        [self loadPharmacies];
    }
}

-(void) loadPharmacies {
    NSData *fileData = [[NSData alloc] initWithContentsOfFile: [self getDataFilePathForFile: kPharmaciesFileName]];
    pharmacies = [[NSMutableDictionary dictionaryWithDictionary: [self deserializeData: fileData ForKey: pharmaciesKey]] retain];
    [fileData release];
    
#ifdef DEBUG
    [self checkData: pharmacies andCorrect: YES];
#endif
}

-(void) importPharmacyRecordsFrom: (NSDictionary *)toBeMerged {
    int size = [pharmacies count];
    // Make a backup of the data file before trying to merge.
    [self makeBackupOfDataFile: kPharmaciesFileName usingCopy: YES];
    
    @try {
        [toBeMerged enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([pharmacies objectForKey: key]) {
                NSLog(@"Disregarding %@. A Pharmacy with that ident already exists.", obj);
            }
            else {
#ifdef DEBUG
                NSLog(@"\tImporting %@", obj);
#endif
                [self createPharmacyWithoutSave: obj];
            }
        }];
        
        if ([pharmacies count] > size) {
            [self savePharmacyData];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR: failed to import Pharmacy data.\n%@", ex);
        // Restore the data from the backup file.
        [self restoreBackupOfDataFile: kPharmaciesFileName withForce: YES];
    }
}

-(void) savePharmacyData {
    @synchronized(self) {
        NSMutableData *pharmacyData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:pharmacyData];
        
        [archiver encodeObject:pharmacies forKey:pharmaciesKey];
        [archiver finishEncoding];
        
        NSError *ioError = nil;
        NSString *filePath = [self getDataFilePathForFile: kPharmaciesFileName];
        NSString *tmpPath = [filePath stringByAppendingString: kTmpFileMarker];
        [self makeBackupOfDataFile: kPharmaciesFileName usingCopy: NO];
        
        if (![pharmacyData writeToFile:filePath atomically:YES]) {
            // Move temp file back to normal file.
            [self restoreBackupOfDataFile: kPharmaciesFileName withForce: YES];
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            // All is fine.  Just remove the leftover backup file.
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&ioError];
        }
        
        [archiver release];
        [pharmacyData release];
    }
}

-(Pharmacy *) pharmacyWithIdent: (NSString *)ident {
    return [pharmacies objectForKey:ident];
}

-(void) createPharmacy: (Pharmacy *)p {
    if ([self createPharmacyWithoutSave:p]) {
        [self savePharmacyData];
    }
}
-(void) createPharmacies: (NSArray *)pharms {
    int numSaved = 0;
    for (Pharmacy *p in pharms) {
        if ([self createPharmacyWithoutSave:p]) numSaved++;
    }
    if (numSaved > 0) {
        [self savePharmacyData];
    }
}
-(BOOL) createPharmacyWithoutSave: (Pharmacy *)p {
    if ([p isKindOfClass:[Pharmacy class]]) {
        [pharmacies setObject:p forKey:p.ident];
        [self sendNotification:kPharmacyCreatedNotification about:p];
        return YES;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Pharmacy class.", [p class]);
        return NO;
    }
}

-(void) updatePharmacy: (Pharmacy *)p {
    if ([p isKindOfClass:[Pharmacy class]]) {
        [self sendNotification:kPharmacyUpdatedNotification about:p];
        [self savePharmacyData];
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Pharmacy class.", [p class]);
    }
}

-(void) deletePharmacy: (Pharmacy *)p {
    if ([self deletePharmacyWithoutSave: p]) {
        [self savePharmacyData];
    }
}
-(void) deletePharmacies: (NSArray *)pharms {
    int numDeleted = 0;
    for (Pharmacy *p in pharms) {
        if ([self deletePharmacyWithoutSave: p]) numDeleted++;
    }
    if (numDeleted > 0) {
        [self savePharmacyData];
    }
}
-(BOOL) deletePharmacyWithoutSave: (Pharmacy *)p {
    if ([p isKindOfClass:[Pharmacy class]]) {
        if (p.referenceCount == 0) {
            [pharmacies removeObjectForKey:p.ident];
            [self sendNotification:kPharmacyDeletedNotification about:p];
            return YES;
        }
        else return NO;
    }
    else {
        NSLog(@"Error: Cannot treat instance of '%@' as Pharmacy class.", [p class]);
        return NO;
    }
}


#pragma mark - Event Handling

-(void) addTableViewCellWillUpdateObserver: (NSObject *)observer withHandler: (SEL)notificationHandler forNotificationName: (NSString *)n {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:notificationHandler name:n object:nil];
}
-(void) removeTableViewCellWillUpdateObserver: (NSObject *)observer forNotificationName: (NSString *)n {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:n object:nil];
}

// User preferences have changed in the Settings app, so update to reflect them.
-(void) handlePreferenceSettingsChanged: (NSNotification *)n {
    NSDictionary *settingsDict = [[n object] dictionaryRepresentation];
    
    for (NSString *prefKey in settingsDict) {
        if ([prefKey isEqual: kReportEmailSetting]) {
            self.userEmailAddressSetting = [settingsDict objectForKey: kReportEmailSetting];
            continue;
        }
        if ([prefKey isEqual: kNameSortSetting]) {
            self.nameSortOrderSetting = [[settingsDict objectForKey: kNameSortSetting] integerValue];
            continue;
        }
        if ([prefKey isEqual: kDateSortSetting]) {
            self.dateSortOrderSetting = [[settingsDict objectForKey: kDateSortSetting] integerValue];
            continue;
        }
        if ([prefKey isEqual: kThemeSetting]) {
            self.currentThemeSetting = [[settingsDict objectForKey: kThemeSetting] integerValue];
            continue;
        }
        if ([prefKey isEqual: kAutoGenerateReportSetting]) {
            self.autoGenerateVisitReport = [[settingsDict objectForKey: kAutoGenerateReportSetting] boolValue];
            continue;
        }
    }
}

-(void) subscribeToSettingsChangedNotifications: (BOOL)yesNo {
    if (yesNo) {
        
        
        // Observe changes to Curbside settings in the Settings app.
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handlePreferenceSettingsChanged:)
                                                     name: NSUserDefaultsDidChangeNotification
                                                   object: nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver: self 
                                                        name: NSUserDefaultsDidChangeNotification 
                                                      object: nil];
    }
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
