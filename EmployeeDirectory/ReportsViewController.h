//
//  ReportsViewController.h
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/17/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportsViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *reports;

@end
