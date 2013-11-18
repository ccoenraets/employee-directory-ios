//
//  DetailViewController.h
//  EmployeeDirectory
//
//  Created by Christophe Coenraets on 11/18/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
