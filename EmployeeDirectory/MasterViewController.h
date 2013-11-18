//
//  MasterViewController.h
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/18/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
