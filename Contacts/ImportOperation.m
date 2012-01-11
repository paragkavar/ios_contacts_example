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


#import "ImportOperation.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "UIHelper.h"

@implementation ImportOperation
@synthesize delegate;
@synthesize totalAttempted, totalImported;

- (NSPredicate *) contactsPredicate {
	return nil;
}

- (void) deleteContacts {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    NSError *error = nil;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
	[fetch setPredicate: [self contactsPredicate]];
    NSArray *results = [context executeFetchRequest:fetch error:&error];
    for (id contact in results) [context deleteObject:contact];
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }  
}

- (void) importContacts {
}

- (void) beginImportOperation {
    totalAttempted = 0;
    totalImported = 0;
    
	if (delegate) {
		[((NSObject*)delegate) performSelectorOnMainThread:@selector(didBeginImportOperation) withObject:nil waitUntilDone:NO];
	}
    
	[self deleteContacts];
}

- (void) updatewithProgress: (float) progress {
	if (delegate) {
		NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithFloat:progress];
		[((NSObject*)delegate) performSelectorOnMainThread:@selector(isPerformingImportOperationWithProgress:) withObject:number waitUntilDone:NO];
	}
}

- (void) finishImportOperation {
	if (delegate) {
		[((NSObject*)delegate) performSelectorOnMainThread:@selector(didFinishImportOperation) withObject:nil waitUntilDone:YES];
	}
}

- (void) failImportOperation {
	if (delegate) {
		[((NSObject*)delegate) performSelectorOnMainThread:@selector(didFailImportOperation) withObject:nil waitUntilDone:YES];
	}
}

- (void)request:(OAuthXRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    [UIHelper alertWithTitle:[NSString stringWithFormat: @"Import from %@ failed.", request.service] 
                     message:[NSString stringWithFormat: @"Failed to import contacts from %@. Please check your connection and try again.", request.service] 
                    delegate:self];
}


- (void)main {
	[self importContacts];
}

@end
