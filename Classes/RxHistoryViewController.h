//
//  RxHistoryViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryViewController.h"
#import "RxHistoryDataSource.h"
#import "Prescription.h"
#import "Patient.h"
#import "RxViewController.h"
@class MainViewController;


@interface RxHistoryViewController : HistoryViewController {
    BOOL wasViewPopped;
}


@end
