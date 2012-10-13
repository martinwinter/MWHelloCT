//
//  MWCTViewBase.h
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

// Define things that are different between UIView and NSView so we can use one
// shared view base class.
#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

typedef UIColor                         MWColor;
typedef CGRect                          MWRect;

#define MWRectFill(rect)                UIRectFill(rect)
#define MW_VIEW_FLIPPED                 YES
#define MW_CURRENT_GRAPHICS_CONTEXT     UIGraphicsGetCurrentContext()

#else // OS X

#import <Cocoa/Cocoa.h>

typedef NSColor                         MWColor;
typedef NSRect                          MWRect;

#define MWRectFill(rect)                NSRectFill(rect)
#define MW_VIEW_FLIPPED                 NO
#define MW_CURRENT_GRAPHICS_CONTEXT     [[NSGraphicsContext currentContext] graphicsPort]

#endif


@interface MWCTViewBase : NSObject

- (void)drawRect:(MWRect)rect inView:(id)view;

@end
