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

#import "Contact.h"
#import "AppDelegate.h"

@implementation Contact
@synthesize delegate, imageIndexPath, imageRequest;

@dynamic url;
@dynamic imageUrl;
@dynamic imageName;
@dynamic name;
@dynamic sectionName;
@dynamic source;
@dynamic sourceId;

- (UIImage *) mugshotImage {
    if (self.imageUrl == nil)
        return [UIImage imageNamed:@"mugshot.gif"];

    if (self.imageName == nil)
        return nil;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *filePath = [[appDelegate photosPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.imageName]];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

- (UIImage *) scaleAndRotateImage:(UIImage *) image {
	int kMaxResolution = 800; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

- (NSString*)stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	NSString *uuidString = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}

- (void) saveMugshotImage: (UIImage *) image {
    if (image == nil) {
        [self setValue:nil forKey:@"imageName"];
        return;
    }
    
    UIImage *scaledImage = [self scaleAndRotateImage: image];
    
    NSString *imageName = [self stringWithUUID];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    
    NSString *filePath = [[appDelegate photosPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", imageName]];
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0);
    [imageData writeToFile:filePath atomically:YES];
    [self setValue:imageName forKey:@"imageName"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }  
}

- (void) downloadImageForIndexPath: (NSIndexPath *) indexPath delegate: (id <ContactDelegate>) newDelegate {
    if ([self mugshotImage] != nil) return;

    self.delegate = newDelegate;
    self.imageIndexPath = indexPath;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.imageRequest = [appDelegate.oauthx requestService: self.source 
                                                   withURL: self.imageUrl
                                                 andParams: [NSMutableDictionary dictionary] 
                                             andHttpMethod: @"GET" 
                                                andOptions: [NSMutableDictionary dictionaryWithObjectsAndKeys:@"yes", @"unauthorized", nil]
                                               andDelegate: self]; 
}

- (void) cancelImageDownload {
    if (imageRequest) {
        [imageRequest cancel];
    }
    self.imageRequest = nil;
    self.imageIndexPath = nil;
}

- (void)request:(OAuthXRequest *)request didFailWithError:(NSError *)error {
    [delegate contact:self didFinishLoadingWithNoImageAvailableForIndexPath:imageIndexPath];
}

- (void)request:(OAuthXRequest *)request didLoadResponse:(OAuthXResponse *)response {
    UIImage *resultImage = [UIImage imageWithData:[response rawData]];
    if (resultImage) {
        [self saveMugshotImage: resultImage];
        [delegate contact:self didFinishLoadingImage:resultImage forIndexPath:imageIndexPath];
    }
}

- (void) downloadMugshotImageFromUrl: (NSString *) url locked:(BOOL) locked {
    NSLog(@"%@", url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    UIImage *resultImage = [UIImage imageWithData:(NSData *)result];
    [self saveMugshotImage:resultImage];  
}

@end
