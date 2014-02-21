//
//  TKMultiColumnCollectionViewController.m
//  TKMultiColumnTableCollectionView
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import "TKMultiColumnCollectionViewController.h"
#import "TKGradebookStudentRowHeader.h"
#import "TKGradebookGradableItemColumnHeader.h"
#import "TKGradebookGridline.h"
#import "TKMultiColumnCollectionViewLayout.h"

NSString * const TKCellReuseIdentifier = @"cell";
NSString * const TKGradableItemColumnHeaderReuseIdentifier = @"TKGradableItemColumnHeaderReuseIdentifier";
NSString * const TKGradableItemColumnGroupHeaderReuseIdentifier = @"TKGradableItemColumnGroupHeaderReuseIdentifier";
NSString * const TKStudentRowHeaderReuseIdentifier = @"TKStudentRowHeaderReuseIdentifier";
NSString * const TKStudentRowFooterReuseIdentifier = @"TKStudentRowFooterReuseIdentifier";

NSString * const TKGradableItemColumnHeaderReuseIdentifierBackground = @"TKGradableItemColumnHeaderReuseIdentifierBackground";
NSString * const TKGradableItemColumnGroupHeaderReuseIdentifierBackground = @"TKGradableItemColumnGroupHeaderReuseIdentifierBackground";
NSString * const TKStudentRowHeaderReuseIdentifierBackground = @"TKStudentRowHeaderReuseIdentifierBackground";
NSString * const TKStudentRowFooterReuseIdentifierBackground = @"TKStudentRowFooterReuseIdentifierBackground";

NSString * const TKStudentRowHeaderOriginCellReuseIdentifier = @"TKStudentRowHeaderOriginCellReuseIdentifier";
NSString * const TKStudentRowFooterOriginCellReuseIdentifier = @"TKStudentRowFooterOriginCellReuseIdentifier";


@interface TKMultiColumnCollectionViewController () <TKMultiColumnCollectionViewLayoutDelegate>

@property (nonatomic, weak) TKMultiColumnCollectionViewLayout *gridLayout;

@end

@implementation TKMultiColumnCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.gridLayout = (TKMultiColumnCollectionViewLayout *)self.collectionViewLayout;
    self.gridLayout.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    [self.collectionView registerClass:TKGradebookStudentRowHeader.class forSupplementaryViewOfKind:TKCollectionElementKindRowHeader withReuseIdentifier:TKStudentRowHeaderReuseIdentifier];
    
    [self.collectionView registerClass:TKGradebookStudentRowHeader.class forSupplementaryViewOfKind:TKCollectionElementKindRowHeaderOriginCell withReuseIdentifier:TKStudentRowHeaderOriginCellReuseIdentifier];
    [self.collectionView registerClass:TKGradebookStudentRowHeader.class forSupplementaryViewOfKind:TKCollectionElementKindRowFooterOriginCell withReuseIdentifier:TKStudentRowFooterOriginCellReuseIdentifier];
    
    [self.collectionView registerClass:[TKGradebookStudentRowHeader class] forSupplementaryViewOfKind:TKCollectionElementKindRowFooter withReuseIdentifier:TKStudentRowFooterReuseIdentifier];
    
    [self.collectionView registerClass:TKGradebookGradableItemColumnHeader.class forSupplementaryViewOfKind:TKCollectionElementKindColumnHeader withReuseIdentifier:TKGradableItemColumnHeaderReuseIdentifier];
    
    [self.collectionView registerClass:TKGradebookGradableItemColumnHeader.class forSupplementaryViewOfKind:TKCollectionElementKindColumnGroupHeader withReuseIdentifier:TKGradableItemColumnGroupHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.gridLayout registerClass:TKGradebookStudentRowHeaderBackground.class forDecorationViewOfKind:TKCollectionElementKindRowHeaderBackground];
    
    [self.gridLayout registerClass:TKGradebookStudentRowFooterBackground.class forDecorationViewOfKind:TKCollectionElementKindRowFooterBackground];
    
    [self.gridLayout registerClass:TKGradebookGradableItemColumnHeaderBackground.class forDecorationViewOfKind:TKCollectionElementKindColumnHeaderBackground];
    
    [self.gridLayout registerClass:TKGradebookCategoryColumnHeaderBackground.class forDecorationViewOfKind:TKCollectionElementKindColumnGroupHeaderBackground];

    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindHorizontalGridline];
    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindVerticalGridline];
    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindVerticalLastGridline];
    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindHorizontalRowHeaderSeparator];
    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindHorizontalRowFooterSeparator];
    [self.gridLayout registerClass:TKGradebookGridline.class forDecorationViewOfKind:TKCollectionElementKindVerticalGridlineSeparator];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 100;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:TKCellReuseIdentifier forIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == TKCollectionElementKindColumnHeader) {
        TKGradebookGradableItemColumnHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKGradableItemColumnHeaderReuseIdentifier forIndexPath:indexPath];
        header.gradableItemTitle = [NSString stringWithFormat:@"GradableItem #%li", (long)indexPath.section];
        view = header;
    }
    else if (kind == TKCollectionElementKindColumnGroupHeader) {
        TKGradebookGradableItemColumnHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKGradableItemColumnGroupHeaderReuseIdentifier forIndexPath:indexPath];
        header.gradableItemTitle = [NSString stringWithFormat:@"Group #%li", (long)indexPath.section];
        view = header;
    }
    else if (kind == TKCollectionElementKindRowHeader) {
        TKGradebookStudentRowHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKStudentRowHeaderReuseIdentifier forIndexPath:indexPath];
        header.studentName = @"Ahmad AlMoraly";
        view = header;
    }
    else if (kind == TKCollectionElementKindRowFooter) {
        TKGradebookStudentRowHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKStudentRowFooterReuseIdentifier forIndexPath:indexPath];
        header.studentName = @"A+";
        view = header;
    }
    else if (kind == TKCollectionElementKindRowHeaderOriginCell) {
        TKGradebookStudentRowHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKStudentRowHeaderOriginCellReuseIdentifier forIndexPath:indexPath];
        header.studentName = @"Student";
        header.backgroundColor = [UIColor whiteColor];
        view = header;
    }
    else if (kind == TKCollectionElementKindRowFooterOriginCell) {
        TKGradebookStudentRowHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TKStudentRowFooterOriginCellReuseIdentifier forIndexPath:indexPath];
        header.studentName = @"Total";
        header.backgroundColor = [UIColor whiteColor];
        view = header;
    }
    return view;
}


-(NSInteger)numberOfColumnGroupsInCollectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout *)collectionViewLayout {
    return 20;
}

- (NSIndexSet *)collectionView:(UICollectionView *)collectionView layout:(TKMultiColumnCollectionViewLayout *)collectionViewLayout columnsIndexesForGroupAtIndex:(NSInteger)groupIndex {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(groupIndex*5, 5)];
}

@end
