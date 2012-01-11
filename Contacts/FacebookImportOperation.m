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


#import "FacebookImportOperation.h"
#import "AppDelegate.h"
#import "Contact.h"

@implementation FacebookImportOperation

@synthesize userId;

- (NSPredicate *) contactsPredicate {
	return [NSPredicate predicateWithFormat:@"source == 'facebook'"];
}

- (void) getUserInfo {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	fbMode = FacebookModeGetUserInfo;
	[appDelegate.oauthx requestService:@"facebook" withURL:@"https://graph.facebook.com/me" andDelegate:self];
}

- (void) importFriends {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    fbMode = FacebookModeImportFriendsBirthdays;
	NSString *query = [NSString stringWithFormat:@"select uid, name, pic_big, profile_url from user where uid in (select uid1 from friend where uid2=%@)", self.userId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: query, @"query", @"json", @"format", @"ios", @"sdk", @"2", @"sdk_version", nil];
	[appDelegate.oauthx requestService:@"facebook" withURL:@"https://api.facebook.com/method/fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void) importContacts {
	[self beginImportOperation];
    
    if (self.userId == nil) {
		[self getUserInfo];
        return;
    }
    
    [self updatewithProgress:0.3];
	[self importFriends];
}

- (void) request: (OAuthXRequest *)request didLoadResponse: (OAuthXResponse *)response {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (fbMode == FacebookModeGetUserInfo) {
        self.userId = [response objectForKey:@"id"];
		[self updatewithProgress:0.1];
		[self importFriends];
        return;         
    }
	
    if (fbMode == FacebookModeImportFriendsBirthdays) {
		NSInvocationOperation *finalizeImportOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processFriends:) object:response];
		[appDelegate.operationQueue addOperation:finalizeImportOperation];
		return;
    }
}

- (void) processFriends: (OAuthXResponse *) response {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    
    NSArray *friends = [response results];
	NSError *error = nil;
	for (int i=0; i<[friends count]; i++) {
        totalAttempted++;
        
		NSDictionary *friend = (NSDictionary *) [friends objectAtIndex:i];
        
		Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.source = response.service;
        contact.sourceId = [NSString stringWithFormat:@"%d", [[friend objectForKey:@"uid"] intValue]];
        contact.name = [friend objectForKey:@"name"];
        contact.url = [friend objectForKey:@"profile_url"];
        contact.sectionName = [contact.name substringToIndex:1];

        if ([friend objectForKey:@"pic_big"] != nil && ![[friend objectForKey:@"pic_big"] isEqualToString:@""])  {
            contact.imageUrl = [friend objectForKey:@"pic_big"];
        }
                
        totalImported++;
        
        if (totalImported % 10 == 0) {
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }    
        }
        
		float progress = i/([friends count] * 1.0) * 0.9;
		NSLog(@"%@", [friend objectForKey:@"name"]);
		[self updatewithProgress:(0.1 + progress)];
	}
    
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}    
	
	[self finishImportOperation];	
}

@end
