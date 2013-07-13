//
//  RxViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Prescription;


@interface RxViewController : UIViewController {
    @private
    Prescription *prescription;
    BOOL needsViewRefresh;
    UITextField *timeUnitTextField;
    UITextField *dispensedTextField;
    UITextField *doseTextField;
    UITextField *refillsTextField;
    UITextField *medicationTextField;
    UITextField *freqQuantityTextField;
    UITextField *periodQuantityTextField;
    UILabel *doseLabel;
    UILabel *nameLabel;
    UILabel *dispensedLabel;
    UILabel *refillsLabel;
    UILabel *freqLabel;
}

@property (nonatomic, retain) Prescription *prescription;

@property (nonatomic, retain) NSString *medicationName;

@property (nonatomic, retain) NSString *dispensed;

@property (nonatomic, retain) NSString *dose;

@property (nonatomic, retain) NSString *refills;

@property (nonatomic, retain) NSString *frequencyQuantity;

@property (nonatomic, retain) NSString *periodQuantity;

@property (nonatomic, retain) NSString *timeUnits;

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

-(IBAction) toggleTimeSubViewAction: (id)sender;

@end
