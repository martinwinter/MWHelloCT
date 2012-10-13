//
//  MWCTNSView.m
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWCTNSView.h"
#import "MWCTViewBase.h"


@implementation MWCTNSView
{
    MWCTViewBase *_viewBase;
}


- (id)initWithFrame:(NSRect)frame
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


- (void)drawRect:(NSRect)dirtyRect
{
    [_viewBase drawRect:dirtyRect inView:self];
}


@end
