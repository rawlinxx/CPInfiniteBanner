//
//  CPInfiniteBannerView.h
//  Pods
//
//  Created by CrespoXiao on 04/23/2016.
//  Copyright (c) 2016 CrespoXiao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  link, the image url string, if the source is a image, return a @""
 *  selectedIndex, the index of the clicked image
 *  imageView, clicked imageview, you can use it to write a animation maybe :]
 */
typedef void (^CPInfiniteBannerResponseBlock)(NSString * link, NSUInteger selectedIndex, UIImageView *imageView);

typedef NS_ENUM(NSUInteger, CPInfiniteBannerPageContolAliment) {
    CPInfiniteBannerPageContolAlimentRight = 0,
    CPInfiniteBannerPageContolAlimentCenter,
    CPInfiniteBannerPageContolAlimentLeft
};


@interface CPInfiniteBannerView : UIControl

// placeholder of banner
@property (nonatomic, strong) UIImage                       *placeHolder;

// image arrays of banner
@property (nonatomic, strong) NSMutableArray                *imageArray;

// duration of auto scroll, default is 3
@property (nonatomic, assign) CFTimeInterval                duration;

// enable auto scroll, default is Yes
@property (nonatomic, assign) BOOL enableAutoScroll;

// page contol aliment, default is CPInfiniteBannerPageContolAlimentRight
@property (nonatomic, assign) CPInfiniteBannerPageContolAliment pageContolAliment;

// scrollview to contol the images
@property (nonatomic, strong, readonly) UIScrollView                  *scrollView;

// you can cutom the pagecontol props
@property (nonatomic, strong, readonly) UIPageControl                 *pageControl;

// image click block
@property (nonatomic, copy  ) CPInfiniteBannerResponseBlock responseBlock;

// item width
@property (nonatomic) CGFloat itemWidth;

// spacing between items
@property (nonatomic) CGFloat spacing;
/**
 *  init method
 *
 *  @param contianer
 *  @param block
 *
 *  @return
 */
- (instancetype)initWithContainerView:(UIView *)contianer responseBlock:(CPInfiniteBannerResponseBlock)block;

@end
