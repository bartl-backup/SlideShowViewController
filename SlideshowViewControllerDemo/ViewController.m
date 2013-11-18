//
//  ViewController.m
//  SlideshowViewController
//
//  Created by Evgeny Rusanov on 18.11.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "ViewController.h"

#import "SlideShowViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"show" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 100, 100);
    button.center = self.view.center;
    
    [button addTarget:self
               action:@selector(showSlideshow)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSlideshow
{
    SlideShowViewController *slideShow = [SlideShowViewController constructSlideShowViewController];
    
    NSString *names [] = {@"1111",@"2222",@"3333",@"4444"};
    NSMutableArray *links = [NSMutableArray array];
    for (int i=0; i<4; i++)
        [links addObject:[[NSBundle mainBundle] URLForResource:names[i] withExtension:@"jpg"]];
    
    slideShow.imagesUrls = links;
    
    [self presentViewController:slideShow animated:YES completion:nil];
}

@end
