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
