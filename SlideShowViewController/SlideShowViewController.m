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
@property (nonatomic) NSInteger currentImageIndex;
@property (nonatomic,weak) UIImageView *currentImageView;

@end


@implementation SlideShowViewController
{
    __weak IBOutlet UIActivityIndicatorView *loadActivity;
    __weak IBOutlet UIView *controllsView;
    __weak IBOutlet UIView *contentView;
    
    BOOL controllsHidden;
}

@synthesize loadActivity = loadActivity;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.currentImageIndex = -1;
        self.interval = 5;
        controllsHidden = NO;
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
    
    if (self.currentImageIndex==-1)
        [self startSlideShow];
    
    controllsView.alpha = 0.5;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
    [self setControllsHiden:NO animated:NO];
    
    if (loadActivity)
        [self startSlideShow];
}

-(void)startSlideShow
{
    self.currentImageIndex = 0;
    
    if (!self.imagesUrls.count)
        return;
    
    [self scheduleHideControlls:2.0];
    
    if (self.currentImageView)
    {
        [self.currentImageView removeFromSuperview];
        self.currentImageView = nil;
    }
    
    [loadActivity startAnimating];
    [self loadImageAsync:self.imagesUrls[0] completition:^(UIImage *image) {
        [self.loadActivity stopAnimating];
        [self showImage:image completition:^{
            if (self.imagesUrls.count>1)
                [self scheduleSwitch:self.interval * (1.0 - FADE_PERCENT)];
            else
                [self scheduleClose:self.interval];
        }];
        if (self.imagesUrls.count>1)
            [self loadImageAsync:self.imagesUrls[1]
                     completition:^(UIImage *image) {
                         self.nextImage = image;
                     }];
    }];
}

-(void)scheduleClose:(CGFloat)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self closeClick:nil];
    });
}

-(void)scheduleHideControlls:(CGFloat)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setControllsHiden:YES animated:YES];
    });
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
    SlideShowImageView *imageView = [[SlideShowImageView alloc] initWithFrame:contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = image;
    imageView.delegate = self;
    imageView.userInteractionEnabled = YES;
    
    if (self.currentImageView)
    {
        [UIView transitionFromView:self.currentImageView
                            toView:imageView
                          duration:2.0*self.interval*FADE_PERCENT
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            self.currentImageView = imageView;
                            if (completition)
                                completition();
                        }];
    }
    else
    {
        imageView.alpha = 0;
        [contentView insertSubview:imageView atIndex:0];
        [UIView animateWithDuration:self.interval*FADE_PERCENT
                         animations:^{
                             imageView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             self.currentImageView = imageView;
                             if (completition)
                                 completition();
                         }];
    }
}

-(void)scheduleSwitch:(double)switchInterval
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(switchInterval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSwitch];
    });
}

-(void)performSwitch
{
    if (self.currentImageIndex == self.imagesUrls.count)
    {
        [UIView animateWithDuration:self.interval*FADE_PERCENT
                         animations:^{
                             self.currentImageView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self closeClick:nil];
                         }];
    }
    else if (!self.nextImage)
    {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSwitch];
        });
    }
    else
    {
        [self showImage:self.nextImage completition:^{
            [self scheduleSwitch:self.interval * (1.0 - 2*FADE_PERCENT)];
        }];
        self.currentImageIndex++;
        if (self.currentImageIndex<self.imagesUrls.count)
            [self loadImageAsync:self.imagesUrls[self.currentImageIndex] completition:^(UIImage *image) {
                self.nextImage = image;
            }];
    }
}

-(void)setControllsHiden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat duration = 0.0;
    if (animated)
        duration = 0.3;
    CGFloat toAlpha = 0.0;
        
    if (hidden)
    {
        if (controllsHidden) return;
        toAlpha = 0.0;
    }
    else
    {
        if (!controllsHidden) return;
        toAlpha = 0.5;
    }
    
    controllsHidden = hidden;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         controllsView.alpha = toAlpha;
                     }];
}

-(void)slideShowImageViewTapped:(SlideShowImageView *)imageView
{
    [self touchDetected];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchDetected];
}

-(void)touchDetected
{
    [self setControllsHiden:!controllsView animated:YES];
    if (!controllsHidden)
        [self scheduleHideControlls:3.0];
}

@end
