//
//  TKGradebookGradableItemColumnHeader.h
//  TeacherKit
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKGradebookGradableItemColumnHeader : UICollectionReusableView

@property (nonatomic, strong) NSString *gradableItemTitle;

@end

@interface TKGradebookGradableItemColumnHeaderBackground : UICollectionReusableView
@end



@interface TKGradebookCategoryColumnHeader : UICollectionReusableView

@property (nonatomic, strong) NSString *categoryTitle;

@end

@interface TKGradebookCategoryColumnHeaderBackground : UICollectionReusableView
@end
