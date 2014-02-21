//
//  TKMultiColumnCollectionViewLayout.m
//  TKMultiColumnTableCollectionView
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import "TKMultiColumnCollectionViewLayout.h"

NSString *const TKCollectionElementKindRowHeader                    = @"TKCollectionElementKindRowHeader";
NSString *const TKCollectionElementKindRowFooter                    = @"TKCollectionElementKindRowFooter";
NSString *const TKCollectionElementKindColumnHeader                 = @"TKCollectionElementKindColumnHeader";
NSString *const TKCollectionElementKindColumnGroupHeader            = @"TKCollectionElementKindColumnGroupHeader";

NSString *const TKCollectionElementKindRowHeaderBackground          = @"TKCollectionElementKindRowHeaderBackground";
NSString *const TKCollectionElementKindRowFooterBackground          = @"TKCollectionElementKindRowFooterBackground";
NSString *const TKCollectionElementKindColumnHeaderBackground       = @"TKCollectionElementKindColumnHeaderBackground";
NSString *const TKCollectionElementKindColumnGroupHeaderBackground  = @"TKCollectionElementKindColumnGroupHeaderBackground";
NSString *const TKCollectionElementKindVerticalGridline             = @"TKCollectionElementKindVerticalGridline";
NSString *const TKCollectionElementKindVerticalLastGridline             = @"TKCollectionElementKindVerticalLastGridline";
NSString *const TKCollectionElementKindHorizontalGridline           = @"TKCollectionElementKindHorizontalGridline";

NSString *const TKCollectionElementKindRowHeaderOriginCell = @"TKCollectionElementKindRowHeaderOriginCell";
NSString *const TKCollectionElementKindRowFooterOriginCell = @"TKCollectionElementKindRowFooterOriginCell";

NSString *const TKCollectionElementKindHorizontalRowHeaderSeparator           = @"TKCollectionElementKindHorizontalRowHeaderSeparator";
NSString *const TKCollectionElementKindHorizontalRowFooterSeparator           = @"TKCollectionElementKindHorizontalRowFooterSeparator";

NSString *const TKCollectionElementKindVerticalGridlineSeparator = @"TKCollectionElementKindVerticalGridlineSeparator";

NSString *const TKCollectionElementKindVerticalRowGridline             = @"TKCollectionElementKindVerticalRowGridline";


NSUInteger const TKCollectionMinOverlayZ = 1000.0; // Allows for 900 items in a section without z overlap issues
NSUInteger const TKCollectionMinCellZ = 10.0;  // Allows for 100 items in a section's background
NSUInteger const TKCollectionMinBackgroundZ = 100.0;


@interface TKMultiColumnCollectionViewLayout ()

// Caches
@property (nonatomic, assign) BOOL needsToPopulateAttributesForAllSections;

@property (nonatomic, assign) CGFloat cachedColumnWidth;

// Registered Decoration Classes
@property (nonatomic, strong) NSMutableDictionary *registeredDecorationClasses;

// Attributes
@property (nonatomic, strong) NSMutableArray *allAttributes;
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

@property (nonatomic, strong) NSMutableDictionary *columnHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *columnHeaderBackgroundAttributes;

@property (nonatomic, strong) NSMutableDictionary *columnGroupHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *columnGroupHeaderBackgroundAttributes;

@property (nonatomic, strong) NSMutableDictionary *rowHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *rowHeaderBackgroundAttributes;

@property (nonatomic, strong) NSMutableDictionary *rowHeaderSeparatorAttributes;
@property (nonatomic, strong) NSMutableDictionary *rowFooterSeparatorAttributes;

@property (nonatomic, strong) NSMutableDictionary *columnHeaderSeparatorAttributes;

@property (nonatomic, strong) NSMutableDictionary *rowFooterAttributes;
@property (nonatomic, strong) NSMutableDictionary *rowFooterBackgroundAttributes;

@property (nonatomic, strong) NSMutableDictionary *horizontalGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *verticalGridlineAttributes;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *lastVerticalGridlineAttributes;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *rowHeaderOriginCellAttributes;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *rowFooterOriginCellAttributes;

- (void)initialize;

// Layout
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache;
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache;
- (UICollectionViewLayoutAttributes *)layoutAttributesForCellAtIndexPath:(NSIndexPath *)indexPath withItemCache:(NSMutableDictionary *)itemCache;

// Section Sizing
- (CGRect)rectForSection:(NSInteger)section;
- (CGFloat)sectionsWidth;
- (CGFloat)minXOfSection:(NSInteger)section;
- (CGFloat)widthOfSection:(NSInteger)section;

// Z Index
- (CGFloat)zIndexForElementKind:(NSString *)elementKind;
@end


@implementation TKMultiColumnCollectionViewLayout


#pragma mark - init

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

#pragma mark - UICollectionViewLayout

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [self invalidateLayoutCache];
    
    // Update the layout with the new items
    [self prepareLayout];
    
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates {
    // This is a hack to prevent the error detailed in :
    // http://stackoverflow.com/questions/12857301/uicollectionview-decoration-and-supplementary-views-can-not-be-moved
    // If this doesn't happen, whenever the collection view has batch updates performed on it, we get multiple instantiations of decoration classes
    for (UIView *subview in self.collectionView.subviews) {
        for (Class decorationViewClass in self.registeredDecorationClasses.allValues) {
            if ([subview isKindOfClass:decorationViewClass]) {
                [subview removeFromSuperview];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind {
    [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
    self.registeredDecorationClasses[decorationViewKind] = viewClass;
}

- (void)prepareLayout {
    self.collectionView.bounces = NO;
    [super prepareLayout];
    
    if (self.needsToPopulateAttributesForAllSections) {
        [self prepareSectionLayoutForSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        self.needsToPopulateAttributesForAllSections = NO;
    }
    
    BOOL needsToPopulateAllAttribtues = (self.allAttributes.count == 0);
    
    if (needsToPopulateAllAttribtues) {
        [self.allAttributes addObjectsFromArray:[self.columnHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.columnHeaderBackgroundAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.columnGroupHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.columnGroupHeaderBackgroundAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.rowHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.rowHeaderBackgroundAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.rowFooterAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.rowFooterBackgroundAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.verticalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.horizontalGridlineAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.rowHeaderSeparatorAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.rowFooterSeparatorAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.columnHeaderSeparatorAttributes allValues]];
        
        [self.allAttributes addObjectsFromArray:[self.itemAttributes allValues]];
        [self.allAttributes addObject:self.rowHeaderOriginCellAttributes];
        [self.allAttributes addObject:self.rowFooterOriginCellAttributes];
    }
}

- (UICollectionViewLayoutAttributes *)rowHeaderOriginCellAttributes {
    
    if (!_rowHeaderOriginCellAttributes) {
        NSIndexPath *rowHeaderOriginIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *rowHeaderOriginAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:TKCollectionElementKindRowHeaderOriginCell withIndexPath:rowHeaderOriginIndexPath];
        // update its frame
        CGFloat rowHeaderOriginMinY = self.collectionView.contentInset.top + self.collectionView.contentOffset.y;
        rowHeaderOriginAttributes.frame = CGRectMake(self.collectionView.contentOffset.x, rowHeaderOriginMinY, self.rowHeaderWidth, self.rowHeaderHeight);
        rowHeaderOriginAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowHeaderOriginCell];
        _rowHeaderOriginCellAttributes = rowHeaderOriginAttributes;
    }
    
    return _rowHeaderOriginCellAttributes;
}

- (UICollectionViewLayoutAttributes *)rowFooterOriginCellAttributes {
    
    if (!_rowFooterOriginCellAttributes) {
        NSIndexPath *rowHeaderOriginIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *rowHeaderOriginAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:TKCollectionElementKindRowFooterOriginCell withIndexPath:rowHeaderOriginIndexPath];
        // update its frame
        CGFloat rowHeaderOriginMinY = self.collectionView.contentInset.top + self.collectionView.contentOffset.y;
        CGFloat rowFooterMinX = fmaxf(self.collectionView.contentOffset.x + self.collectionView.frame.size.width - self.rowFooterWidth, 0.0);
        rowHeaderOriginAttributes.frame = CGRectMake(rowFooterMinX, rowHeaderOriginMinY, self.rowHeaderWidth, self.rowHeaderHeight);
        rowHeaderOriginAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowHeaderOriginCell];
        _rowFooterOriginCellAttributes = rowHeaderOriginAttributes;
    }
    
    return _rowFooterOriginCellAttributes;
}

- (void)prepareSectionLayoutForSections:(NSIndexSet *)sectionIndexes {
    
    if (self.collectionView.numberOfSections == 0) {
        return;
    }
    
    BOOL needsToPopulateItemAttributes = (self.itemAttributes.count == 0);
    BOOL needsToPopulateVerticalGridlineAttributes = (self.verticalGridlineAttributes.count == 0);
    
    CGFloat gridMinY = 0 + self.collectionView.contentInset.top;
    CGFloat gridContentMinX = self.rowHeaderWidth;
    CGFloat gridContentMinY = self.columnHeaderHeight + self.columnGroupHeaderHeight;
    CGFloat gridWidth = (self.collectionViewContentSize.width - self.rowHeaderWidth);
    
    CGRect frame = self.rowHeaderOriginCellAttributes.frame;
    frame.origin.y  = self.collectionView.contentInset.top + self.collectionView.contentOffset.y;
    frame.origin.x = self.collectionView.contentOffset.x;
    self.rowHeaderOriginCellAttributes.frame = frame;
    
    frame = self.rowFooterOriginCellAttributes.frame;
    frame.origin.y  = self.collectionView.contentInset.top + self.collectionView.contentOffset.y;
    frame.origin.x = self.collectionView.contentOffset.x + self.collectionView.frame.size.width - self.rowFooterWidth;
    self.rowFooterOriginCellAttributes.frame = frame;
    
    // Row Header
    CGFloat rowHeaderMinX;
    BOOL rowHeaderFloating;
    {
        rowHeaderMinX = fmaxf(self.collectionView.contentOffset.x, 0.0);
        rowHeaderFloating = ((rowHeaderMinX != 0) || self.displayHeaderBackgroundAtOrigin);
        
        // Row Header Background
        
        NSIndexPath *rowHeaderBackgroundIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *rowHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:rowHeaderBackgroundIndexPath ofKind:TKCollectionElementKindRowHeaderBackground withItemCache:self.rowHeaderBackgroundAttributes];
        // Frame
        CGFloat rowHeaderBackgroundHeight = self.collectionView.frame.size.height;
        CGFloat rowHeaderBackgroundWidth = self.rowHeaderWidth;
        CGFloat rowHeaderBackgroundMinX = (rowHeaderMinX);
        CGFloat rowHeaderBackgroundMinY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
        
        rowHeaderBackgroundAttributes.frame = CGRectMake(rowHeaderBackgroundMinX, rowHeaderBackgroundMinY, rowHeaderBackgroundWidth, rowHeaderBackgroundHeight);
        // Floating
        rowHeaderBackgroundAttributes.hidden = !rowHeaderFloating;
        rowHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowHeaderBackground];
    }
    
    // Row Footer
    CGFloat rowFooterMinX;
    BOOL rowFooterFloating;
    {
        rowFooterMinX = fmaxf(self.collectionView.contentOffset.x + self.collectionView.frame.size.width - self.rowFooterWidth, 0.0);
        rowFooterFloating = ((rowFooterMinX != 0) || self.displayHeaderBackgroundAtOrigin);
        
        // Row Footer Background
        NSIndexPath *rowFooterBackgroundIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *rowFooterBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:rowFooterBackgroundIndexPath ofKind:TKCollectionElementKindRowFooterBackground withItemCache:self.rowFooterBackgroundAttributes];
        // Frame
        CGFloat rowFooterBackgroundHeight = self.collectionView.frame.size.height;
        CGFloat rowFooterBackgroundWidth = self.rowFooterWidth;
        CGFloat rowFooterBackgroundMinX = (rowFooterMinX);
        CGFloat rowFooterBackgroundMinY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
        
        rowFooterBackgroundAttributes.frame = CGRectMake(rowFooterBackgroundMinX, rowFooterBackgroundMinY, rowFooterBackgroundWidth, rowFooterBackgroundHeight);
        // Floating
        rowFooterBackgroundAttributes.hidden = !rowHeaderFloating;
        rowFooterBackgroundAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowFooterBackground];
    }
    
    CGFloat columnGroupHeaderMinY;
    BOOL columnGroupHeaderFloating;
    {
        columnGroupHeaderMinY = fmaxf(self.collectionView.contentOffset.y + self.collectionView.contentInset.top, 0.0);
        columnGroupHeaderFloating = ((columnGroupHeaderMinY != 0) || self.displayHeaderBackgroundAtOrigin);
        // Column Group Header Background
        NSIndexPath *columnGroupHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *columnGroupHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:columnGroupHeaderBackgroundIndexPath ofKind:TKCollectionElementKindColumnGroupHeaderBackground withItemCache:self.columnGroupHeaderBackgroundAttributes];
        // Frame
        CGFloat columnGroupHeaderBackgroundHeight = self.columnGroupHeaderHeight;
        columnGroupHeaderBackgroundAttributes.frame = CGRectMake(self.collectionView.contentOffset.x, columnGroupHeaderMinY, self.collectionView.frame.size.width, columnGroupHeaderBackgroundHeight);
        // Floating
        columnGroupHeaderBackgroundAttributes.hidden = !columnGroupHeaderFloating;
        columnGroupHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindColumnGroupHeaderBackground];
        
        
    }
    
    // Column Header
    CGFloat columnHeaderMinY;
    BOOL columnHeaderFloating;
    {
        columnHeaderMinY = fmaxf(self.collectionView.contentOffset.y + self.collectionView.contentInset.top + self.columnGroupHeaderHeight, 0.0);
        columnHeaderFloating = ((columnHeaderMinY != 0) || self.displayHeaderBackgroundAtOrigin);
        
        // Column Header Background
        NSIndexPath *columnHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *columnHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:columnHeaderBackgroundIndexPath ofKind:TKCollectionElementKindColumnHeaderBackground withItemCache:self.columnHeaderBackgroundAttributes];
        // Frame
        CGFloat columnHeaderBackgroundHeight = self.columnHeaderHeight;
        columnHeaderBackgroundAttributes.frame = CGRectMake(self.collectionView.contentOffset.x, columnHeaderMinY, self.collectionView.frame.size.width, columnHeaderBackgroundHeight);
        // Floating
        columnHeaderBackgroundAttributes.hidden = !columnHeaderFloating;
        columnHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindColumnHeaderBackground];
    }
    
    // calculate Row Header&Footer Attributes
    for (NSInteger idx = 0; idx < [self.collectionView numberOfItemsInSection:0]; idx++) {
        
        // Row Headers
        {
            NSIndexPath *rowHeaderIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            UICollectionViewLayoutAttributes *rowHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:rowHeaderIndexPath ofKind:TKCollectionElementKindRowHeader withItemCache:self.rowHeaderAttributes];
            // update its frame
            CGFloat rowHeaderMinY = gridContentMinY + (self.rowHeaderHeight * idx);
            rowHeaderAttributes.frame = CGRectMake(rowHeaderMinX, rowHeaderMinY, self.rowHeaderWidth, self.rowHeaderHeight);
            rowHeaderAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowHeader];
        }
        
        // Row Headers Separator
        {
            NSIndexPath *rowHeaderIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            UICollectionViewLayoutAttributes *rowHeaderAttributes = [self layoutAttributesForDecorationViewAtIndexPath:rowHeaderIndexPath ofKind:TKCollectionElementKindHorizontalRowHeaderSeparator withItemCache:self.rowHeaderSeparatorAttributes];
            // update its frame
            CGFloat rowHeaderMinY = (self.rowHeaderHeight * idx) + self.rowHeaderHeight;
            rowHeaderAttributes.frame = CGRectMake(rowHeaderMinX, rowHeaderMinY, self.rowHeaderWidth, self.horizontalGridlineHeight);
            rowHeaderAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindHorizontalRowHeaderSeparator];
        }
        
        // Horizontal Gridlines
        {
            NSIndexPath *horizontalGridlineIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:horizontalGridlineIndexPath ofKind:TKCollectionElementKindHorizontalGridline withItemCache:self.horizontalGridlineAttributes];
            CGFloat horizontalGridlineMinY = nearbyintf((self.rowHeaderHeight * idx) + self.rowHeaderHeight);
            CGFloat horizontalGridlineXOffset = 0;//(gridMinX + self.sectionMargin.left);
            CGFloat horizontalGridlineMinX = fmaxf(horizontalGridlineXOffset, self.collectionView.contentOffset.x + horizontalGridlineXOffset);
            CGFloat horizontalGridlineWidth = fminf(gridWidth, self.collectionView.frame.size.width);
            horizontalGridlineAttributes.frame = CGRectMake(horizontalGridlineMinX, horizontalGridlineMinY, horizontalGridlineWidth, self.horizontalGridlineHeight);
            horizontalGridlineAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindHorizontalGridline];
        }
        
        
        // Row Footers
        {
            NSIndexPath *rowFooterIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            UICollectionViewLayoutAttributes *rowFooterAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:rowFooterIndexPath ofKind:TKCollectionElementKindRowFooter withItemCache:self.rowFooterAttributes];
            // update its frame
            CGFloat rowFooterMinY = gridContentMinY + (self.rowFooterHeight * idx);
            rowFooterAttributes.frame = CGRectMake(rowFooterMinX, rowFooterMinY, self.rowFooterWidth, self.rowHeaderHeight);
            rowFooterAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindRowHeader];
        }
        
        // Row Footers Separator
        {
            NSIndexPath *rowFooterIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            UICollectionViewLayoutAttributes *rowFooterAttributes = [self layoutAttributesForDecorationViewAtIndexPath:rowFooterIndexPath ofKind:TKCollectionElementKindHorizontalRowFooterSeparator withItemCache:self.rowFooterSeparatorAttributes];
            // update its frame
            CGFloat rowFooterMinY = (self.rowHeaderHeight * idx);
            rowFooterAttributes.frame = CGRectMake(rowFooterMinX, rowFooterMinY, self.rowFooterWidth, self.horizontalGridlineHeight);
            rowFooterAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindHorizontalRowFooterSeparator];
        }
    }
    
    
    __block CGFloat sectionsWidth = 0;
    
    [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        
        CGFloat columnWidth = self.columnHeaderWidth;
        if (sectionsWidth == 0) {
            sectionsWidth = [self minXOfSection:section];
        }
        CGFloat sectionMinX = (gridContentMinX + sectionsWidth);
        
        // Column Header
        
        UICollectionViewLayoutAttributes *columnHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] ofKind:TKCollectionElementKindColumnHeader withItemCache:self.columnHeaderAttributes];
        // asks the delegat for the column width
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:widthForColumnHeaderInSection:)]) {
            CGFloat width = [self.delegate collectionView:self.collectionView layout:self widthForColumnHeaderInSection:section];
            if (width > columnWidth) {
                columnWidth = width;
            }
        }
        // increment the sectionsWith
        sectionsWidth += columnWidth;
        
        columnHeaderAttributes.frame = CGRectMake(sectionMinX, self.collectionView.contentOffset.y + self.columnGroupHeaderHeight + self.collectionView.contentInset.top, columnWidth, self.columnHeaderHeight);
        columnHeaderAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindColumnHeader];
        
        
        // Vertical Gridline
        if (needsToPopulateVerticalGridlineAttributes) {
            NSIndexPath *verticalGridlineIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *verticalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineIndexPath ofKind:TKCollectionElementKindVerticalGridline withItemCache:self.verticalGridlineAttributes];
            CGFloat verticalGridlineHeight = self.collectionViewContentSize.height;
            CGFloat verticalGridlineMinX = sectionMinX +  + self.rowHeaderWidth;// nearbyintf(sectionMinX - self.sectionMargin.left);
            verticalGridlineAttributes.frame = CGRectMake(verticalGridlineMinX, gridMinY, self.verticalGridlineWidth, verticalGridlineHeight);
            verticalGridlineAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindVerticalGridline];
        }
        
        NSIndexPath *verticalGridlineIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *separatorAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineIndexPath ofKind:TKCollectionElementKindVerticalGridlineSeparator withItemCache:self.columnHeaderSeparatorAttributes];
        separatorAttributes.frame = CGRectMake(sectionMinX + self.rowHeaderWidth, self.collectionView.contentOffset.y + self.columnGroupHeaderHeight + self.collectionView.contentInset.top, self.verticalGridlineWidth, self.columnHeaderHeight);
        separatorAttributes.zIndex = [self zIndexForElementKind:TKCollectionElementKindVerticalGridlineSeparator];
        
        if (needsToPopulateItemAttributes) {
            // Items
            NSMutableArray *sectionItemAttributes = [NSMutableArray new];
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                
                NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForCellAtIndexPath:itemIndexPath withItemCache:self.itemAttributes];
                [sectionItemAttributes addObject:itemAttributes];
                
                CGFloat minY = (item * self.rowHeaderHeight);
                
                CGFloat itemMinY = nearbyintf(minY + gridMinY);
                CGFloat itemMinX = nearbyintf(sectionMinX);
                itemAttributes.frame = CGRectMake(itemMinX, itemMinY, columnWidth, self.rowHeaderHeight);
                
                itemAttributes.zIndex = [self zIndexForElementKind:nil];
            }
        }
    }];
    
    // column groups
    // ask the delegate
    if ([self.delegate respondsToSelector:@selector(numberOfColumnGroupsInCollectionView:layout:)]) {
        // get the groups
        NSInteger numberOfGroups = [self.delegate numberOfColumnGroupsInCollectionView:self.collectionView layout:self];
        
        CGFloat groupsWidth = 0;
        for (NSInteger group = 0; group < numberOfGroups; group ++) {
            
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnsIndexesForGroupAtIndex:)]) {
                NSIndexSet *columnIndexs = [self.delegate collectionView:self.collectionView layout:self columnsIndexesForGroupAtIndex:group];
                
                if (columnIndexs.count) {
                    
                    NSIndexPath *columnsGroupIndexPath = [NSIndexPath indexPathForItem:0 inSection:[columnIndexs firstIndex]];
                    UICollectionViewLayoutAttributes *columnsGroupAttribute = [self layoutAttributesForSupplementaryViewAtIndexPath:columnsGroupIndexPath ofKind:TKCollectionElementKindColumnGroupHeader withItemCache:self.columnGroupHeaderAttributes];
                    CGFloat groupMinX = groupsWidth + gridContentMinX;
                    __block CGFloat groupWidth = 0;
                    [columnIndexs enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
                        groupWidth += [self widthOfSection:section];
                    }];
                    
                    groupsWidth += groupWidth;
                    
                    columnsGroupAttribute.frame = CGRectMake(groupMinX, self.collectionView.contentOffset.y + self.collectionView.contentInset.top, groupWidth, self.columnGroupHeaderHeight);
                    
                    columnsGroupAttribute.zIndex = [self zIndexForElementKind:TKCollectionElementKindColumnGroupHeader];
                    
                    // adjust the Vertical Gridlines
                    NSIndexPath *verticalGridlineFirstIndexPath = [NSIndexPath indexPathForItem:0 inSection:columnIndexs.firstIndex];
                    UICollectionViewLayoutAttributes *verticalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineFirstIndexPath ofKind:TKCollectionElementKindVerticalGridlineSeparator withItemCache:self.columnHeaderSeparatorAttributes];
                    CGRect frame = verticalGridlineAttributes.frame;
                    frame.origin.y -= self.columnHeaderHeight;
                    frame.size.height += self.columnGroupHeaderHeight;
                    verticalGridlineAttributes.frame = frame;
                    
                    // adjust the Vertical Gridlines
                    NSInteger lastIndex = columnIndexs.lastIndex;
                    if (lastIndex == self.collectionView.numberOfSections - 1) {
                        
                    } else {
                        NSIndexPath *verticalGridlineLastIndexPath = [NSIndexPath indexPathForItem:0 inSection:columnIndexs.lastIndex+1];
                        UICollectionViewLayoutAttributes *verticalGridlineLastAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineLastIndexPath ofKind:TKCollectionElementKindVerticalGridlineSeparator withItemCache:self.columnHeaderSeparatorAttributes];
                        frame = verticalGridlineLastAttributes.frame;
                        frame.origin.y -= self.columnHeaderHeight;
                        frame.size.height += self.columnGroupHeaderHeight;
                        verticalGridlineLastAttributes.frame = frame;
                    }
                }
            }
        }
    }
}

- (CGSize)collectionViewContentSize {
    CGFloat width;
    CGFloat height;
    height = self.columnHeaderHeight + self.columnGroupHeaderHeight + (self.rowHeaderHeight * [self.collectionView numberOfItemsInSection:0]);
    width = (self.rowHeaderWidth + [self sectionsWidth] + self.rowFooterWidth);
    return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == TKCollectionElementKindColumnHeader) {
        return self.columnHeaderAttributes[indexPath];
    }
    else if (kind == TKCollectionElementKindColumnGroupHeader) {
        return self.columnGroupHeaderAttributes[indexPath];
    }
    else if (kind == TKCollectionElementKindRowHeader) {
        return self.rowHeaderAttributes[indexPath];
    }
    else if (kind == TKCollectionElementKindRowFooter) {
        return self.rowFooterAttributes[indexPath];
    }
    else if (kind == TKCollectionElementKindRowHeaderOriginCell) {
        return self.rowHeaderOriginCellAttributes;
    }
    else if (kind == TKCollectionElementKindRowFooterOriginCell) {
        return self.rowFooterOriginCellAttributes;
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    if (decorationViewKind == TKCollectionElementKindVerticalGridline) {
        return self.verticalGridlineAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindHorizontalGridline) {
        return self.horizontalGridlineAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindRowHeaderBackground) {
        return self.rowHeaderBackgroundAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindColumnHeaderBackground) {
        return self.columnHeaderBackgroundAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindHorizontalRowHeaderSeparator) {
        return self.rowHeaderSeparatorAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindHorizontalRowFooterSeparator) {
        return self.rowFooterSeparatorAttributes[indexPath];
    }
    else if (decorationViewKind == TKCollectionElementKindVerticalGridlineSeparator) {
        return self.columnHeaderSeparatorAttributes[indexPath];
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableIndexSet *visibleSections = [NSMutableIndexSet indexSet];
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)] enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        CGRect sectionRect = [self rectForSection:section];
        if (CGRectIntersectsRect(sectionRect, rect)) {
            [visibleSections addIndex:section];
        }
    }];
    
    // Update layout for only the visible sections
    [self prepareSectionLayoutForSections:visibleSections];
    
    // Return the visible attributes (rect intersection)
    NSArray *visibleAttributes = [self.allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, layoutAttributes.frame);
    }]];
    
    return visibleAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // Required for sticky headers
    return YES;
}


#pragma mark - TKGradebookCollectionViewLayout

- (void)initialize {
    self.needsToPopulateAttributesForAllSections = YES;
    
    self.cachedColumnWidth = CGFLOAT_MIN;
    
    self.registeredDecorationClasses = [NSMutableDictionary new];
    
    self.allAttributes = [NSMutableArray new];
    self.itemAttributes = [NSMutableDictionary new];
    
    self.columnHeaderAttributes = [NSMutableDictionary new];
    self.columnHeaderBackgroundAttributes = [NSMutableDictionary new];
    
    self.columnGroupHeaderAttributes = [NSMutableDictionary new];
    self.columnGroupHeaderBackgroundAttributes = [NSMutableDictionary new];
    
    self.rowHeaderAttributes = [NSMutableDictionary new];
    self.rowHeaderBackgroundAttributes = [NSMutableDictionary new];
    
    self.rowFooterAttributes = [NSMutableDictionary new];
    self.rowFooterBackgroundAttributes = [NSMutableDictionary new];
    
    self.verticalGridlineAttributes = [NSMutableDictionary new];
    self.horizontalGridlineAttributes = [NSMutableDictionary new];
    
    self.rowHeaderSeparatorAttributes = [NSMutableDictionary new];
    self.rowFooterSeparatorAttributes = [NSMutableDictionary new];
    self.columnHeaderSeparatorAttributes = [NSMutableDictionary new];
    
    self.rowHeaderHeight = 60.0;
    self.rowHeaderWidth = 150.0;
    self.rowFooterHeight = 60.0;
    self.rowFooterWidth = 150.0;
    self.columnHeaderHeight = 30.0;
    self.columnHeaderWidth = 150.0;
    self.columnGroupHeaderHeight = 30.0;
    self.columnGroupHeaderWidth = 150.0;
    self.verticalGridlineWidth = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    self.horizontalGridlineHeight = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    
    self.displayHeaderBackgroundAtOrigin = YES;
}

#pragma mark - Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache {
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (self.registeredDecorationClasses[kind] && !(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
 
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache {
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForCellAtIndexPath:(NSIndexPath *)indexPath withItemCache:(NSMutableDictionary *)itemCache {
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
    
    return layoutAttributes;
}

- (void)invalidateLayoutCache {
    self.needsToPopulateAttributesForAllSections = YES;
    
    self.cachedColumnWidth = CGFLOAT_MIN;
    
    // Invalidate cached item attributes
    [self.itemAttributes removeAllObjects];
    
    [self.verticalGridlineAttributes removeAllObjects];
    [self.horizontalGridlineAttributes removeAllObjects];
    
    [self.rowHeaderSeparatorAttributes removeAllObjects];
    [self.rowFooterSeparatorAttributes removeAllObjects];
    
    [self.columnHeaderSeparatorAttributes removeAllObjects];
    
    [self.columnHeaderAttributes removeAllObjects];
    [self.columnHeaderBackgroundAttributes removeAllObjects];
    [self.columnGroupHeaderAttributes removeAllObjects];
    [self.columnGroupHeaderBackgroundAttributes removeAllObjects];
    [self.rowHeaderAttributes removeAllObjects];
    [self.rowHeaderBackgroundAttributes removeAllObjects];
    [self.rowFooterAttributes removeAllObjects];
    [self.rowFooterBackgroundAttributes removeAllObjects];
    [self.allAttributes removeAllObjects];
}


#pragma mark Section Sizing

- (CGRect)rectForSection:(NSInteger)section {
    CGRect sectionRect;
    CGFloat calendarGridMinX = (self.rowHeaderWidth);
    CGFloat sectionWidth = [self widthOfSection:section];
    CGFloat sectionMinX = (calendarGridMinX + [self minXOfSection:section]);
    sectionRect = CGRectMake(sectionMinX, 0.0, sectionWidth, self.collectionViewContentSize.height);
    
    return sectionRect;
}

- (CGFloat)sectionsWidth {
    
    if (self.cachedColumnWidth == CGFLOAT_MIN) {
        CGFloat sections = 0.0;
        for (NSInteger idx = 0; idx < self.collectionView.numberOfSections; idx ++) {
            sections += [self widthOfSection:idx];
        }
        
        if (sections != 0.0) {
            self.cachedColumnWidth = sections;
        }
    }
    
    return self.cachedColumnWidth;
}

- (CGFloat)widthOfSection:(NSInteger)section {
    CGFloat sectionWidth = self.columnHeaderWidth;
    // asks the delegat for the column width
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:widthForColumnHeaderInSection:)]) {
        CGFloat width = [self.delegate collectionView:self.collectionView layout:self widthForColumnHeaderInSection:section];
        if (width > sectionWidth) {
            sectionWidth = width;
        }
    }
    
    return sectionWidth;
}

- (CGFloat)minXOfSection:(NSInteger)section {
    // calculate all width before that section
    CGFloat sections = 0.0;
    for (NSInteger idx = 0; idx < section; idx ++) {
        sections += [self widthOfSection:idx];
    }
    
    return sections;
}

#pragma mark Z Index

- (CGFloat)zIndexForElementKind:(NSString *)elementKind{
    // Row Header
    if (elementKind == TKCollectionElementKindRowHeader) {
        return (TKCollectionMinOverlayZ + 8.0);
    }
    if (elementKind == TKCollectionElementKindRowHeaderOriginCell || elementKind == TKCollectionElementKindRowHeaderOriginCell) {
        return (TKCollectionMinOverlayZ + 18.0);
    }
    // Row Header Background
    else if (elementKind == TKCollectionElementKindRowHeaderBackground) {
        return (TKCollectionMinOverlayZ + 5);
    }
    // Row Footer
    else if (elementKind == TKCollectionElementKindRowFooter) {
        return (TKCollectionMinOverlayZ + 8.0);
    }
    // Row Footer Background
    else if (elementKind == TKCollectionElementKindRowFooterBackground) {
        return (TKCollectionMinOverlayZ + 5);
    }
    // Column Header
    else if (elementKind == TKCollectionElementKindColumnHeader) {
        return (TKCollectionMinOverlayZ);
    }
    // Column Group Header
    else if (elementKind == TKCollectionElementKindColumnGroupHeader) {
        return (TKCollectionMinOverlayZ);
    }
    // Column Group Header
    else if (elementKind == TKCollectionElementKindVerticalGridlineSeparator) {
        return (TKCollectionMinOverlayZ + 1);
    }
    // Column Group Header Background
    else if (elementKind == TKCollectionElementKindColumnGroupHeaderBackground) {
        return (TKCollectionMinBackgroundZ + 5);
    }
    // Column Header Background
    else if (elementKind == TKCollectionElementKindColumnHeaderBackground) {
        return (TKCollectionMinBackgroundZ + 5.0);
    }
    // Cell
    else if (elementKind == nil) {
        return TKCollectionMinCellZ;
    }
    // Vertical Gridline
    else if (elementKind == TKCollectionElementKindVerticalGridline) {
        return (TKCollectionMinBackgroundZ);
    }
    // Horizontal Gridline
    else if (elementKind == TKCollectionElementKindHorizontalGridline) {
        return TKCollectionMinBackgroundZ;
    }
    // Row Header Separator
    else if (elementKind == TKCollectionElementKindHorizontalRowHeaderSeparator || elementKind == TKCollectionElementKindHorizontalRowFooterSeparator) {
        return (TKCollectionMinOverlayZ + 12);
    }
    
    return CGFLOAT_MIN;
}




@end
