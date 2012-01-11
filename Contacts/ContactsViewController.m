/*
 * Copyright 2011-2012 OAuthX
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "ContactsViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "ContactTableViewCell.h"

#import "AddressBookImportOperation.h"
#import "GeniImportOperation.h"
#import "FacebookImportOperation.h"
#import "GoogleImportOperation.h"
#import "MicrosoftImportOperation.h"

#import "UIHelper.h"

@interface ContactsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) importContactsFromAddressBook;
- (void) importContactsFromService: (NSString *) service;
- (void) loadImagesForOnscreenRows;
@end

@implementation ContactsViewController

@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize tableView=_tableView;
@synthesize loadingView, loadingProgressView, importOperation;
@synthesize downloadingPictures;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Contacts";
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStyleBordered target:self action:@selector(importContacts:)];
    self.navigationItem.leftBarButtonItem = importButton;
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadImagesForOnscreenRows];
}

- (IBAction) importContacts: (id) sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Import Contacts" delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle: NULL 
                                                    otherButtonTitles: @"From Address Book", @"From Facebook", @"From Google", @"From Hotmail", @"From Geni", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Address Book"]) {
        [self importContactsFromAddressBook];
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Facebook"]) {
        [self importContactsFromService:@"facebook"];
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Google"]) {
        [self importContactsFromService:@"google"];
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Hotmail"]) {
        [self importContactsFromService:@"microsoft"];
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Geni"]) {
        [self importContactsFromService:@"geni"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactTableViewCell";

    ContactTableViewCell *cell = (ContactTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)configureCell:(ContactTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.nameLabel setText:[contact valueForKey:@"name"]];
    cell.sourceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", contact.source]];
    [cell.infoLabel setText:[NSString stringWithFormat:@"Imported from %@", contact.source]];
    
    UIImage *image = [contact mugshotImage];
    if (image != nil) {
        [cell updateWithImage:image];
    } else {
        [cell markAsLoading];
    }
}

-(void) contact:(Contact *)contact didFinishLoadingImage:(UIImage *) image forIndexPath:(NSIndexPath *) indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateWithImage: image];
    [downloadingPictures removeObjectForKey:[NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row]];
}

-(void) contact:(Contact *)contact didFinishLoadingWithNoImageAvailableForIndexPath:(NSIndexPath *) indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateWithNoImage];
    [downloadingPictures removeObjectForKey:[NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row]];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"sectionName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *sections = [self.fetchedResultsController sections];
    NSMutableArray *sectionIndex = [NSMutableArray array];
    for (id <NSFetchedResultsSectionInfo> sectionInfo in sections) {
        [sectionIndex addObject:[sectionInfo name]];
    }
    
    return sectionIndex;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

-(void) reload {
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    for (Contact *c in [downloadingPictures allValues]) {
        [c cancelImageDownload];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

- (void) loadImagesForOnscreenRows {
    NSFetchedResultsController *frs = self.fetchedResultsController;
    if (frs == nil) return;
    
    if (downloadingPictures == nil) 
        self.downloadingPictures = [NSMutableDictionary dictionary];
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        Contact *contact = [frs objectAtIndexPath:indexPath];
        UIImage *image = [contact mugshotImage];
        if (image == nil) {
            [downloadingPictures setValue:contact forKey:[NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row]];
            [contact downloadImageForIndexPath:indexPath delegate:self];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// IMPORT OPERATION DELEGATION
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void) didBeginImportOperation {
	NSLog(@"Began importing...");
    
	self.loadingView.hidden = NO;
	[self.view bringSubviewToFront:self.loadingView];
	self.loadingProgressView.progress = 0.0;
	[self.loadingProgressView setNeedsDisplay];
}

- (void) isPerformingImportOperationWithProgress:(NSDecimalNumber*) progress {
	self.loadingProgressView.progress = [progress floatValue];
	[self.loadingProgressView setNeedsDisplay];
}

- (void) didFinishImportOperation {
	NSLog(@"Finished importing...");
	self.loadingProgressView.progress = 1.0;
	[self.loadingProgressView setNeedsDisplay];
	self.loadingView.hidden = YES;
    [self reload];
    
    if ([importOperation totalImported] > 0) {
        [UIHelper alertWithTitle: @"Import Completed" 
                         message:[NSString stringWithFormat:@"Imported %d out of %d contacts.", [importOperation totalImported],[importOperation totalAttempted]]
                        delegate:self];
    }
}

- (void) didFailImportOperation {
	self.loadingView.hidden = YES;
    [self reload];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// ADDRESS BOOK
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void) importContactsFromAddressBook {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
	self.importOperation = [[AddressBookImportOperation alloc] init];
	self.importOperation.delegate = self;
    
	[appDelegate.operationQueue addOperation:importOperation];	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// OAuthX SDK
///////////////////////////////////////////////////////////////////////////////////////////////////

- (ImportOperation *) operationForService: (NSString *) service {
    if ([service isEqualToString:@"geni"]) {
        return [[GeniImportOperation alloc] init];
    }
    
    if ([service isEqualToString:@"facebook"]) {
        return [[FacebookImportOperation alloc] init];
    }
    
    if ([service isEqualToString:@"google"]) {
        return [[GoogleImportOperation alloc] init];
    }
    
    if ([service isEqualToString:@"microsoft"]) {
        return [[MicrosoftImportOperation alloc] init];
    }
    
    return nil;
}

- (void) importContactsFromService: (NSString *) service {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if (![appDelegate.oauthx isAccessTokenValidForService:service]) {
        [appDelegate.oauthx authorizeService:service delegate:self];    
        return;
    }
	
	self.importOperation = [self operationForService:service];
	self.importOperation.delegate = self;
	[self.importOperation importContacts];
}

- (void) oauthXDidLoginToService:(NSString *)service {
    [self importContactsFromService: service];
}

@end
