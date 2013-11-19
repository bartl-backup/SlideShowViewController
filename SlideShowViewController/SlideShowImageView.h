//
//  SlideShowImageView.h
//  photomovie
//
//  Created by Evgeny Rusanov on 19.11.13.
//  Copyright (c) 2013 Macsoftex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlideShowImageView;

@protocol SlideShowImageViewDelegate <NSObject>
@optional
-(void)slideShowImageViewTapped:(SlideShowImageView*)imageView;
@end

@interface SlideShowImageView : UIImageView

@property (nonatomic,assign) id<SlideShowImageViewDelegate> delegate;

@end
