//
//  TableCellFactory.m
//  CurbSide
//
//  Created by Greg Walker on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableCellFactory.h"

@implementation TableCellFactory


/**
 */
+(UITableViewCell *) createEditableTextCellForTable: (UITableView *)tableView 
                                     withIdentifier: (NSString *)reuseIdentifier 
                                       withDelegate: (id<UITextFieldDelegate>)delegate 
                                   withKeyboardType: (UIKeyboardType)keyboardType
                                  withReturnKeyType: (UIReturnKeyType)returnKeyType
                             withCapitalizationType: (UITextAutocapitalizationType)capsType
                                            withTag: (NSInteger)tag
                                         withIndent: (NSInteger)indent
                                         firstLabel: (NSString *)description 
                                        secondLabel: (NSString *)text {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    UITextField *textField = nil;
    if (cell == nil) {
        // Create a new cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:reuseIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Not sure why the width between tables is like this.  This fixes sizing difference when
        // TableView (x-orig,x-width) is (0,320) versus (11,298).
        NSInteger xOrig = tableView.frame.origin.x;
        NSInteger width = tableView.frame.size.width + xOrig;
        if (xOrig == 0) {
            width -= indent;
        }
        // Calculate the desired frame for the embedded TextView.
        CGRect fieldFrame = CGRectMake(indent, (tableView.rowHeight - 31) / 2, width, 31);
        textField = [[UITextField alloc] initWithFrame: fieldFrame];
        // Set up a new TextField for cell editing
        textField.adjustsFontSizeToFitWidth = YES;
        // This is crucial to let the TextField resize when the cell width is set.
        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        textField.keyboardType = keyboardType;
        textField.textColor = [UIColor blackColor];
        textField.returnKeyType = returnKeyType;
        textField.backgroundColor = [UIColor clearColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo; 
        textField.autocapitalizationType = capsType;
        textField.textAlignment = UITextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = [UIFont systemFontOfSize:15];
        textField.clipsToBounds = YES;
        textField.autoresizesSubviews = YES;
        [textField setEnabled: YES];
        
        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [cell.contentView addSubview:textField];
        
        [textField release];
    }
    else {
        // Reuse an existing cell
        for (UIView *view in [cell.contentView subviews]) {
            if ([view isKindOfClass: [UITextField class]]) {
                textField = (UITextField *)view;
                break;
            } 
        }
    }
    
    if (textField) {
        textField.placeholder = description;
        textField.text = text;
        textField.delegate = delegate;
        textField.tag = tag;
    }
    
    return cell;
}

/// Create an cell with two immutable labels.
+(UITableViewCell *) createImmutableDoubleLabelCellForTable: (UITableView *)tableView 
                                              withIdentifier: (NSString *)reuseIdentifier
                                                     withTag: (NSInteger)tag 
                                           withAccessoryType: (UITableViewCellAccessoryType)accessoryType
                                               withCellStyle: (UITableViewCellStyle)cellStyle
                                                  firstLabel: (NSString *)label1 
                                                 secondLabel: (NSString *)label2 {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Create a new cell
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier] autorelease];
        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    cell.accessoryType = accessoryType;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cellStyle == UITableViewCellStyleSubtitle) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize: 15];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize: 15];
    }
    cell.textLabel.text = label1;
    //cell.textLabel.textColor = [UIColor blueColor];
    cell.contentView.tag = tag;
    
    if (cellStyle != UITableViewCellStyleDefault) {
        if (cellStyle == UITableViewCellStyleSubtitle) {
            cell.detailTextLabel.font = [UIFont systemFontOfSize: 14];
        }
        else {
            cell.detailTextLabel.font = [UIFont boldSystemFontOfSize: 15];
        }
        cell.detailTextLabel.text = label2;
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

/// Create a cell with an image and two immutable labels.
+(UITableViewCell *) createImmutableDoubleLabelCellForTable: (UITableView *)tableView 
                                             withIdentifier: (NSString *)reuseIdentifier
                                                    withTag: (NSInteger)tag 
                                          withAccessoryType: (UITableViewCellAccessoryType)accessoryType
                                              withCellStyle: (UITableViewCellStyle)cellStyle
                                          withImageFilePath: (NSString *)imagePath
                                                 firstLabel: (NSString *)label1 
                                                secondLabel: (NSString *)label2 {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Create a new cell
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier] autorelease];
        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    cell.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    cell.accessoryType = accessoryType;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cellStyle == UITableViewCellStyleSubtitle) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize: 15];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize: 15];
    }
    cell.textLabel.text = label1;
    cell.contentView.tag = tag;
    
    if (cellStyle != UITableViewCellStyleDefault) {
        if (cellStyle == UITableViewCellStyleSubtitle) {
            cell.detailTextLabel.font = [UIFont systemFontOfSize: 14];
        }
        else {
            cell.detailTextLabel.font = [UIFont boldSystemFontOfSize: 15];
        }
        cell.detailTextLabel.text = label2;
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

/**
 */
+(UITableViewCell *) createAdditionPlaceHolderCellForTable: (UITableView *)tableView 
                                      withIdentifier: (NSString *)reuseIdentifier
                                          firstLabel: (NSString *)label1 {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Create a new cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier] autorelease];
        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize: 15];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = label1;
    cell.contentView.tag = -1;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.text = @"";
    
    return cell;
}

/**
 */
+(UITableViewCell *) createHistoryCellForTable: (UITableView *)tableView 
                                 withIdentifier: (NSString *)reuseIdentifier
                                       withTag: (NSInteger)tag
                                    firstLabel: (NSString *)label1 
                                   secondLabel: (NSString *)label2 {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: reuseIdentifier] autorelease];
        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    cell.textLabel.text = label1;
    cell.detailTextLabel.text = label2;
    cell.contentView.tag = tag;
    // All the rows should show the disclosure indicator
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/**
 */
+(PatientTableViewCell *) createSortablePatientCellForTable: (UITableView *)tableView 
                                             withIdentifier: (NSString *)reuseIdentifier
                                                    withTag: (NSInteger)tag {
    PatientTableViewCell *cell = (PatientTableViewCell *)[tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (cell == nil) {
        cell = [[[PatientTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier andFontSize:20] autorelease];
    }
    
    cell.contentView.tag = tag;
    // All the rows should show the disclosure indicator
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/**
 */
+(PatientTableViewCell *) createEmphasizedPatientCellForTable: (UITableView *)tableView
                                               withEmphasisOn: (NSString *)substring
                                               withIdentifier: (NSString *)reuseIdentifier
                                                      withTag: (NSInteger)tag {
    PatientTableViewCell *cell = (PatientTableViewCell *)[tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (cell == nil) {
        cell = [[[PatientTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier andFontSize:14] autorelease];
    }
    
    cell.contentView.tag = tag;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Set the cell name emphasis value based on user settings.
    switch ([ApplicationSupervisor instance].nameSortOrderSetting) {
        case ORDER_BY_LAST_NAME:
            cell.emphasisOnLastName = YES;
            break;
        case ORDER_BY_FIRST_NAME:
            cell.emphasisOnLastName = NO;
            break;
        default:
            cell.emphasisOnLastName = NO;
            break;
    }
    
    return cell;
}

/**
 */
+(PharmacyTableViewCell *) createPharmacyCellForTable: (UITableView *)tableView
                                       withIdentifier: (NSString *)reuseIdentifier
                                              withTag: (NSInteger)tag {
    PharmacyTableViewCell *cell = (PharmacyTableViewCell *)[tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (cell == nil) {
        cell = [[[PharmacyTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier andFontSize:14] autorelease];
    }
    
    cell.contentView.tag = tag;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


@end
