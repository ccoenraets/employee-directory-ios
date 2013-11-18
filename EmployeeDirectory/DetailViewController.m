//
//  DetailViewController.m
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/12/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import "DetailViewController.h"
#import "Employee.h"
#import "ReportsViewController.h"

@interface DetailViewController ()
@property NSMutableArray *actions;
- (void)configureView;
@end

@implementation DetailViewController {
    //    NSMutableArray *actions;
    Employee *manager;
    NSArray *reports;
}

@synthesize employee;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - Managing the detail item

//- (void)setEmployee:(Employee*)newEmployee
//{
//    if (employee != newEmployee) {
//        employee = newEmployee;
//
//        // Update the view.
//        [self configureView];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer hiding the empty Table View cells
    return 0.01f;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    self.actionList.dataSource = self;
    self.actionList.delegate = self;
    
    if (self.employee) {
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
        
        // Find the direct reports
        NSFetchRequest *reportsRequest = [[NSFetchRequest alloc] init];
        [reportsRequest setEntity:entityDescription];
        
        NSPredicate *reportsPredicate = [NSPredicate predicateWithFormat:@"managerId == %@", self.employee.id];
        [reportsRequest setPredicate:reportsPredicate];
        
        NSError *error;
        reports = [_managedObjectContext executeFetchRequest:reportsRequest error:&error];
        
        // Find the manager
        if ([employee.managerId intValue] > 0) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", employee.managerId];
            [request setPredicate:predicate];
            
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            if (array != nil) {
                manager = [array objectAtIndex:0];
                NSLog(@"found employee %@", manager.lastName);
            }
        }
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.employee.firstName, self.employee.lastName];
        self.titleLabel.text = self.employee.title;
        [self.employeePic setImage:[UIImage imageNamed:self.employee.picture]];
        _actions = [[NSMutableArray alloc] init];
        
        NSDictionary *callOffice = [NSDictionary dictionaryWithObjectsAndKeys:@"Call Office", @"label", self.employee.officePhone, @"data", @"call", @"command", nil];
        [self.actions addObject:callOffice];
        
        NSDictionary *callCell = [NSDictionary dictionaryWithObjectsAndKeys:@"Call Cell", @"label", self.employee.cellPhone, @"data", @"call", @"command", nil];
        [self.actions addObject:callCell];
        
        NSDictionary *sms = [NSDictionary dictionaryWithObjectsAndKeys:@"SMS", @"label", self.employee.cellPhone, @"data", @"sms", @"command", nil];
        [self.actions addObject:sms];
        
        NSDictionary *email = [NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"label", self.employee.email, @"data", @"email", @"command", nil];
        [self.actions addObject:email];
        
        
        if ([employee.managerId intValue] > 0) {
            NSDictionary *mgr = [NSDictionary dictionaryWithObjectsAndKeys:@"View Manager", @"label", [NSString stringWithFormat:@"%@ %@", manager.firstName, manager.lastName], @"data", @"mgr", @"command", nil];
            [self.actions addObject:mgr];
        }
        
        if ([reports count] > 0) {
            NSDictionary *reportsAction = [NSDictionary dictionaryWithObjectsAndKeys:@"View Reports", @"label", [NSString stringWithFormat:@"%d", [reports count]], @"data", @"reports", @"command", nil];
            [self.actions addObject:reportsAction];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [_actions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *action = [_actions objectAtIndex:[indexPath row]];
    cell.textLabel.text = [action valueForKey:@"label"];
    cell.detailTextLabel.text = [action valueForKey:@"data"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *action = [_actions objectAtIndex:[indexPath row]];
    
    NSString *command = [action valueForKey:@"command"];
    NSString *data = [action valueForKey:@"data"];
    
    if ([command isEqualToString:@"call"]) {
        NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@",data];
        NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
        [[UIApplication sharedApplication] openURL:phoneURL];
        
    } else if ([command isEqualToString:@"sms"]) {
        
    } else if ([command isEqualToString:@"email"]) {
        NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@",
                                [data stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
    } else if ([command isEqualToString:@"mgr"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        DetailViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"EmployeeVC"];
        dest.employee = manager;
        [self.navigationController pushViewController:dest animated:YES];
    } else if ([command isEqualToString:@"reports"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ReportsViewController *reportsVC = [storyboard instantiateViewControllerWithIdentifier:@"ReportsVC"];
        reportsVC.reports = reports;
        [self.navigationController pushViewController:reportsVC animated:YES];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EmployeeDirectory" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EmployeeDirectory.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
