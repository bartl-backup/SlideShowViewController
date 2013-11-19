//
//  SlideShowImageView.m
//  photomovie
//
//  Created by Evgeny Rusanov on 19.11.13.
//  Copyright (c) 2013 Macsoftex. All rights reserved.
//

#import "SlideShowImageView.h"

@implementation SlideShowImageView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideShowImageViewTapped:)])
        [self.delegate slideShowImageViewTapped:self];
}

@end
