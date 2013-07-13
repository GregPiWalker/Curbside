//
//  RxViewController.m
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RxViewController.h"
#import "Prescription.h"
#import "Constants.h"
#import "ApplicationSupervisor.h"


@interface RxViewController ()

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

@end


@implementation RxViewController


#pragma mark - Properties

@synthesize dispensedTextField;
@synthesize doseTextField;
@synthesize refillsTextField;
@synthesize medicationTextField;
@synthesize timeUnitTextField;
@synthesize freqQuantityTextField;
@synthesize periodQuantityTextField;
@synthesize nameLabel;
@synthesize doseLabel;
@synthesize freqLabel;
@synthesize refillsLabel;
@synthesize dispensedLabel;

@synthesize prescription;
-(void) setPrescription: (Prescription *)p {
    if (p == prescription) {
        return;
    }
    [prescription release];
    prescription = [p retain];
    needsViewRefresh = YES;
    
    if (prescription != nil) {
        //
    }
}

@dynamic medicationName;
-(NSString *) medicationName {
    return medicationTextField.text;
}
-(void) setMedicationName: (NSString *)value {
    medicationTextField.text = value;
}

@dynamic dose;
-(NSString *) dose {
    return doseTextField.text;
}
-(void) setDose: (NSString *)value {
    doseTextField.text = value;
}

@dynamic dispensed;
-(NSString *) dispensed {
    return dispensedTextField.text;
}
-(void) setDispensed: (NSString *)value {
    dispensedTextField.text = value;
}

@dynamic refills;
-(NSString *) refills {
    return refillsTextField.text;
}
-(void) setRefills: (NSString *)value {
    refillsTextField.text = value;
}

@dynamic frequencyQuantity;
-(NSString *) frequencyQuantity {
    return freqQuantityTextField.text;
}
-(void) setFrequencyQuantity: (NSString *)value {
    freqQuantityTextField.text = value;
}

@dynamic periodQuantity;
-(NSString *) periodQuantity {
    return periodQuantityTextField.text;
}
-(void) setPeriodQuantity: (NSString *)value {
    periodQuantityTextField.text = value;
}

@dynamic timeUnits;
-(NSString *) timeUnits {
    return timeUnitTextField.text;
}
-(void) setTimeUnits: (NSString *)value {
    timeUnitTextField.text = value;
}


#pragma mark - Methods

///
-(id) initWithPrescription: (Prescription *)rx {
    self = [super initWithNibName: @"PrescriptionView" bundle: nil];
    if (self) {
        self.prescription = rx;
        self.title = @"Prescription";
    }
    return self;
}

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    self.prescription = nil;
    self.dispensedTextField = nil;
    self.doseTextField = nil;
    self.refillsTextField = nil;
    self.medicationTextField = nil;
    self.timeUnitTextField = nil;
    self.freqQuantityTextField = nil;
    self.periodQuantityTextField = nil;
    [nameLabel release];
    [doseLabel release];
    [refillsLabel release];
    [freqLabel release];
    [dispensedLabel release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //TODO:
}

-(void) refreshView {
    if (self.prescription != nil) {
        self.medicationName = prescription.medication;
        self.dose = prescription.dosage;
        self.dispensed = (prescription.totalDispensed > 0 ? [NSString stringWithFormat: @"%i", prescription.totalDispensed] : @"");
        self.refills = (prescription.numRefills > 0 ? [NSString stringWithFormat: @"%i", prescription.numRefills] : @"");
        self.periodQuantity = prescription.usagePeriod;
        self.frequencyQuantity = prescription.usageFrequency;
        self.timeUnits = prescription.usageUnits;
    }
    else {
        self.medicationName = @"";
        self.dose = @"";
        self.dispensed = @"";
        self.refills = @"";
        self.periodQuantity = @"";
        self.frequencyQuantity = @"";
        self.timeUnits = @"";
    }
    
    needsViewRefresh = NO;
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_D];
    
    // Update the font color for labels.
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: nameLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: doseLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: freqLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: dispensedLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: refillsLabel];
}


#pragma mark Actions

-(IBAction) toggleTimeSubViewAction: (id)sender {
    
}


#pragma mark View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/** viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    [self applyTheme];
    [self subscribeToAppNotifications:YES];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (needsViewRefresh) {
        [self refreshView];
    }
}

-(void) viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    //[self subscribeToAppNotifications:NO];
    // e.g. self.myOutlet = nil;
    //TODO:
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark Event Handling

-(void) handleThemeChanged: (NSNotification *)n {
    [self applyTheme];
}

///
-(void) subscribeToAppNotifications: (BOOL)yesNo {
    if (yesNo) {
        [[ApplicationSupervisor instance] addThemeSettingChangedObserver:self withHandler:@selector(handleThemeChanged:)];
    }
    else {
        [[ApplicationSupervisor instance] removeThemeSettingChangedObserver:self];
    }
}

@end
