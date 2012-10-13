//
//  MWCTViewBase.m
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWCTViewBase.h"
#import "MWHelloCT.h"
#import <CoreGraphics/CoreGraphics.h>


@implementation MWCTViewBase


- (void)drawRect:(MWRect)rect inView:(id)view
{
    [[MWColor whiteColor] set];
    MWRectFill(rect);
    
    // Needed for flipping coordinates vertically.
    CGFloat viewHeight = [view frame].size.height;

    CGContextRef context = MW_CURRENT_GRAPHICS_CONTEXT;

    // Save state before flipping.
    CGContextSaveGState(context);
    
    if (MW_VIEW_FLIPPED)
    {
        // Flip coordinate system vertically.
        CGContextTranslateCTM(context, 0.0, viewHeight);
        CGContextScaleCTM(context, 1.0f, -1.0f);
    }

    MWHelloCT *hello = [[MWHelloCT alloc] init];
    hello.context = context;
    hello.viewHeight = viewHeight;
    
    // Use convenience method on UIColor and NSColor to create a CGColor.
    hello.textColor = [MWColor blackColor].CGColor;
    hello.highlightColor = [MWColor redColor].CGColor;
    [hello drawLineWithString:@"Hello Core Text!"];

    hello.textColor = [MWColor whiteColor].CGColor;
    [hello drawFrameWithString:@"The Quick Brown Fox Jumps Over The Lazy Dog. And so the story goes on and on. We still need more text, so let’s add a few meaningless words."];

    // Restore state after we are done.
    CGContextRestoreGState(context);
}


@end
