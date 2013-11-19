//
//  SlideShowViewController.h
//  SlidshowViewController
//
//  Created by Evgeny Rusanov on 11.11.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideShowImageView.h"

@interface SlideShowViewController : UIViewController <SlideShowImageViewDelegate>

@property (nonatomic, strong) NSArray *imagesUrls;
@property (nonatomic) float interval;

+(SlideShowViewController*)constructSlideShowViewController;

@end
