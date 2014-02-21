//
//  TKGradebookStudentRowHeader.m
//  TeacherKit
//
//  Created by Ahmad AlMoraly on 2/19/14.
//  Copyright (c) 2014 ITWorx. All rights reserved.
//

#import "TKGradebookStudentRowHeader.h"

@implementation TKGradebookStudentRowHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.title = [[UILabel alloc] initWithFrame:self.bounds];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:12.0];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
        
        UIView *title = self.title;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(title)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(title)]];
        
    }
    return self;
}

- (void)setStudentName:(NSString *)studentName {
    _studentName = studentName;
    
    self.title.text = studentName;
    [self setNeedsLayout];
}

@end
@implementation TKGradebookStudentRowHeaderBackground

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

@end

@implementation TKGradebookStudentRowFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.title = [[UILabel alloc] initWithFrame:self.bounds];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:12.0];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
        
    }
    return self;
}


- (void)setStudentName:(NSString *)studentName {
    _studentName = studentName;
    
    self.title.text = studentName;
    [self setNeedsLayout];
}

@end

@implementation TKGradebookStudentRowFooterBackground

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

@end
