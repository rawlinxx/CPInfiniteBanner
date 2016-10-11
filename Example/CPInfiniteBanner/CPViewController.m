//
//  CPViewController.m
//  CPInfiniteBanner
//
//  Created by CrespoXiao on 04/23/2016.
//  Copyright (c) 2016 CrespoXiao. All rights reserved.
//

#import "CPViewController.h"
#import <CPInfiniteBanner/CPInfiniteBannerView.h>


@interface CPViewController ()
@property (weak, nonatomic) IBOutlet CPInfiniteBannerView *banner;

@end

@implementation CPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *array = @[[NSURL URLWithString:@"http://file27.mafengwo.net/M00/52/F2/wKgB6lO_PTyAKKPBACID2dURuk410.jpeg"],
//                        [NSURL URLWithString:@"http://file27.mafengwo.net/M00/52/F2/wKgB6lO_PTyAKKPBACID2dURuk410.jpeg"],
                        [UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"]];
    
    self.banner.placeHolder = nil;
//    self.banner.itemWidth = 275;
//    self.banner.spacing = 5;
    self.banner.enableAutoScroll = YES;

    [self.banner setImageArray:[NSMutableArray arrayWithArray:array]];

//    CPInfiniteBannerView *banner = [[CPInfiniteBannerView alloc]initWithContainerView:self.view responseBlock:^(NSString *link, NSUInteger index) {
//        NSLog(@"the link of the image you pressed is %@",link);
//    }];
//    banner.frame = CGRectMake(20, 30, self.view.frame.size.width-40, 90);
//    banner.placeHolder = [UIImage imageNamed:@"3.jpg"];
//    banner.duration = 3.0;
//    banner.enableAutoScroll = NO;
//    banner.pageContolAliment = CPInfiniteBannerPageContolAlimentLeft;
//    banner.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
//    banner.imageArray = [NSMutableArray arrayWithArray:array];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
