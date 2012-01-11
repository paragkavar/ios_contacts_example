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
