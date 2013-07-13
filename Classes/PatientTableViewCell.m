//
//  PatientTableViewCell.m
//  CurbSide
//
//  Created by Greg Walker on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatientTableViewCell.h"
#import "Patient.h"
#import "Constants.h"

@interface PatientTableViewCell ()

-(void) subscribeToPatientPropertyChanges: (BOOL)yesNo;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

@end


@implementation PatientTableViewCell

@synthesize patient;
// Override the patient setter to do custom layout.
-(void) setPatient: (Patient *)p {
    if (p == patient) {
        return;
    }
    
    [self subscribeToPatientPropertyChanges:NO];
    [patient autorelease];
    patient = [p retain];
    [self subscribeToPatientPropertyChanges:YES];
    
    if (patient != nil) {
        fnameLabel.text = [NSString stringWithFormat: @"%@ ", patient.firstName];
        lnameLabel.text = patient.lastName;
    }
    else {
        fnameLabel.text = @"";
        lnameLabel.text = @"";
    }
    
    [self layoutLabels];
}

@dynamic emphasisOnLastName;
-(BOOL) emphasisOnLastName {
    return emphasisOnLastName;
}
-(void) setEmphasisOnLastName: (BOOL)value {
    if (value == emphasisOnLastName) {
        return;
    }
    emphasisOnLastName = value;
    
    if (patient != nil) {
        [self layoutLabels];
    }
}

@dynamic firstNameText;
-(NSString *) firstNameText {
    //TODO: this will cause a bug if first name includes a middle initial.
    return [fnameLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@dynamic lastNameText;
-(NSString *) lastNameText {
    return lnameLabel.text;
}

-(id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier andFontSize: (NSInteger)size {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        patient = nil;
        emphasisOnLastName = YES;
        
        // Initialize two new labels for first name and last name
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        //label.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:size];
        fnameLabel = label;
        [self.contentView addSubview:label];
        // Do not release the allocated label, as it will be released in Dealloc()

        label = [[UILabel alloc] initWithFrame:CGRectZero];
        //label.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:size];
        lnameLabel = label;
        [self.contentView addSubview:label];
        // Do not release the allocated label, as it will be released in Dealloc()
    }
    return self;
}

-(void) setSortByLastName: (BOOL)b {
    emphasisOnLastName = b;
    if (patient != nil) {
        [self layoutLabels];
    }
}

-(void) layoutLabels {
    CGSize fnameLabelSize = [fnameLabel.text sizeWithFont: fnameLabel.font];
    
    if (emphasisOnLastName) {
        fnameLabel.textColor = [UIColor grayColor];
    }
    else {
        fnameLabel.textColor = [UIColor blackColor];
    }
    
    // position the first name first in the content rectangle.
    CGRect firstFrame = self.contentView.bounds;
    firstFrame.size.width = fnameLabelSize.width;
    fnameLabel.frame = firstFrame;
    
    // position the last name second in the cell.
    CGRect lastFrame = self.contentView.bounds;
    lastFrame.origin.x += firstFrame.size.width;
    lastFrame.size.width -= firstFrame.size.width;
    lnameLabel.frame = lastFrame;
    
    [fnameLabel setNeedsDisplay];
    [lnameLabel setNeedsDisplay];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Patient Row: %@ %@", patient.firstName, patient.lastName];
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

- (void)dealloc {
    self.patient = nil;
    [fnameLabel release];
    [lnameLabel release];
    [super dealloc];
}


#pragma mark Event Handling

///
-(void) observeValueForKeyPath: (NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Patient *p = (Patient *)object;
    if (p != self.patient) {
        return;
    }
    BOOL willChange = ([keyPath isEqualToString:@"firstName"] || [keyPath isEqualToString:@"lastName"]);
    
    if (willChange) {
        // Give preemptive notice to any observers that the tableCell labels will changed.
        [self sendNotification: kPatientTableCellTextWillUpdateNotification about:self];
    }
    
    // Only need to refresh the first or last name.
    if ([keyPath isEqualToString:@"firstName"]) {
        fnameLabel.text = [NSString stringWithFormat: @"%@ ", p.firstName];
    }
    else if ([keyPath isEqualToString:@"lastName"]) {
        lnameLabel.text = p.lastName;
    }
    if (willChange) {
        [self layoutLabels];
    }
}

///
-(void) subscribeToPatientPropertyChanges: (BOOL)yesNo {
    if (self.patient) {
        if (yesNo) {
            [self.patient addPropertyChangeObserver:self];
            //NSLog(@"Added PatientTableViewCell as observer of new Patient.");
        }
        else {
            [self.patient removePropertyChangeObserver:self];
            //NSLog(@"Removed PatientTableViewCell as observer of old patient.");
        }
    }
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
