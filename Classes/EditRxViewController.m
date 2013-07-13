//
//  NewRxViewController.m
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditRxViewController.h"
#import "ApplicationSupervisor.h"
#import "SimplePickerDataSource.h"
#import "Constants.h"
#import "RxListDataSource.h"
#import "Prescription.h"
#import "Visit.h"


@interface EditRxViewController ()

-(BOOL) validatePrescription;

-(void) showInvalidPrescriptionAlert;

-(void) animateKeyboardWillShow: (NSNotification *)notification;

-(void) animateKeyboardWillHide: (NSNotification *)notification;

-(void) refreshView;

-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context;

-(void) applyChanges;

-(void) showTimeUnitPicker;

-(void) dismissTimeUnitPicker;

-(void) applyTheme;
-(void) handleThemeChanged: (NSNotification *)n;
-(void) subscribeToAppNotifications: (BOOL)yesNo;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

@end


@implementation EditRxViewController

#pragma mark - Properties

@synthesize timeUnitDataSource;
@synthesize isNewPrescription;
@synthesize rxDataSource;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize saveButton;
@synthesize timeUnitPicker;
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
@synthesize autoCompleteTableView;

@synthesize prescription;
-(void) setPrescription: (Prescription *)p {
    if (p == prescription) {
        return;
    }
    [prescription autorelease];
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
-(id) init {
    self = [super initWithNibName: @"EditPrescriptionView" bundle: nil];
    if (self) {
        self.title = @"New Prescription";
        isNewPrescription = YES;
    }
    return self;
}

///
//-(id) initWithDataSource: (RxListDataSource *)dataSource andPrescriptionIndex: (NSIndexPath *)rx {
-(id) initWithPrescription: (Prescription *)rx {
    self = [super initWithNibName: @"EditPrescriptionView" bundle: nil];
    if (self) {
        //self.rxDataSource = dataSource;
        self.prescription = rx;
        self.title = @"Edit Prescription";
        isNewPrescription = NO;
    }
    return self;
}

-(BOOL) validatePrescription {
    if (self.medicationName && ![self.medicationName isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

-(void) showInvalidPrescriptionAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"A new prescription requires a medication." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
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

/// Apply any outstanding UI changes to this view's prescription object.
-(void) applyChanges {
    self.prescription.medication = self.medicationName;
    self.prescription.dosage = self.dose;
    self.prescription.numRefills = [self.refills intValue];
    self.prescription.totalDispensed = [self.dispensed intValue];
    self.prescription.usageFrequency = self.frequencyQuantity;
    self.prescription.usagePeriod = self.periodQuantity;
    self.prescription.usageUnits = self.timeUnits;
}

-(void) keyboardResizeDidFinish: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
    if (controlBeingEdited) {
        // Try to scroll the control into view.
        CGRect frame = controlBeingEdited.frame;
        UIView *view = controlBeingEdited.superview;
        // Add the Y-origin of all superviews until the master UIScrollView is found.
        while (view && ([view isKindOfClass: [UITableView class]] || ![view isKindOfClass: [UIScrollView class]])) {
            frame.origin.y += view.frame.origin.y;
            view = view.superview;
        }
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
}

-(void) slideDownDidStop: (NSString *)animationId finished: (BOOL)finished context: (void *)context {
	// a picker has finished sliding downwards, so remove it
	[timeUnitPicker removeFromSuperview];
}

-(void) dismissTimeUnitPicker {
    if (timeUnitPicker.superview != nil) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [timeUnitPicker sizeThatFits:CGSizeZero];
        CGRect scrollFrame = scrollView.frame;
        CGRect endFrame = timeUnitPicker.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        scrollFrame.size.height += pickerSize.height;
        
        // start the slide down animation
        [UIView beginAnimations:@"ResizeForTimeUnitPicker" context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop:finished:context:)];
        timeUnitPicker.frame = endFrame;
        scrollView.frame = scrollFrame;
        [UIView commitAnimations];
        
        // Swap the done button's action from "set time unit" to "save" function.
        self.navigationItem.rightBarButtonItem.action = @selector(savePrescriptionAction:);
        
        // If the picker is dismissed but the TextField is still empty, set the text using the selected row.
        if ([self.timeUnits isEqualToString:@""]) {
            self.timeUnits = [timeUnitDataSource dataAtRow: [timeUnitPicker selectedRowInComponent:0]];
        }
    }
}

-(void) showTimeUnitPicker {
    // check if our date picker is already on screen
    if (timeUnitPicker.superview == nil) {
        [self.view.window addSubview: timeUnitPicker];
        
        // Swap the done button's action from "done" to "dismiss picker" function.
        self.navigationItem.rightBarButtonItem.action = @selector(dismissTimeUnitPickerAction:);
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [timeUnitPicker sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        timeUnitPicker.frame = startRect;
        
        // compute the end frames for the picker and the scrollview.
        CGRect scrollFrame = scrollView.frame;
        CGRect pickerEndRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                          pickerSize.width, pickerSize.height);
        scrollFrame.size.height -= pickerSize.height;
        // start the slide up animation
        [UIView beginAnimations:@"ResizeForTimeUnitPicker" context:NULL];
        [UIView setAnimationDuration:0.3];
        // Set the completion handler to scroll the field into view.
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector: @selector(keyboardResizeDidFinish:finished:context:)];
        scrollView.frame = scrollFrame;
        timeUnitPicker.frame = pickerEndRect;
        [UIView commitAnimations];
    }
}

-(void) applyTheme {
    // Set the background image.
    [[ApplicationSupervisor instance].themeManager applyThemeToView:self.view withOption:THEME_OPTION_B];
    
    // Update the font color for labels.
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: nameLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: doseLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: freqLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: dispensedLabel];
    [[ApplicationSupervisor instance].themeManager applyThemeToLabel: refillsLabel];
}


#pragma mark Actions

-(IBAction) savePrescriptionAction: (id)sender {
    [self dismissKeyboard];
    
    if ([self validatePrescription]) {
        // In the case of a new prescription, it is already owned by a Visit.  This controller does
        // not need to save anything, just set the values on the prescription.
        [self applyChanges];
        
        if (isNewPrescription) {
            // Don't save changes yet.  Just fire an event and let the VisitController handle
            // creation of the Pharmacy.
            //[self sendNotification:kPrescriptionSavedNotification about: [NotificationArgs argsWithData:self.prescription fromSender:self]];
        }
        // However, if this is an update, need to save changes to Application Supervisor.
        else {
            [[ApplicationSupervisor instance] updatePrescription:self.prescription];
        }
        
        self.prescription = nil;
        // Pop view directly to NavigationController since this view will always show under its control.
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self showInvalidPrescriptionAlert];
    }
}

-(IBAction) dismissTimeUnitPickerAction: (id)sender {
    [self dismissTimeUnitPicker];
}

-(IBAction) beginEditingTextFieldAction: (id)sender {
    [self dismissTimeUnitPicker];
    controlBeingEdited = (UIControl *)sender;
}

-(IBAction) periodQuantityEditingEndAction: (id)sender {
    if (prescription && isNewPrescription) {
        prescription.usagePeriod = self.periodQuantity;
    }
}

-(IBAction) freqQuantityEditingEndAction: (id)sender {
    if (prescription && isNewPrescription) {
        prescription.usageFrequency = self.frequencyQuantity;
    }
}

//-(IBAction) freqTimeEditingBeginAction: (id)sender {
//    controlBeingEdited = (UIControl *)sender;
//    [self showTimeUnitPicker];
//}

-(IBAction) timeUnitEditingEndAction: (id)sender {
    if (prescription && isNewPrescription) {
        prescription.usageUnits = self.timeUnits;
    }
    [self dismissTimeUnitPicker];
}

-(IBAction) setDoseValueAction: (id)sender {
    UITextField *tf = (UITextField *)sender;
    if (prescription && isNewPrescription) {
        prescription.dosage = tf.text;
    }
}

-(IBAction) setDispensedValueAction:(id)sender {
    UITextField *tf = (UITextField *)sender;
    if (prescription && isNewPrescription) {
        prescription.totalDispensed = [tf.text intValue];
    }
}

-(IBAction) setRefillsValueAction:(id)sender {
    UITextField *tf = (UITextField *)sender;
    if (prescription && isNewPrescription) {
        prescription.numRefills = [tf.text intValue];
    }
}


#pragma mark ViewControllerBase Methods

/// animateKeyboardWillShow
///
-(void) animateKeyboardWillShow: (NSNotification *)notification {
    // Swap the done button's action from "done" to "dismiss keyboard" function.
    self.navigationItem.rightBarButtonItem.action = @selector(dismissKeyboard);
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.height -= keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:animationDuration];
    // Set the completion handler to scroll the field into view.
    [UIView setAnimationDidStopSelector: @selector(keyboardResizeDidFinish:finished:context:)];
    scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

/// animateKeyboardWillHide
///
-(void) animateKeyboardWillHide: (NSNotification *)notification {
    // Swap the done button's action from "dismiss keyboard" to "done" function.
    self.navigationItem.rightBarButtonItem.action = @selector(savePrescriptionAction:);
    
	CGFloat keyboardheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect scrollFrame = scrollView.frame;
    scrollFrame.size.height += keyboardheight;
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    scrollView.frame = scrollFrame;
    [UIView commitAnimations];
}

/// dismissKeyboard
///
-(void) dismissKeyboard {
    if (controlBeingEdited) {
        [controlBeingEdited resignFirstResponder];
        controlBeingEdited = nil;
    }
    [self dismissTimeUnitPicker];
}


#pragma mark UIViewController lifecycle

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
    
    [self applyTheme];
    [self subscribeToAppNotifications:YES];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    // If you add more, put them at the end so that existing ones don't change.
    NSArray *data = [[NSArray arrayWithObjects: @"week", @"day", @"hour", @"minute", @"as needed", nil] retain];
    [self.timeUnitDataSource setData: data];
    [data release];
    
    scrollView.contentSize = scrollContentView.frame.size;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (needsViewRefresh) {
        [self refreshView];
    }
}

-(void) viewDidDisappear:(BOOL)animated {    
    [super viewDidDisappear:animated];
}

-(void) viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
    //[self subscribeToAppNotifications:NO];
}

/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark UITextFieldDelegate Methods

/// textFieldShouldReturn
///
-(BOOL) textFieldShouldReturn: (UITextField *)tf {
    // the user pressed the "Done" button, so dismiss the keyboard and stop editing.
    [tf resignFirstResponder];
    return YES;
}

/// textFieldShouldBeginEditing
///
-(BOOL) textFieldShouldBeginEditing: (UITextField *)tf {
    if (tf == timeUnitTextField) {
        [self dismissKeyboard];
        controlBeingEdited = tf;
        [self showTimeUnitPicker];
        return NO;
    }
    
    return YES;
}

/// textFieldDidBeginEditing
///
//-(void) textFieldDidBeginEditing: (UITextField *)tf {
//    controlBeingEdited = tf;
//}


#pragma mark UIPickerViewDelegate Methods

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component {
    if (pickerView == timeUnitPicker) {
        self.timeUnits = [timeUnitDataSource dataAtRow: row];
    }
}

-(NSString *) pickerView: (UIPickerView *)pickerView titleForRow: (NSInteger)row forComponent: (NSInteger)component {
    if (pickerView == timeUnitPicker) {
        return [timeUnitDataSource dataAtRow: row];
    }
    
    return @"";
}
        
#pragma mark Memory Management

- (void)dealloc {
    [self subscribeToAppNotifications:NO];
    self.prescription = nil;
    self.timeUnitDataSource = nil;
    self.scrollView = nil;
    self.scrollContentView = nil;
    self.saveButton = nil;
    self.timeUnitPicker = nil;
    self.dispensedTextField = nil;
    self.doseTextField = nil;
    self.refillsTextField = nil;
    self.medicationTextField = nil;
    self.timeUnitTextField = nil;
    self.freqQuantityTextField = nil;
    self.periodQuantityTextField = nil;
    self.autoCompleteTableView = nil;
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

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}
        
@end
