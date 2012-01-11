//
//  UIHelper.h
//  Anekdot
//
//  Created by Michael Berkovich on 7/28/09.
//  Copyright 2009 Michael Berkovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIHelper : NSObject {

}

+ (UILabel *) newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
+ (void) alertWithTitle:(NSString *) ttl message: (NSString *) msg delegate:delegate;

@end
