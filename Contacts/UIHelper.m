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
