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


#import "ContactTableViewCell.h"
#import "UIHelper.h"

@implementation ContactTableViewCell
@synthesize imageView, nameLabel, infoLabel, activityIndicator, sourceImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.nameLabel = [UIHelper newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
		self.nameLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.nameLabel];

		self.infoLabel = [UIHelper newLabelWithPrimaryColor:[UIColor grayColor] selectedColor:[UIColor whiteColor] fontSize:12.0 bold:NO];
		self.infoLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.infoLabel];
        
		self.imageView = [[UIImageView alloc] initWithImage:[self defaultLoadingImage]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.imageView.clipsToBounds = YES; 
		[self.contentView addSubview:self.imageView];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self.contentView addSubview:self.activityIndicator];
        
		self.sourceImageView = [[UIImageView alloc] init];
        self.sourceImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:self.sourceImageView];
        
       // [self markAsLoading];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    [imageView setFrame: CGRectMake(2, 3, 46, 46)];
    [activityIndicator setFrame: CGRectMake(15, 15, 20, 20)];
    [nameLabel setFrame: CGRectMake(58, 7, 200, 20)];
    [infoLabel setFrame: CGRectMake(75, 27, 200, 20)];
    [sourceImageView setFrame: CGRectMake(58, 31, 14, 14)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIImage *) defaultLoadingImage {
    return [UIImage imageNamed:@"mugshot.gif"];
}

-(void) markAsLoading {
    self.imageView.image = [self defaultLoadingImage];
    activityIndicator.hidden = NO; 
    [activityIndicator startAnimating];
}

-(void) updateWithImage:(UIImage *) image {
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES; 
    imageView.image = image;
    [imageView setNeedsDisplay];
}

-(void) updateWithNoImage {
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES; 
}

@end
