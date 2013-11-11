//
//  SlideShowViewController.m
//  SlidshowViewController
//
//  Created by Evgeny Rusanov on 11.11.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "SlideShowViewController.h"

#define FADE_PERCENT            0.1

@interface SlideShowViewController()

@property (nonatomic,weak) UIActivityIndicatorView *loadActivity;
@property (nonatomic,strong) UIImage *nextImage;
@property (nonatomic) int currentImageIndex;
@property (nonatomic,weak) UIImageView *currentImageView;

@end


@implementation SlideShowViewController
{
    __weak IBOutlet UIActivityIndicatorView *loadActivity;
}

@synthesize loadActivity = loadActivity;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.currentImageIndex = -1;
    }
    return self;
}

+(SlideShowViewController*)constructSlideShowViewController
{
    return [[SlideShowViewController alloc] initWithNibName:@"SlideShowViewController" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setImagesUrls:(NSArray *)imagesUrls
{
    _imagesUrls = imagesUrls;
    
    [self startSlideShow];
}

-(void)startSlideShow
{
    self.currentImageIndex = 0;
    
    if (!self.imagesUrls.count)
        return;
    
    __weak typeof(self) pself = self;
    
    if (self.currentImageView)
    {
        [self.currentImageView removeFromSuperview];
        self.currentImageView = nil;
    }
    
    [loadActivity startAnimating];
    [self loadImageAsync:self.imagesUrls[0] completition:^(UIImage *image) {
        [pself.loadActivity stopAnimating];
        [pself showImage:image completition:^{
            [pself scheduleSwitch:pself.interval * (1.0 - FADE_PERCENT)];
        }];
        if (pself.imagesUrls.count>1)
            [pself loadImageAsync:pself.imagesUrls[1]
                     completition:^(UIImage *image) {
                         pself.nextImage = image;
                     }];
    }];
}

-(void)loadImageAsync:(NSURL*)imageUrl completition:(void(^)(UIImage *image))completition
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:imageData];
        if (completition!=nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completition(image);
            });
        }
    });
}

-(void)showImage:(UIImage*)image completition:(void (^)(void))completition
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    __weak typeof(self) pself = self;
    
    if (self.currentImageView)
    {
        [UIView transitionFromView:self.currentImageView
                            toView:imageView
                          duration:2*self.interval*FADE_PERCENT
                           options:0
                        completion:^(BOOL finished) {
                            pself.currentImageView = imageView;
                            if (completition)
                                completition();
                        }];
    }
    else
    {
        imageView.alpha = 0;
        [self.view insertSubview:imageView belowSubview:self.loadActivity];
        [UIView animateWithDuration:self.interval*FADE_PERCENT
                         animations:^{
                             imageView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             pself.currentImageView = imageView;
                             if (completition)
                                 completition();
                         }];
    }
}

-(void)scheduleSwitch:(double)switchInterval
{
    __weak typeof(self) pself = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(switchInterval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [pself performSwitch];
    });
}

-(void)performSwitch
{
    __weak typeof(self) pself = self;
    
    if (self.currentImageIndex == self.imagesUrls.count)
    {
        [UIView animateWithDuration:pself.interval*FADE_PERCENT
                         animations:^{
                             pself.currentImageView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [pself closeClick:nil];
                         }];
    }
    else if (!self.nextImage)
    {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pself performSwitch];
        });
    }
    else
    {
        [self showImage:pself.nextImage completition:^{
            [pself scheduleSwitch:pself.interval * (1.0 - 2*FADE_PERCENT)];
        }];
        self.currentImageIndex++;
        if (self.currentImageIndex<self.imagesUrls.count)
            [self loadImageAsync:self.imagesUrls[self.currentImageIndex] completition:^(UIImage *image) {
                pself.nextImage = image;
            }];
    }
}

@end
