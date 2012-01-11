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


#import "GoogleImportOperation.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation GoogleImportOperation

- (NSPredicate *) contactsPredicate {
	return [NSPredicate predicateWithFormat:@"source == 'google'"];
}

- (void) importContacts {
	[self beginImportOperation];
    [self updatewithProgress:0.0];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"json",                 @"alt",    
                                   @"5000",                 @"max-results",  
                                   nil];
	[appDelegate.oauthx requestService:@"google" withURL:@"https://www.google.com/m8/feeds/contacts/default/full" andParams:params andDelegate:self];
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
    
	NSArray *contacts = [[response objectForKey:@"feed"] objectForKey:@"entry"];
    
	for (int i=0; i<[contacts count]; i++) {
        totalAttempted++;
        
		NSDictionary *contactJSON = [contacts objectAtIndex:i];
        
        NSString *googleId = [[contactJSON objectForKey:@"id"] objectForKey:@"$t"];
        googleId = (NSString *) [[googleId componentsSeparatedByString:@"/"] lastObject];
        NSString *name = [[contactJSON objectForKey:@"title"] objectForKey:@"$t"];

        NSArray *links = [contactJSON objectForKey:@"link"];
        NSString *imageUrl = nil;
        
        for (NSDictionary *link in links) {
            if ([[link objectForKey:@"type"] isEqualToString:@"image/*"])
                imageUrl = [link objectForKey:@"href"];
        }
        
        NSString *contactUrl = [NSString stringWithFormat:@"https://mail.google.com/mail/?shva=1#contact/%@", googleId];
        
        if (name == nil || [name isEqualToString:@""]) continue;
            
        NSLog(@"Inserting %d - %@", totalAttempted, name);
        
		Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.source = response.service;
        contact.sourceId = googleId;
        contact.name = name;
        contact.url = contactUrl;
        contact.sectionName = [contact.name substringToIndex:1];
		
        //		NSDictionary *imagesJSON = [profileJSON objectForKey:@"mugshot_urls"];
        //		[profile setValue:[imagesJSON objectForKey:@"large"] forKey:@"imageUrl"];
        
//        if (imageUrl) {
//            OAuthXToken *token = [appDelegate.oauthX tokenForService:@"google"];
//            imageUrl = [NSString stringWithFormat:@"%@&oauth_token=%@", imageUrl, token.accessToken];
//            [contact downloadMugshotImageFromUrl:imageUrl locked: YES];
//        }
		
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
