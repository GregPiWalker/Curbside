//
//  LookupTableDataSource.h
//  CurbSide
//
//  Created by Greg Walker on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCellFactory.h"
#import "ApplicationSupervisor.h"
#import "PatientsByNameDataSource.h"
#import "LookupDataSource.h"
@class Patient;


typedef enum {
    PatientTextFieldTag = 0
} VisitUITextFieldTag;


@interface PatientLookupDataSource : LookupDataSource {
    @private
    PatientsByNameDataSource *sortedPatients;
}

@property (nonatomic, retain) Patient *selectedPatient;

@property (nonatomic, retain) PatientsByNameDataSource *sortedPatients;

@end
