//
//  ChatMore_FaceView.m
//  J1-IM
//
//  Created by wushangkun on 16/2/18.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ChatMore_FaceView.h"
#import "Emoji.h"

// MARK: FaceCollectionViewCell
@interface FaceCollectionViewCell : UICollectionViewCell

@property (nonatomic ,strong)  UILabel *titleLabel;
@property (nonatomic ,strong)  UIImageView * faceIcon;

@end

@implementation FaceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:25];
        [self.contentView addSubview:_titleLabel];
        
        _faceIcon = [[UIImageView alloc] initWithFrame:self.bounds];
        _faceIcon.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_faceIcon];
    }
    return self;
}

@end



// MARK: FaceCollectionViewLayout
@interface FaceCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic ,assign) NSInteger xNumber;
@property (nonatomic ,assign) NSInteger yNumber;

@end

@implementation FaceCollectionViewLayout
-(CGSize)collectionViewContentSize
{
    CGFloat page = [self.collectionView numberOfItemsInSection:0]/24.0;
    if (page > (int)page) {
        page +=1;
    }
    return CGSizeMake((int)page * DeviceWidth, 0);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    NSInteger number = [self.collectionView numberOfItemsInSection:0];
    
    int x=0, y=0, page = 0;
    
    for (int i = 0; i < number ; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
        
        attributes.frame = CGRectMake(x * attributes.frame.size.width + page * self.collectionView.frame.size.width, y * attributes.frame.size.height,attributes.frame.size.width , attributes.frame.size.width);
        
        x++;
        
        if (x > _xNumber) {
            x=0;
            y++;
            if (y>_yNumber) {
                y=0 ;
                page++;
            }
        }
    }
    return layoutAttributes;
}

@end

// MARK: 表情显示界面
@interface  FaceCollectionView  : UIView <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UIPageControl    *_pageControl;
}

@property (nonatomic,assign) FaceType faceType;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) FaceCollectionViewLayout *layout;
@property (nonatomic,assign) ChatMore_FaceView * faceView;

@end

@implementation FaceCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _layout = [[FaceCollectionViewLayout alloc]init];
        _layout.xNumber = 8;
        _layout.yNumber = 3;
        _layout.itemSize = CGSizeMake(frame.size.width / _layout.xNumber, (frame.size.height -20) / _layout.yNumber);
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 20) collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[FaceCollectionViewCell class] forCellWithReuseIdentifier:@"FaceCollectionViewCell"];
       // [_collectionView addObserver:self forKeyPath:@"contenSize" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:_collectionView];
        
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.numberOfPages =  frame.size.width  + 28 / _collectionView.frame.size.width;

        [self addSubview:_pageControl];
  
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGSize size;
    [[change objectForKey:@"new"]getValue:&size];
    _pageControl.numberOfPages = size.width / _collectionView.frame.size.width;

}

//-(void)dealloc
//{
//    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
//}

-(void)setDataArray:(NSArray *)dataArray
{
    NSMutableArray * mArr = [[NSMutableArray alloc] initWithArray:dataArray];
    [mArr removeObjectsInRange:NSMakeRange(mArr.count - 8, 8)];
    
    UIImage * image = [UIImage imageNamed:@"aio_face_delete"];
    for (int i = 24; i < mArr.count; i+=24) {
        [mArr insertObject:image atIndex:i - 1];
    }
    [mArr addObject:image];
    _dataArray = mArr;
    [_collectionView reloadData];
}

// MARK: - CollectionData Delgate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCollectionViewCell" forIndexPath:indexPath];
    
    id object = [self.dataArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = @"";
    cell.faceIcon.image = nil;
    
    if ([object isKindOfClass:[NSString class]]) {
        cell.titleLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    }else{
        cell.faceIcon.image = [self.dataArray objectAtIndex:indexPath.row];
    }

    return cell;
}

// MARK: - Collection Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_faceView.sendFaceBlock) {
        _faceView.sendFaceBlock([self.dataArray objectAtIndex:indexPath.row],self.faceType);
    }

}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, -20, 2, -20);
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
    page = page > (int)page ? page + 1 : page;
    _pageControl.currentPage = page;
}

@end

@interface FaceButton : UIButton

@end

@implementation FaceButton

-(void)drawRect:(CGRect)rect
{
    // 绘制左边的线条
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, [UIScreen mainScreen].scale /2.0);
    
    CGPoint points[2];
    points[0] = CGPointMake(rect.size.width, 0);
    points[1] = CGPointMake(rect.size.width, rect.size.height);
    
    CGContextAddLines(ctx, points, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end



// MARK: - 底部表情按钮

@interface FaceBar : UIView
{
    UIScrollView *_scrollView;
    NSArray *_btns;
    FaceButton *_preButton;
}
@property (nonatomic ,assign) ChatMore_FaceView *faceView;
@end

@implementation FaceBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc]initWithFrame:frame];
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _btns = @[[NSNumber numberWithInt:0x1F604]];
        
        int index = 0;
        for (id value in _btns) {
            FaceButton *btn = nil;
            if ([value isKindOfClass:[NSNumber class]]) {
                btn = [self defaultButtonTitle:[Emoji emojiWithCode:[value intValue]] Image:nil];
            }
            if (index == 0) {
                [self clickFaceBtn:btn];
            }
            [btn addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((frame.size.height+10)*index, 0, frame.size.height + 10, frame.size.height );
            [_scrollView addSubview:btn];
            index++;
        }
        
        FaceButton *sendBtn = [self defaultButtonTitle:@"发送" Image:nil];
        sendBtn.frame = CGRectMake(frame.size.width - (frame.size.height + 10), 0, (frame.size.height + 10), frame.size.height );
        [sendBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];
    }
    return self;
}

-(void)sendClick:(UIButton *)sendBtn
{
    if (_faceView.sendButtonBlock) {
        _faceView.sendButtonBlock();
    }
}

-(void)clickFaceBtn:(FaceButton *)btn
{
    _preButton.backgroundColor = [UIColor clearColor];
    btn.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    _preButton = btn;
}

-(FaceButton *)defaultButtonTitle:(NSString *)title Image:(UIImage *)image
{
    FaceButton *btn = [FaceButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:0];
    [btn setImage:image forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    return btn;
}

- (void)drawRect:(CGRect)rect
{
    // 绘制顶部的线条
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale / 2.0f);
    
    CGPoint points[2];
    points[0] = CGPointMake(0, 0);
    points[1] = CGPointMake(rect.size.width, 0);
    
    CGContextAddLines(ctx, points, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end


@interface ChatMore_FaceView ()

@property (nonatomic, strong) FaceBar *faceBar;
@property (nonatomic, strong) FaceCollectionView *collectionView;


@end



// MARK: - 聊天表情界面
@implementation ChatMore_FaceView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        _faceBar = [[FaceBar alloc]initWithFrame:CGRectMake(0, frame.size.height-40, frame.size.width, 40)];
        _faceBar.backgroundColor = [UIColor cyanColor];
        _faceBar.faceView = self;
        [self addSubview:_faceBar];
        
        _collectionView = [[FaceCollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-40)];
        _collectionView.faceView = self;
        [self addSubview:_collectionView];
        
        _collectionView.dataArray = [Emoji allEmoji];
        
    }

    return self;
}


@end
