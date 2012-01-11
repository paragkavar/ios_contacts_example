//
//  FacebookImportOperation.h
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 4/3/11.
//  Copyright 2011 MobTouch, Inc. . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportOperation.h"
#import "Contact.h"

typedef enum {
    FacebookModeNone,
    FacebookModeGetUserInfo,
    FacebookModeImportFriendsBirthdays
} FacebookMode;

@interface FacebookImportOperation : ImportOperation <OAuthXRequestDelegate> {
    FacebookMode fbMode;
}

@property(nonatomic, retain) NSString* userId;

@end
