//
//  TKGradebookStudentRowHeader.h
//  TeacherKit
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKGradebookStudentRowHeader : UICollectionReusableView

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) NSString *studentName;

@end
@interface TKGradebookStudentRowHeaderBackground : UICollectionReusableView
@end

@interface TKGradebookStudentRowFooter : UICollectionReusableView

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) NSString *studentName;

@end
@interface TKGradebookStudentRowFooterBackground : UICollectionReusableView
@end
