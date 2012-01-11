//
//  ImportOperation.h
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 3/30/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthX.h"

@protocol ImportOperationDelegate;

@interface ImportOperation : NSOperation {
    NSInteger totalAttempted;
    NSInteger totalImported;
}

@property(nonatomic, assign) id <ImportOperationDelegate> delegate;

@property(nonatomic, readonly) NSInteger totalAttempted;
@property(nonatomic, readonly) NSInteger totalImported;

- (void) deleteContacts;
- (NSPredicate *)contactsPredicate;
- (void) importContacts;

- (void) beginImportOperation;
- (void) updatewithProgress: (float) progress;
- (void) finishImportOperation;
- (void) failImportOperation;

@end

@protocol ImportOperationDelegate<NSObject>

- (void) didBeginImportOperation;
- (void) isPerformingImportOperationWithProgress:(NSDecimalNumber*) progress;
- (void) didFinishImportOperation;
- (void) didFailImportOperation;

@end
