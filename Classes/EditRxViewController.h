//
//  NewRxViewController.h
//  CurbSide
//
//  Created by Greg Walker on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewControllerBase.h"
@class SimplePickerDataSource;
@class Visit;
@class Prescription;
@class RxListDataSource;


@interface EditRxViewController : ViewControllerBase <UITextFieldDelegate, UIPickerViewDelegate> {
@private
    //Visit *visit;
    RxListDataSource *rxDataSource;
    SimplePickerDataSource *timeUnitDataSource;
    Prescription *prescription;
    BOOL isNewPrescription;
    BOOL needsViewRefresh;
    UIView *controlBeingEdited;
    UIScrollView *scrollView;
    UIView *scrollContentView;
    UIBarButtonItem *saveButton;
    UIPickerView *timeUnitPicker;
    UITextField *timeUnitTextField;
    UITextField *dispensedTextField;
    UITextField *doseTextField;
    UITextField *refillsTextField;
    UITextField *medicationTextField;
    UITextField *freqQuantityTextField;
    UITextField *periodQuantityTextField;
    UITableView *autoCompleteTableView;
    UILabel *doseLabel;
    UILabel *nameLabel;
    UILabel *dispensedLabel;
    UILabel *refillsLabel;
    UILabel *freqLabel;
}

@property (nonatomic, retain) Prescription *prescription;

@property (nonatomic, retain) RxListDataSource *rxDataSource;

@property (nonatomic, retain) NSString *medicationName;

@property (nonatomic, retain) NSString *dispensed;

@property (nonatomic, retain) NSString *dose;

@property (nonatomic, retain) NSString *refills;

@property (nonatomic, retain) NSString *frequencyQuantity;

@property (nonatomic, retain) NSString *periodQuantity;

@property (nonatomic, retain) NSString *timeUnits;

@property (nonatomic, assign) BOOL isNewPrescription;

@property (nonatomic, retain) IBOutlet SimplePickerDataSource *timeUnitDataSource;
@property (nonatomic, retain) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *scrollContentView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIPickerView *timeUnitPicker;
@property (nonatomic, retain) IBOutlet UITextField *timeUnitTextField;
@property (nonatomic, retain) IBOutlet UITextField *dispensedTextField;
@property (nonatomic, retain) IBOutlet UITextField *doseTextField;
@property (nonatomic, retain) IBOutlet UITextField *refillsTextField;
@property (nonatomic, retain) IBOutlet UITextField *medicationTextField;
@property (nonatomic, retain) IBOutlet UITextField *freqQuantityTextField;
@property (nonatomic, retain) IBOutlet UITextField *periodQuantityTextField;

@property (nonatomic, retain) IBOutlet UILabel *doseLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dispensedLabel;
@property (nonatomic, retain) IBOutlet UILabel *refillsLabel;
@property (nonatomic, retain) IBOutlet UILabel *freqLabel;

-(id) initWithPrescription: (Prescription *)p;

-(IBAction) dismissTimeUnitPickerAction: (id)sender;

-(IBAction) savePrescriptionAction: (id)sender;

-(IBAction) beginEditingTextFieldAction: (id)sender;

-(IBAction) periodQuantityEditingEndAction: (id)sender;

//-(IBAction) periodTimeEditingBeginAction: (id)sender;

-(IBAction) freqQuantityEditingEndAction: (id)sender;

//-(IBAction) freqTimeEditingBeginAction: (id)sender;

-(IBAction) timeUnitEditingEndAction: (id)sender;

-(IBAction) setDoseValueAction: (id)sender;

-(IBAction) setDispensedValueAction:(id)sender;

-(IBAction) setRefillsValueAction:(id)sender;

@end
