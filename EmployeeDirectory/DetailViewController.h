//
//  DetailViewController.h
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/12/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Employee *employee;

@property (weak, nonatomic) IBOutlet UIView *listContainer;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *employeePic;
@property (weak, nonatomic) IBOutlet UITableView *actionList;

@end
