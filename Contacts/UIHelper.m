//
//  UIHelper.m
//  Anekdot
//
//  Created by Michael Berkovich on 7/28/09.
//  Copyright 2009 Michael Berkovich. All rights reserved.
//

#import "UIHelper.h"


@implementation UIHelper

+ (UILabel *) newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold {
	UIFont *font;
	
	if (bold) {
		font = [UIFont boldSystemFontOfSize:fontSize];
	} else {
		font = [UIFont systemFontOfSize:fontSize];
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor whiteColor];
	label.opaque = YES;
	label.textColor = primaryColor;
	label.highlightedTextColor = selectedColor;
	label.font = font;
	
	return label;
}

+ (void) alertWithTitle:(NSString *) ttl message: (NSString *) msg delegate:delegate {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ttl message:msg delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

@end
