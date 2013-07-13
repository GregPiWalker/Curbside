//
//  PharmacyTableViewCell.m
//  Curbside
//
//  Created by Greg Walker on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PharmacyTableViewCell.h"
#import "Pharmacy.h"
#import "Contact.h"
#import "Constants.h"



@interface PharmacyTableViewCell ()

-(void) subscribeToPharmacyPropertyChanges: (BOOL)yesNo;

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data;

@end


@implementation PharmacyTableViewCell


#pragma mark - Properties

@synthesize pharmacy;
// Override the patient setter to do custom layout.
-(void) setPharmacy: (Pharmacy *)p {
    if (p == pharmacy) {
        return;
    }
    
    [self subscribeToPharmacyPropertyChanges:NO];
    [pharmacy autorelease];
    pharmacy = [p retain];
    [self subscribeToPharmacyPropertyChanges:YES];
    
    if (pharmacy != nil) {
        nameLabel.text = pharmacy.name;
        addressLabel.text = [pharmacy.contactInfo simplifiedDescription];
    }
    else {
        nameLabel.text = @"";
        addressLabel.text = @"";
    }
    
    [self layoutLabels];
}

@dynamic nameText;
-(NSString *) nameText {
    return [nameLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@dynamic addressText;
-(NSString *) addressText {
    return [addressLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}


#pragma mark - Methods

-(id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier andFontSize: (NSInteger)size {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pharmacy = nil;
        
        // Initialize two new labels for first name and last name
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        //label.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize: size];
        nameLabel = label;
        [self.contentView addSubview:label];
        // Do not release the allocated label, as it will be released in Dealloc.
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        //label.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont boldSystemFontOfSize: size - 2];
        addressLabel = label;
        [self.contentView addSubview:label];
        // Do not release the allocated label, as it will be released in Dealloc.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) layoutLabels {
    CGSize nameLabelSize = [nameLabel.text sizeWithFont: nameLabel.font];
    CGSize addrLabelSize = [addressLabel.text sizeWithFont: addressLabel.font];
    
    // position the name first in the content rectangle.
    CGRect nameFrame = self.contentView.bounds;
    nameFrame.size.width = nameLabelSize.width;
    nameFrame.size.height = nameLabelSize.height;
    nameLabel.frame = nameFrame;
    
    // position the address below the name in the cell.
    CGRect addrFrame = self.contentView.bounds;
    addrFrame.origin.y = nameLabelSize.height;
    addrFrame.size.width = addrLabelSize.width;
    addrFrame.size.height = addrLabelSize.height;
    addressLabel.frame = addrFrame;
    
    [nameLabel setNeedsDisplay];
    [addressLabel setNeedsDisplay];
}

- (void)dealloc {
    self.pharmacy = nil;
    [nameLabel release];
    [addressLabel release];
    [super dealloc];
}


#pragma mark Event Handling

///
-(void) observeValueForKeyPath: (NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Pharmacy *p = (Pharmacy *)object;
    if (p != self.pharmacy) {
        return;
    }
    BOOL willChange = [keyPath isEqualToString: nameKey];
    
    if (willChange) {
        // Give preemptive notice to any observers that the tableCell labels will change.
        [self sendNotification: kPharmacyTableCellTextWillUpdateNotification about:self];
    }
    
    // Only need to refresh the first or last name.
    if ([keyPath isEqualToString: nameKey]) {
        nameLabel.text = p.name;
    }
    
    if (willChange) {
        [self layoutLabels];
    }
}

///
-(void) subscribeToPharmacyPropertyChanges: (BOOL)yesNo {
    if (yesNo) {
        [self.pharmacy addPropertyChangeObserver:self];
    }
    else {
        [self.pharmacy removePropertyChangeObserver:self];
    }
}

-(void) sendNotification: (NSString *)notificationName about: (NSObject *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: data];
}

@end
