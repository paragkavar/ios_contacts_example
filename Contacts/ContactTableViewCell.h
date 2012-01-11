//
//  PhotoAlbumTableViewCell.h
//  Geni
//
//  Created by Michael Berkovich on 3/23/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContactTableViewCell : UITableViewCell {
}

@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UILabel *nameLabel;
@property(nonatomic, retain) UILabel *infoLabel;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIImageView *sourceImageView; 


-(void) markAsLoading;
-(void) updateWithImage:(UIImage *) image;
-(void) updateWithNoImage;
- (UIImage *) defaultLoadingImage;

@end
