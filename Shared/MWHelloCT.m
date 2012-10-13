//
//  MWHelloCT.m
//  MWHelloCT
//
//  Created by Martin Winter on 09.09.12.
//  Copyright (c) 2012 Martin Winter. All rights reserved.
//

#import "MWHelloCT.h"

// This is more complicated before OS X 10.8 (sub-framework of 
// ApplicationServices).
#import <CoreText/CoreText.h>


// Don’t recreate the font descriptor but keep it around.
static CTFontDescriptorRef _fontDescriptor;


@implementation MWHelloCT


+ (void)initialize
{
    // A font can be registered only once. Registering it again would cause an
    // error.
    if (_fontDescriptor == NULL)
    {
        // Free and fairly nice font from <http://www.google.com/webfonts>.
        NSString *fontName = @"Lato-Regular";
        
        // Start with Obj-C objects because they are much easier to use.
        NSURL *fontURL = [[NSBundle mainBundle] URLForResource:fontName 
                                                 withExtension:@"ttf" 
                                                  subdirectory:@"Fonts"];

        // Cast NSURL to CFURL and pass to CF function.
        // Do not change ownership.
        CFErrorRef error;
        bool success = CTFontManagerRegisterFontsForURL(
                                                        (__bridge CFURLRef)(fontURL), 
                                                        kCTFontManagerScopeProcess, 
                                                        &error
                                                        );
        if (!success)
        {
            // Cast CFError to NSError and use in Obj-C. 
            // Do not change ownership.
            NSLog(@"%s  %@", __PRETTY_FUNCTION__, 
                  [(__bridge NSError *)(error) localizedDescription]);
            return;
        }
        
        // Pass point size 0.0 to create descriptor without explicit size.
        _fontDescriptor = CTFontDescriptorCreateWithNameAndSize(
                              (__bridge CFStringRef)(fontName), 
                              0.0
                                                                );
        if (!_fontDescriptor)
        {
            NSLog(@"%s  Failed to create font descriptor.", __PRETTY_FUNCTION__);
            return;
        }
    }
}


- (void)drawLineWithString:(NSString *)string
{
    CGFloat pointSize = 36.0;
    
    // Pass concrete point size. NULL indicates identity transformation matrix.
    CTFontRef font = CTFontCreateWithFontDescriptor(
                                                    _fontDescriptor, 
                                                    pointSize, 
                                                    NULL
                                                    );
    
    /*
     This function is the easiest way to create a Core Text font on iOS if you
     have added a UIAppFonts key to the Info.plist. You don’t need a font
     descriptor then, but a font descriptor offers other advantages.
     
     CTFontRef font = CTFontCreateWithName(
                                           CFSTR("Lato-Regular"), 
                                           pointSize, 
                                           NULL
                                           );
     */
    
    // In some circumstances, the text matrix gets overwritten inappropriately.
    // Reset it explicitly to the identity matrix.
    CGContextSetTextMatrix(self.context, CGAffineTransformIdentity);
    
    // Use NSDictionary to create attributes dictionary because it is much 
    // easier. It also allows the use of collection literals and boxing.
    // Cast CF object (CTFont) with no corresponding Obj-C class (not toll-free 
    // bridged) simply to id.
    NSDictionary *initialAttributes = (
        @{
            (NSString *)kCTFontAttributeName            : (__bridge id)font,
            (NSString *)kCTKernAttributeName            : @(-0.5),
            (NSString *)kCTForegroundColorAttributeName : (__bridge id)self.textColor
          }
                                       );
    
    // Ditto with NSMutableAttributedString.
    NSMutableAttributedString *attributedString = 
        [[NSMutableAttributedString alloc] initWithString:string
                                               attributes:initialAttributes];
    
    // Let string itself determine the range of the substring whose attributes 
    // we want to modify.
    NSRange coreTextRange = [string rangeOfString:@"Core Text"];
    
    // Cast CF property to id. No need for transfer keyword because that is
    // already determined by the property declaration.
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                             value:(__bridge id)self.highlightColor
                             range:coreTextRange];

    CTLineRef line = CTLineCreateWithAttributedString(
        (__bridge CFAttributedStringRef)attributedString);

    // Since the line will draw itself starting at the baseline but we want to
    // specify the top left corner, get the height of capital letters.
    CGFloat capHeight = CTFontGetCapHeight(font);

    // Offset text position by cap height (see above). Also, take care of 
    // vertically flipped coordinate system by using a convenience method.
    CGContextSetTextPosition(
                             self.context, 
                             20.0, 
                             [self flippedVerticalCoordinate:20.0 + capHeight]
                             );

    CTLineDraw(line, self.context);

    // Manage memory for CF objects we created ourselves.
    CFRelease(line);
    CFRelease(font);
}


- (void)drawFrameWithString:(NSString *)string
{
    // Create font with different size from existing font descriptor.
    CGFloat pointSize = 24.0;
    CTFontRef font = CTFontCreateWithFontDescriptor(
                                                    _fontDescriptor, 
                                                    pointSize, 
                                                    NULL
                                                    );
    
    CGContextSetTextMatrix(self.context, CGAffineTransformIdentity);
    
    NSDictionary *initialAttributes = (
        @{
            (NSString *)kCTFontAttributeName            : (__bridge id)font,
            (NSString *)kCTForegroundColorAttributeName : (__bridge id)self.textColor
          }
                                       );
    
    NSMutableAttributedString *attributedString = 
    [[NSMutableAttributedString alloc] initWithString:string
                                           attributes:initialAttributes];
    
    // For typesetting a frame, we should create a paragraph style.
    // Includes fix for CTFramesetter’s wrong line spacing behavior.
    // See Technical Q&A QA1698: “How do I work-around an issue where some lines
    // in my Core Text output have extra line spacing?”

    // Center alignment looks best when filling an ellipse.
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    
    // This is the leading in the historical sense, which is added to the point
    // size but does not include it like the line height does.
    CGFloat leading = 4.0;
    
    // Still, for the fix we do need the line height.
    CGFloat lineHeight = pointSize + leading;
    
    CTParagraphStyleSetting paragraphStyleSettings[] =
    {
        {
            kCTParagraphStyleSpecifierAlignment,
            sizeof(alignment),
            &alignment
        },
        
        {
            kCTParagraphStyleSpecifierLineBreakMode,
            sizeof(lineBreakMode),
            &lineBreakMode
        },
        
        // These two specifiers fix the line spacing when set to line height.
        {
            kCTParagraphStyleSpecifierMinimumLineHeight,
            sizeof(lineHeight),
            &lineHeight
        },
        
        {
            kCTParagraphStyleSpecifierMaximumLineHeight,
            sizeof(lineHeight),
            &lineHeight
        }

        // Very important: Do not set kCTParagraphStyleSpecifierLineSpacing too,
        // or it will be added again!
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(
        paragraphStyleSettings,
        sizeof(paragraphStyleSettings) / sizeof(paragraphStyleSettings[0])
                                                                );
    
    // Apply paragraph style to entire string. This cannot be done when the
    // string is empty, by the way, because attributes can only be applied to
    // existing characters.
    NSRange stringRange = NSMakeRange(0, [attributedString length]);
    
    [attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName 
                             value:(__bridge id)(paragraphStyle) 
                             range:stringRange];
    
    // Create ellipse bezier path to contain our text.
    CGMutablePathRef path = CGPathCreateMutable();

    CGRect rect = CGRectMake(
                             20.0, 
                             20.0,
                             250.0, 
                             250.0
                             );
    
    CGPathAddEllipseInRect(path, NULL, rect);
    
    // Fill ellipse below the text.
    CGContextSetFillColorWithColor(self.context, self.highlightColor);
    CGContextAddPath(self.context, path);
    CGContextFillPath(self.context);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(
        (__bridge CFAttributedStringRef)(attributedString));
    
    // Range with length 0 indicates that we want to typeset until we run out of
    // text or space.
    CTFrameRef frame = CTFramesetterCreateFrame(
                                                framesetter, 
                                                CFRangeMake(0, 0), 
                                                path, 
                                                NULL
                                                );
    
    CTFrameDraw(frame, self.context);
    
    CFRelease(font);
    CFRelease(framesetter);
    
    // Use specialized release function when it exists.
    CGPathRelease(path);
}


- (CGFloat)flippedVerticalCoordinate:(CGFloat)verticalCoordinate
{
    return self.viewHeight - verticalCoordinate;
}


@end
