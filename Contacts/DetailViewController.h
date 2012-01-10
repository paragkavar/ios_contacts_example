//
//  DetailViewController.h
//  Contacts
//
//  Created by Michael Berkovich on 1/10/12.
//  Copyright (c) 2012 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
