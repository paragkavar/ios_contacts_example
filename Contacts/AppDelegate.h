//
//  AppDelegate.h
//  Contacts
//
//  Created by Michael Berkovich on 1/10/12.
//  Copyright (c) 2012 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthXSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSString *photosPath_;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property(nonatomic, retain) OAuthX *oauthx;
@property(nonatomic, retain) NSOperationQueue *operationQueue;

- (NSString *) photosPath;

@end
