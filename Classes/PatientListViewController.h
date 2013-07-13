//
//  PatientListViewController.h
//  CurbSide
//
//  Created by Greg Walker on 3/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApplicationSupervisor.h"
#import "ViewControllerBase.h"
#import "ParentViewDelegate.h"
#import "PatientViewController.h"
#import "PatientTableViewCell.h"
#import "PatientsByNameDataSource.h"
#import "EditPatientViewController.h"


@interface PatientListViewController : ViewControllerBase <UITableViewDelegate, ParentViewDelegate> {
    @private
    PatientsByNameDataSource *listDataSource;
    EditPatientViewController *newPatientViewController;
    PatientViewController *patientViewController;
    UINavigationController *newPatientNavController;
    NSString *selectedFirstName;
    NSString *selectedLastName;
    UITableView *tableView;
    UISearchBar *searchBar;
    //UIBarButtonItem *doneTypingButton;
}

@property (nonatomic, retain) IBOutlet PatientsByNameDataSource *listDataSource;

@property (nonatomic, retain) IBOutlet EditPatientViewController *newPatientViewController;

@property (nonatomic, retain) IBOutlet PatientViewController *patientViewController;

@property (nonatomic, retain) NSString *selectedFirstName;

@property (nonatomic, retain) NSString *selectedLastName;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

//@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneTypingButton;

@end
