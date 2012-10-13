//
//  MWCTUIView.m
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWCTUIView.h"
#import "MWCTViewBase.h"


@implementation MWCTUIView
{
    MWCTViewBase *_viewBase;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }

    return self;
}


- (void)awakeFromNib
{
    _viewBase = [[MWCTViewBase alloc] init];
}


- (void)drawRect:(CGRect)rect
{
    [_viewBase drawRect:rect inView:self];
}


@end
