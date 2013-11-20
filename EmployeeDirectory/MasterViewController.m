//
//  MasterViewController.m
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/12/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Employee.h"


@interface MasterViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *employees;
@property (strong, nonatomic) NSArray *filteredEmployees;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error;
    self.employees = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.searchFetchRequest = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        return [self.employees count];
    } else {
        return [self.filteredEmployees count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Employee *employee = nil;
    if (tableView == self.tableView)
    {
        employee = [self.employees objectAtIndex:indexPath.row];
    }
    else
    {
        employee = [self.filteredEmployees objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", employee.firstName, employee.lastName];
    cell.detailTextLabel.text = employee.title;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Employee *employee = nil;
    if (self.searchDisplayController.isActive)
    {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        employee = [self.filteredEmployees objectAtIndex:indexPath.row];
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        employee = [self.employees objectAtIndex:indexPath.row];
    }

    DetailViewController *detailVC = [segue destinationViewController];

    detailVC.managedObjectContext = self.managedObjectContext;
    detailVC.employee = employee;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchForText:searchString];
    return YES;
}

- (void)searchForText:(NSString *)searchText
{
    
    NSLog(@"Search for text %@", searchText);
    
    if (self.managedObjectContext)
    {
        NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
        NSString *searchAttribute = @"lastName";
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
        [self.searchFetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        self.filteredEmployees = [self.managedObjectContext executeFetchRequest:self.searchFetchRequest error:&error];
        NSLog(@"search results: %lu", (unsigned long)[self.filteredEmployees count]);
    }
}


- (NSFetchRequest *)searchFetchRequest
{
    if (_searchFetchRequest != nil)
    {
        return _searchFetchRequest;
    }
    
    _searchFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
    [_searchFetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [_searchFetchRequest setSortDescriptors:sortDescriptors];
    
    return _searchFetchRequest;
}

@end
