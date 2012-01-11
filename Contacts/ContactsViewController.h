//
//  RootViewController.h
//  Contacts
//
//  Created by Michael Berkovich on 8/13/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "Contact.h"
#import "ImportOperation.h"
#import "OAuthXSDK.h"

@interface ContactsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, ContactDelegate, ImportOperationDelegate, OAuthXSessionDelegate> {
}

@property(nonatomic, retain) NSMutableDictionary *downloadingPictures;

@property(nonatomic, retain) IBOutlet UIView *loadingView;
@property(nonatomic, retain) IBOutlet UIProgressView *loadingProgressView;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property(nonatomic, retain) ImportOperation *importOperation;

@end
