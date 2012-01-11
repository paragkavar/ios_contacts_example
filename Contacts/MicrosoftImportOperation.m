//
//  FacebookImportOperation.m
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 4/3/11.
//  Copyright 2011 MobTouch, Inc. . All rights reserved.
//

#import "MicrosoftImportOperation.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation MicrosoftImportOperation

- (NSPredicate *) contactsPredicate {
	return [NSPredicate predicateWithFormat:@"source == 'microsoft'"];
}

- (void) importContacts {
	[self beginImportOperation];
    [self updatewithProgress:0.0];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.oauthx requestService:@"microsoft" withURL:@"https://apis.live.net/v5.0/me/contacts" andDelegate:self];
}

- (void)request:(OAuthXRequest *)request didLoadResponse:(OAuthXResponse *)response {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSInvocationOperation *finalizeImportOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processData:) object:response];
	[appDelegate.operationQueue addOperation:finalizeImportOperation];
}

- (void) processData: (OAuthXResponse *)response {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
	NSError *error = nil;
    
	NSArray *contacts = [response objectForKey:@"data"];
    
	for (int i=0; i<[contacts count]; i++) {
        totalAttempted++;
        
		NSDictionary *contactJSON = [contacts objectAtIndex:i];
        
		Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.source = response.service;
        contact.sourceId = [contactJSON objectForKey:@"id"];
        contact.name = [contactJSON objectForKey:@"name"];
        contact.sectionName = [contact.name substringToIndex:1];
        
        totalImported++;
        if (totalImported % 10 == 0) {
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }    
        }
        
		float progress = i/([contacts count] * 1.0);
		[self updatewithProgress:progress];
	}
	
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    

    [self finishImportOperation];		
}

@end
