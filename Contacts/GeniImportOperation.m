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


#import "GeniImportOperation.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation GeniImportOperation

- (NSPredicate *) contactsPredicate {
	return [NSPredicate predicateWithFormat:@"source == 'geni'"];
}

- (void) importContacts {
	[self beginImportOperation];
    [self updatewithProgress:0.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    geniMode = GeniModeImportFamilyBirthdays;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"1",                 @"only_list",    
                                   @"id,name,mugshot_urls,birth_date_parts,url,relationship,guid", @"fields",
                                   nil];
    [appDelegate.oauthx requestService:@"geni" withURL:@"https://www.geni.com/api/user/max-family" andParams:params andDelegate:self];
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
    
	NSArray *family = [response objectForKey:@"results"];
	for (int i=0; i<[family count]; i++) {
        totalAttempted++;
        
		NSDictionary *relative = [family objectAtIndex:i];
        
		Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.source = response.service;
        contact.sourceId = [relative objectForKey:@"id"];
        contact.name = [relative objectForKey:@"name"];
        contact.sectionName = [contact.name substringToIndex:1];
		contact.url = [NSString stringWithFormat:@"http://www.geni.com/profile/index?id=%@", [relative objectForKey:@"guid"]];

		NSDictionary *imagesJSON = [relative objectForKey:@"mugshot_urls"];
        if ([imagesJSON objectForKey:@"large"] != nil && ![[imagesJSON objectForKey:@"large"] isEqualToString:@""]) {
            contact.imageUrl = [imagesJSON objectForKey:@"large"];
        }
        
        totalImported++;
        if (totalImported % 10 == 0) {
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }    
        }
        
		float progress = i/([family count] * 1.0);
		NSLog(@"%@", [relative objectForKey:@"name"]);
        
		[self updatewithProgress:progress];
	}
	
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
	
	NSString *nextPageUrl = [response nextPageURL];
	if (nextPageUrl != nil) {
		[self updatewithProgress:0];
		[self performSelectorOnMainThread:@selector(loadNextPage:) withObject:response waitUntilDone:YES];
	} else {
		[self finishImportOperation];		
	}
}

- (void) loadNextPage: (OAuthXResponse *)response {
	NSString *nextPageUrl = [response nextPageURL];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.oauthx requestService:response.service withURL:nextPageUrl andDelegate:self];
}

@end
