//
//  GeniImportOperation.h
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 4/21/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportOperation.h"

typedef enum {
    GeniModeNone,
    GeniModeImportFamilyBirthdays
} GeniMode;

@interface GeniImportOperation : ImportOperation <OAuthXRequestDelegate> {
    GeniMode geniMode;
}

@end
