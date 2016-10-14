//
//  CPInfiniteBannerView.m
//  Pods
//
//  Created by CrespoXiao on 04/23/2016.
//  Copyright (c) 2016 CrespoXiao. All rights reserved.
//

#import "CPInfiniteBannerView.h"
#import "CPInfiniteBannerSingleItem.h"

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <Masonry/Masonry.h>
#import <libextobjc/EXTScope.h>


#define ITEM_WIDTH                         (self.itemWidth + self.spacing)
#define CP_SafeBlockRun(block, ...)        block ? block(__VA_ARGS__) : nil



@interface CPInfiniteBannerView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (nonatomic, strong) UIPageControl                 *pageControl;
@property (nonatomic, strong) NSTimer                       *timer;
@property (nonatomic, weak  ) UIView                        *container;

@end

@implementation CPInfiniteBannerView


- (void)dealloc {
    _scrollView.delegate = nil;
    _scrollView = nil;
    _pageControl = nil;
    _placeHolder = nil;
    _container = nil;

    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    
    if (_responseBlock) {
        _responseBlock = nil;
    }
}

- (instancetype)initWithContainerView:(UIView *)contianer responseBlock:(CPInfiniteBannerResponseBlock)block {
    self = [super init];
    if (self) {
        [self commonInit];

        if (contianer) {
            _container = contianer;
            [contianer addSubview:self];
        }
        
        _responseBlock = [block copy];

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _itemWidth = [UIScreen mainScreen].bounds.size.width;
    _spacing = 0.0f;
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    _enableAutoScroll = YES;
    _pageContolAliment = CPInfiniteBannerPageContolAlimentRight;
    [self makeConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setImageArray:_imageArray];
}

#pragma mark - getter & sertter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.userInteractionEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(clickOnScrollView:)];
        [_scrollView addGestureRecognizer:tapGesture];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        // 总页数
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        [_pageControl setBackgroundColor:[UIColor clearColor]];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

#pragma mark - constraints

- (void)makeConstraints {
    
    if (self.spacing != 0 && self.itemWidth != self.frame.size.width) {
        self.scrollView.clipsToBounds = NO;
    }
    
    @weakify(self);
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        if (self.scrollView.clipsToBounds) {
            make.width.equalTo(self.mas_width);
        } else {
            make.width.mas_equalTo(ITEM_WIDTH);
        }
        make.height.equalTo(self);
        make.center.mas_equalTo(self);
    }];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        if (self.pageContolAliment == CPInfiniteBannerPageContolAlimentRight) {
            make.right.equalTo(self.scrollView.mas_right).offset(-5);
            
        } else if (self.pageContolAliment == CPInfiniteBannerPageContolAlimentLeft) {
            make.left.equalTo(self.scrollView.mas_left).offset(5);
            
        } else if (self.pageContolAliment == CPInfiniteBannerPageContolAlimentCenter) {
            make.centerX.equalTo(self.scrollView.mas_centerX);
            
        }
        
        make.bottom.equalTo(self.scrollView.mas_bottom);

        make.height.equalTo(@20);
    }];
    

}


#pragma mark - setter

- (void)setItemWidth:(CGFloat)itemWidth {
    _itemWidth = itemWidth;
    [self makeConstraints];
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    [self makeConstraints];
}

- (void)setPlaceHolder:(UIImage *)placeHolder {
    if (placeHolder) {
        _placeHolder = placeHolder;
    }
}

- (void)setDuration:(CFTimeInterval)duration {
    _duration = duration;
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    
    if (!imageArray || (imageArray && ![imageArray count])) {
        return;
    }
    _imageArray = imageArray;
    
    if (_imageArray.count) {
        
        //首尾各加一张图片
        self.pageControl.hidden = YES;
        self.scrollView.contentSize	 = CGSizeMake(ITEM_WIDTH * (_imageArray.count+4), self.frame.size.height);
        
        //set head view
        if (_imageArray.count > 1) {
            [self buildSubViewOfScrollViewWithTag:98 andImageData:_imageArray[_imageArray.count-2]];
        }
        
        NSInteger tag_head = 99;
        [self buildSubViewOfScrollViewWithTag:tag_head andImageData:[_imageArray lastObject]];
        
        //set center view
        for (NSInteger i = 0; i < _imageArray.count; i ++) {
            NSInteger tag = 100+i;
            [self buildSubViewOfScrollViewWithTag:tag andImageData:[_imageArray objectAtIndex:i]];
        }
        
        //set tail view
        NSInteger tag_tail = 100 + [_imageArray count];
        [self buildSubViewOfScrollViewWithTag:tag_tail andImageData:[_imageArray firstObject]];
        
        if (_imageArray.count > 1) {
            [self buildSubViewOfScrollViewWithTag:101+[_imageArray count] andImageData:_imageArray[1]];
        }
        
        //move to the first item
        [self gotoStartPostionAfterSetData];
    }
}

- (void)setEnableAutoScroll:(BOOL)enableAutoScroll {
    _enableAutoScroll = enableAutoScroll;
    enableAutoScroll ? [self fireTimer]:[self stopTimer];
}

- (void)setPageContolAliment:(CPInfiniteBannerPageContolAliment)pageContolAliment {
    _pageContolAliment = pageContolAliment;
    [self makeConstraints];
}

#pragma mark - build view

- (void)buildSubViewOfScrollViewWithTag:(NSInteger)tag andImageData:(id)imageData {
    if ([self.scrollView viewWithTag:tag]) {
        [[self.scrollView viewWithTag:tag] removeFromSuperview];
    }
    
    NSInteger position;
    if (tag == 98) {
        position = -1;
    } else if (tag == 99) {
        position = 0;
    }else if (tag == (100 + [_imageArray count])){
        position = [_imageArray count]+1;
    }else if (tag == (101 + [_imageArray count])){
        position = [_imageArray count]+2;
    }else{
        position = (tag - 100) + 1;
    }
    CPInfiniteBannerSingleItem *singleItemView = [[CPInfiniteBannerSingleItem alloc] initWithFrame:
                                   CGRectMake(ITEM_WIDTH * position, 0, ITEM_WIDTH, self.frame.size.height)
                                                                                       placeHolder:_placeHolder];
    singleItemView.tag = tag;
    
    UIView *lastView = self.scrollView.subviews.lastObject;
    
    [self.scrollView addSubview:singleItemView];
    
    [singleItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.itemWidth);

        make.height.equalTo(self.mas_height);
        if (position == -1) {
            make.left.equalTo(self.scrollView);
        } else {
            make.left.equalTo(lastView.mas_right).with.offset(self.spacing);
        }
        make.top.equalTo(self.scrollView);
    }];
    
    
    if ([imageData isKindOfClass:[UIImage class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            singleItemView.link = nil;
            [singleItemView setImage:(UIImage*)imageData];
            if (self.pageControl.hidden) {
                self.pageControl.hidden = NO;
            }
        });
    }else if ([imageData isKindOfClass:[NSURL class]]){
        @weakify(self);
        [self downloadImageWithUrl:imageData relatedLink:[imageData absoluteString] downloadImageCallBack:^(UIImage *image, NSString *link) {
            @strongify(self);
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    singleItemView.link = link;
                    [singleItemView setImage:image];
                    if (self.pageControl.hidden) {
                        self.pageControl.hidden = NO;
                    }
                });
            }
        }];
    }
}

- (void)gotoStartPostionAfterSetData {
    self.pageControl.numberOfPages = [_imageArray count];
    self.pageControl.currentPage = 0;
    [self scrollToIndex:0];
}


#pragma mark - press image

- (void)clickOnScrollView:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.scrollView];
    NSInteger page = (NSInteger)point.x / (NSInteger)ITEM_WIDTH;

    CPInfiniteBannerSingleItem *itemView;
    NSInteger currentTag;
    if (page <= 1) {//head
        currentTag = 98+page;
    }else if (page == [self.imageArray count]+1){//tail
        currentTag = (100 + [_imageArray count]);
    }else if (page == [self.imageArray count]+2) {//tail
        currentTag = (101 + [_imageArray count]);
    }else{//center
        currentTag = (page-1+100);
    }
    
    if ([self.scrollView viewWithTag:currentTag] &&
        [[self.scrollView viewWithTag:currentTag]isKindOfClass:[CPInfiniteBannerSingleItem class]]) {
        itemView = (CPInfiniteBannerSingleItem *)[self.scrollView viewWithTag:currentTag];
        
        if (_responseBlock) {
            page = page - 2;
            if (page < 0) {
                page = self.imageArray.count - 1;
            }
            if (page >= self.imageArray.count) {
                page = 0;
            }
            CP_SafeBlockRun(_responseBlock,itemView.link,page,itemView.imageView);
        }
    }
}


#pragma mark - timer methods

- (void)fireTimer {
    if (!self.enableAutoScroll) {
        return;
    }
    [self stopTimer];
    _duration = _duration ? _duration:3;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(go2Next) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)go2Next {
    CGFloat targetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
    targetX = (NSInteger)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
    [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
}

- (void)stopTimer {
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
    }
}


#pragma mark -scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self stopTimer];

    CGFloat targetX = scrollView.contentOffset.x;
    if ([self.imageArray count] > 1){
        if (targetX >= ITEM_WIDTH * ([self.imageArray count] + 2)) {
            targetX = ITEM_WIDTH*2;
            [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }else if(targetX <= ITEM_WIDTH){
            targetX = ITEM_WIDTH * [self.imageArray count] + ITEM_WIDTH;
            [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    NSInteger page = (self.scrollView.contentOffset.x+ITEM_WIDTH/2.0) / ITEM_WIDTH;

    if ([self.imageArray count] > 1){
        page --;
        if (page >= self.pageControl.numberOfPages){
            page = 0;
        }else if(page <0){
            page = self.pageControl.numberOfPages -1;
        }
    }
    self.pageControl.currentPage = page;

    [self fireTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate){
        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        targetX = (NSInteger)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        [self.scrollView setContentOffset:CGPointMake((NSInteger)targetX, 0) animated:YES];
    }
}


- (void)scrollToIndex:(NSInteger)aIndex {
    if ([self.imageArray count] > 1){
        if (aIndex >= ([self.imageArray count])){
            aIndex = [self.imageArray count]-1;
        }
        CGPoint point = CGPointMake(ITEM_WIDTH*(aIndex+2), 0);
        [self.scrollView setContentOffset:point animated:NO];
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - system
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self.scrollView.clipsToBounds == YES) return view;
    if ([view isEqual:self])
    {
        for (UIView *subview in self.scrollView.subviews)
        {
            CGPoint offset = CGPointMake(point.x - self.scrollView.frame.origin.x + self.scrollView.contentOffset.x - subview.frame.origin.x,
                                         point.y - self.scrollView.frame.origin.y + self.scrollView.contentOffset.y - subview.frame.origin.y);
            
            if ((view = [subview hitTest:offset withEvent:event]))
            {
                return view;
            }
        }
        return self.scrollView;
    }
    return view;
}

#pragma mark - download image

- (void)downloadImageWithUrl:(NSURL *)url
                 relatedLink:(NSString *)relatedlink
       downloadImageCallBack:(void (^)(UIImage *image,NSString *link))block {
    if (url && ([url isKindOfClass:[NSURL class]])) {
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
            if (!image) {
                [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageProgressiveDownload progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (finished) {
                        [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
                        CP_SafeBlockRun(block,image,relatedlink?:@"");
                    }
                }];
            }else{
                CP_SafeBlockRun(block,image,relatedlink?:@"");
            }
        }];
    }
}


@end
