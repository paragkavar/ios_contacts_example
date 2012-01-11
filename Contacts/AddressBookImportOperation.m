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


#import "AddressBookImportOperation.h"
#import <AddressBook/AddressBook.h>
#import "AppDelegate.h"
#import "Contact.h"

@implementation AddressBookImportOperation

- (NSPredicate *) contactsPredicate {
	return [NSPredicate predicateWithFormat:@"source == 'address_book'"];
}

- (void) importContacts {
	[self beginImportOperation];
	totalAttempted = 0;
    totalImported = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    NSError *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for (int i=0; i<[allContacts count]; i++) {
        totalAttempted++;
        
        ABRecordRef contactRef = (__bridge ABRecordRef)[allContacts objectAtIndex:i];
        NSInteger contactId = (NSInteger) ABRecordGetRecordID(contactRef);
        
        NSString *name = nil;
        
        CFNumberRef contactType = ABRecordCopyValue(contactRef, kABPersonKindProperty);
        if (contactType == kABPersonKindPerson) {
            name = (__bridge NSString *) ABRecordCopyCompositeName(contactRef);
        } else if (contactType == kABPersonKindOrganization) {
            name = (__bridge NSString *) ABRecordCopyValue(contactRef, kABPersonOrganizationProperty);
        }
        CFRelease(contactType);
        
        if (!name || [name isEqualToString:@""]) continue;    
        
        Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.source = @"address_book";
        contact.sourceId = [NSString stringWithFormat:@"%d", contactId];
        contact.name = name;
        contact.sectionName = [contact.name substringToIndex:1];
        
        UIImage *image = nil;
        if (ABPersonHasImageData(contactRef)) {
            image = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(contactRef)];
        } else { 
            image = [UIImage imageNamed:@"contact.jpg"];
        }

        [contact saveMugshotImage:image];    

        totalImported++;
        if (totalImported % 10 == 0) {
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }    
        }
        
		[self updatewithProgress:(i / ([allContacts count] * 1.0))];
        CFRelease(contactRef);
    }
    
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }  
    
	[self finishImportOperation];
}

@end
