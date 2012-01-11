//
//  ImportOperation.m
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 3/30/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

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
