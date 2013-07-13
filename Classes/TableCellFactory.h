//
//  TableCellFactory.h
//  CurbSide
//
//  Created by Greg Walker on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientTableViewCell.h"
#import "PharmacyTableViewCell.h"
#import "ApplicationSupervisor.h"


@interface TableCellFactory : NSObject {

}

///
+(UITableViewCell *) createEditableTextCellForTable: (UITableView *)tableView 
                                     withIdentifier: (NSString *)reuseIdentifier 
                                       withDelegate: (id<UITextFieldDelegate>)delegate 
                                   withKeyboardType: (UIKeyboardType)keyboardType
                                  withReturnKeyType: (UIReturnKeyType)returnKeyType
                             withCapitalizationType: (UITextAutocapitalizationType)capsType
                                            withTag: (NSInteger)tag 
                                         withIndent: (NSInteger)indent
                                         firstLabel: (NSString *)description 
                                        secondLabel: (NSString *)text;

///
+(UITableViewCell *) createImmutableDoubleLabelCellForTable: (UITableView *)tableView 
                                              withIdentifier: (NSString *)reuseIdentifier 
                                                     withTag: (NSInteger)tag 
                                           withAccessoryType: (UITableViewCellAccessoryType)accessoryType
                                               withCellStyle: (UITableViewCellStyle)cellStyle
                                                  firstLabel: (NSString *)label1 
                                                 secondLabel: (NSString *)label2;

///
+(UITableViewCell *) createImmutableDoubleLabelCellForTable: (UITableView *)tableView 
                                             withIdentifier: (NSString *)reuseIdentifier
                                                    withTag: (NSInteger)tag 
                                          withAccessoryType: (UITableViewCellAccessoryType)accessoryType
                                              withCellStyle: (UITableViewCellStyle)cellStyle
                                          withImageFilePath: (NSString *)imagePath
                                                 firstLabel: (NSString *)label1 
                                                secondLabel: (NSString *)label2;

/**
 */
+(UITableViewCell *) createAdditionPlaceHolderCellForTable: (UITableView *)tableView 
                                            withIdentifier: (NSString *)reuseIdentifier
                                                firstLabel: (NSString *)label1;
/**
 */
+(UITableViewCell *) createHistoryCellForTable: (UITableView *)tableView 
                                 withIdentifier: (NSString *)reuseIdentifier
                                       withTag: (NSInteger)tag
                                    firstLabel: (NSString *)label1 
                                   secondLabel: (NSString *)label2;
/**
 */
+(PatientTableViewCell *) createSortablePatientCellForTable: (UITableView *)tableView 
                                             withIdentifier: (NSString *)reuseIdentifier
                                                    withTag: (NSInteger)tag;
/**
 */
+(PatientTableViewCell *) createEmphasizedPatientCellForTable: (UITableView *)tableView
                                               withEmphasisOn: (NSString *)substring 
                                               withIdentifier: (NSString *)reuseIdentifier
                                                      withTag: (NSInteger)tag;

+(PharmacyTableViewCell *) createPharmacyCellForTable: (UITableView *)tableView
                                       withIdentifier: (NSString *)reuseIdentifier
                                              withTag: (NSInteger)tag;

@end
