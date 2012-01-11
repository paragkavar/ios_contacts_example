//
//  ContactMO.h
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 3/28/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OAuthXSDK.h"
#import <CoreData/CoreData.h>

@protocol ContactDelegate;

@interface Contact : NSManagedObject <OAuthXRequestDelegate> {
    
}

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * sourceId;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * imageName;

@property(assign) id <ContactDelegate> delegate;
@property(nonatomic, retain) NSIndexPath *imageIndexPath;
@property (nonatomic, retain) OAuthXRequest *imageRequest;

- (void) saveMugshotImage: (UIImage *) image;
- (void) downloadMugshotImageFromUrl: (NSString *) url locked:(BOOL) locked;

- (UIImage *) mugshotImage;
- (void) downloadImageForIndexPath: (NSIndexPath *) indexPath delegate: (id <ContactDelegate>) newDelegate;
- (void) cancelImageDownload;

@end


@protocol ContactDelegate<NSObject>

@optional

-(void) contact:(Contact *)contact didFinishLoadingImage:(UIImage *) image forIndexPath:(NSIndexPath *) indexPath;
-(void) contact:(Contact *)contact didFinishLoadingWithNoImageAvailableForIndexPath:(NSIndexPath *) indexPath;

@end
