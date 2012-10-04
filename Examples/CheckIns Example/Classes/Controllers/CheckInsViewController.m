//
//  CheckInsViewController.m
//  Read-Write Example
//
//  Created by Mattt Thompson on 2012/10/04.
//  Copyright (c) 2012年 AFNetworking. All rights reserved.
//

#import "CheckInsViewController.h"

#import "CheckIn.h"

#import "AFIncrementalStore.h"

@interface CheckInsViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}
@end


@implementation CheckInsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CheckIns", nil);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CheckIn"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.includesPendingChanges = NO;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    [_fetchedResultsController performFetch:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refetchData:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserverForName:AFIncrementalStoreContextDidFetchRemoteValues object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.refreshControl endRefreshing];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(checkIn:)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - IBAction

- (void)refetchData:(id)sender {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

- (void)checkIn:(id)sender {
    CheckIn *checkIn = [[CheckIn alloc] initWithTimestamp:[NSDate date] inManagedObjectContext:_fetchedResultsController.managedObjectContext];
    
    [_fetchedResultsController.managedObjectContext insertObject:checkIn];
    
    NSError *error = nil;
    if (![_fetchedResultsController.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CheckIn *checkIn = (CheckIn *)[_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[checkIn timestamp] description];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CheckIn *checkIn = (CheckIn *)[_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Checkin: %@", checkIn);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end