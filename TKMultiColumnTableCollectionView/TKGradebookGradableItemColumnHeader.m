//
//  TKGradebookGradableItemColumnHeader.m
//  TeacherKit
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import "TKGradebookGradableItemColumnHeader.h"

@interface TKGradebookGradableItemColumnHeader ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;

@end

@implementation TKGradebookGradableItemColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleBackground = [UIView new];
        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
        [self addSubview:self.titleBackground];
        
        self.backgroundColor = [UIColor clearColor];
        self.title = [[UILabel alloc] initWithFrame:self.bounds];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
    }
    return self;
}

- (void)setGradableItemTitle:(NSString *)gradableItemTitle {
    _gradableItemTitle = gradableItemTitle;
    
    self.title.text = gradableItemTitle;
    
    [self setNeedsLayout];
}

@end

@implementation TKGradebookGradableItemColumnHeaderBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

@end


@interface TKGradebookCategoryColumnHeader ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;

@end

@implementation TKGradebookCategoryColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleBackground = [UIView new];
        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
        [self addSubview:self.titleBackground];
        
        self.backgroundColor = [UIColor clearColor];
        self.title = [[UILabel alloc] initWithFrame:self.bounds];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
    }
    return self;
}

- (void)setCategoryTitle:(NSString *)categoryTitle {
    _categoryTitle = categoryTitle;
    
    self.title.text = categoryTitle;
    
    [self setNeedsLayout];
}

@end

@implementation TKGradebookCategoryColumnHeaderBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

@end