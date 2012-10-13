//
//  MWHelloCT.h
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import <Foundation/Foundation.h>


// Declaring properties (implicitly) as atomic causes the compiler to use
// objc_getProperty and objc_setProperty instead of a simple assign.
// Declaring a typedef instead of putting __attribute__((NSObject)) directly
// into the property declaration causes the compiler to set the property to nil
// in the dealloc method using objc_storeStrong.
// See also http://stackoverflow.com/questions/9684972/strong-property-with-attribute-nsobject-for-a-cf-type-doesnt-retain/9690656#9690656


typedef __attribute__((NSObject)) CGContextRef MWContextRef;
typedef __attribute__((NSObject)) CGColorRef MWColorRef;


@interface MWHelloCT : NSObject

// Treat CF properties like Obj-C objects.
@property (strong) MWContextRef context;
@property (strong) MWColorRef textColor;
@property (strong) MWColorRef highlightColor;

@property (assign) CGFloat viewHeight; // Needed for flipping coordinates.

- (void)drawLineWithString:(NSString *)string;
- (void)drawFrameWithString:(NSString *)string;

@end
