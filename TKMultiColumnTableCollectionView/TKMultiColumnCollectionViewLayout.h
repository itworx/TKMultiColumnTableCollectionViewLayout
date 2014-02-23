//
//  TKMultiColumnCollectionViewLayout.h
//  TKMultiColumnTableCollectionView
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const TKCollectionElementKindRowHeader;
NSString *const TKCollectionElementKindRowHeaderBackground;
NSString *const TKCollectionElementKindRowFooter;
NSString *const TKCollectionElementKindRowFooterBackground;
NSString *const TKCollectionElementKindColumnHeader;
NSString *const TKCollectionElementKindColumnHeaderBackground;
NSString *const TKCollectionElementKindColumnGroupHeader;
NSString *const TKCollectionElementKindColumnGroupHeaderBackground;
NSString *const TKCollectionElementKindVerticalGridline;
NSString *const TKCollectionElementKindHorizontalGridline;

NSString *const TKCollectionElementKindRowHeaderOriginCell;
NSString *const TKCollectionElementKindRowFooterOriginCell;

NSString *const TKCollectionElementKindHorizontalRowHeaderSeparator;
NSString *const TKCollectionElementKindHorizontalRowFooterSeparator;

NSString *const TKCollectionElementKindVerticalGridlineSeparator;

@class TKMultiColumnCollectionViewLayout;
@protocol TKMultiColumnCollectionViewLayoutDelegate;

@interface TKMultiColumnCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet id<TKMultiColumnCollectionViewLayoutDelegate> delegate;

@property (nonatomic, assign) CGFloat rowHeaderWidth;
@property (nonatomic, assign) CGFloat rowHeaderHeight;

@property (nonatomic, assign) CGFloat rowFooterWidth;
@property (nonatomic, assign) CGFloat rowFooterHeight;

@property (nonatomic, assign) CGFloat columnHeaderWidth;
@property (nonatomic, assign) CGFloat columnHeaderHeight;

@property (nonatomic, assign) CGFloat columnGroupHeaderWidth;
@property (nonatomic, assign) CGFloat columnGroupHeaderHeight;

@property (nonatomic, assign) CGFloat horizontalGridlineHeight;
@property (nonatomic, assign) CGFloat verticalGridlineWidth;

@property (nonatomic, assign) UIEdgeInsets sectionMargin;
@property (nonatomic, assign) UIEdgeInsets contentMargin;
@property (nonatomic, assign) UIEdgeInsets cellMargin;

@property (nonatomic, assign) BOOL displayHeaderBackgroundAtOrigin;

- (void)invalidateLayoutCache;

@end


@protocol TKMultiColumnCollectionViewLayoutDelegate <NSObject, UICollectionViewDelegateFlowLayout>

@optional
- (NSInteger)numberOfColumnGroupsInCollectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout;

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout numberOfColumnsForGroupAtIndex:(NSInteger)groupIndex;

- (NSIndexSet *)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout columnsIndexesForGroupAtIndex:(NSInteger)groupIndex;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout widthForColumnHeaderInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout referenceSizeForRowHeaderInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end
