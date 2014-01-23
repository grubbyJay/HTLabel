//
//  NSAttributedString_Extensions.m
//  CoreText
//
//  Created by Jonathan Wight on 1/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSAttributedString_Extensions.h"

#import "UIFont_CoreTextExtensions.h"

NSString *const kMarkupLinkAttributeName = @"com.touchcode.link";
NSString *const kMarkupBoldAttributeName = @"com.touchcode.bold";
NSString *const kMarkupItalicAttributeName = @"com.touchcode.italic";
NSString *const kMarkupSizeAdjustmentAttributeName = @"com.touchcode.sizeAdjustment";
NSString *const kMarkupFontNameAttributeName = @"com.touchcode.fontName";
NSString *const kShadowColorAttributeName = @"com.touchcode.shadowColor";
NSString *const kShadowOffsetAttributeName = @"com.touchcode.shadowOffset";
NSString *const kShadowBlurRadiusAttributeName = @"com.touchcode.shadowBlurRadius";
NSString *const kMarkupAttachmentAttributeName = @"com.touchcode.attachment";
NSString *const kMarkupBackgroundColorAttributeName = @"com.touchcode.backgroundColor";
NSString *const kMarkupStrikeColorAttributeName = @"com.touchcode.strikeColor";
NSString *const kMarkupOutlineAttributeName = @"com.touchcode.outline";

@implementation NSAttributedString (NSAttributedString_Extensions)

+ (NSAttributedString *)normalizedAttributedStringForAttributedString:(NSAttributedString *)inAttributedString baseFont:(UIFont *)inBaseFont
    {
    NSMutableAttributedString *theString = [inAttributedString mutableCopy];
    
    [theString enumerateAttributesInRange:(NSRange){ .length = theString.length } options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        UIFont *theFont = inBaseFont;
        CTFontRef theCTFont = (__bridge CTFontRef)attrs[(__bridge NSString *)kCTFontAttributeName];
        if (theCTFont != NULL)
            {
            theFont = [UIFont fontWithCTFont:theCTFont];
            }
        
        attrs = [self normalizeAttributes:attrs baseFont:theFont];
        [theString setAttributes:attrs range:range];
        }];
    return(theString);
    }

+ (NSDictionary *)normalizeAttributes:(NSDictionary *)inAttributes baseFont:(UIFont *)inBaseFont
    {
    NSMutableDictionary *theAttributes = [inAttributes mutableCopy];
        
    // NORMALIZE ATTRIBUTES
    UIFont *theBaseFont = inBaseFont;
    NSString *theFontName = theAttributes[kMarkupFontNameAttributeName];
    if (theFontName != NULL)
        {
        theBaseFont = [UIFont fontWithName:theFontName size:inBaseFont.pointSize];
        [theAttributes removeObjectForKey:kMarkupFontNameAttributeName];
        }
    
    UIFont *theFont = theBaseFont;
    
    BOOL theBoldFlag = [theAttributes[kMarkupBoldAttributeName] boolValue];
    if (theAttributes[kMarkupBoldAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupBoldAttributeName];
        }

    BOOL theItalicFlag = [theAttributes[kMarkupItalicAttributeName] boolValue];
    if (theAttributes[kMarkupItalicAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupItalicAttributeName];
        }
    
    if (theBoldFlag == YES && theItalicFlag == YES)
        {
        theFont = theBaseFont.boldItalicFont;
        }
    else if (theBoldFlag == YES)
        {
        theFont = theBaseFont.boldFont;
        }
    else if (theItalicFlag == YES)
        {
        theFont = theBaseFont.italicFont;
        }

    if (theAttributes[kMarkupOutlineAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupOutlineAttributeName];
		theAttributes[(__bridge NSString *)kCTStrokeWidthAttributeName] = @(3.0);
        }

    NSNumber *theSizeValue = theAttributes[kMarkupSizeAdjustmentAttributeName];
    if (theSizeValue != NULL)
        {
        CGFloat theSize = [theSizeValue floatValue];
        theFont = [theFont fontWithSize:theFont.pointSize + theSize];
        
        [theAttributes removeObjectForKey:kMarkupSizeAdjustmentAttributeName];
        }

    if (theFont != NULL)
        {
        theAttributes[(__bridge NSString *)kCTFontAttributeName] = (__bridge id)theFont.CTFont;
        }
        
    return(theAttributes);
    }

+ (CTParagraphStyleRef)createParagraphStyleForAttributes:(NSDictionary *)inAttributes alignment:(CTTextAlignment)inTextAlignment lineBreakMode:(CTLineBreakMode)inLineBreakMode
{
    CGFloat theFirstLineHeadIndent;
    CGFloat theHeadIndent;
    CGFloat theTailIndent;
    CFArrayRef theTabStops;
    CGFloat theDefaultTabInterval;
    CGFloat theLineHeightMultiple;
    CGFloat theMaximumLineHeight;
    CGFloat theMinimumLineHeight;
    CGFloat theLineSpacing;
    CGFloat theParagraphSpacing;
    CGFloat theParagraphSpacingBefore;
    CTWritingDirection theBaseWritingDirection;
    CGFloat lineSpacingAdjustment;
    
    BOOL createdCurrentStyle = NO;
    CTParagraphStyleRef currentParagraphStyle = (__bridge CTParagraphStyleRef)inAttributes[(__bridge NSString *)kCTParagraphStyleAttributeName];
    if (currentParagraphStyle == NULL)
    {
        // Create default style
        currentParagraphStyle = CTParagraphStyleCreate(NULL, 0);
        createdCurrentStyle = YES;
    }
    
    // Grab all but the alignment and line break mode
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(theFirstLineHeadIndent), &theFirstLineHeadIndent);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(theHeadIndent), &theHeadIndent);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierTailIndent, sizeof(theTailIndent), &theTailIndent);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierTabStops, sizeof(theTabStops), &theTabStops);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(theDefaultTabInterval), &theDefaultTabInterval);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(theLineHeightMultiple), &theLineHeightMultiple);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(theMaximumLineHeight), &theMaximumLineHeight);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(theMinimumLineHeight), &theMinimumLineHeight);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(theLineSpacing), &theLineSpacing);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(theParagraphSpacing), &theParagraphSpacing);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(theParagraphSpacingBefore), &theParagraphSpacingBefore);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(theBaseWritingDirection), &theBaseWritingDirection);
    CTParagraphStyleGetValueForSpecifier(currentParagraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpacingAdjustment), &lineSpacingAdjustment);
    
    CFRetain(theTabStops);
    
    if (createdCurrentStyle)
    {
        CFRelease(currentParagraphStyle);
    }
    
    CTParagraphStyleSetting newSettings[] = {
        { .spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(inTextAlignment), .value = &inTextAlignment, },
        { .spec = kCTParagraphStyleSpecifierFirstLineHeadIndent, .valueSize = sizeof(theFirstLineHeadIndent), .value = &theFirstLineHeadIndent, },
        { .spec = kCTParagraphStyleSpecifierHeadIndent, .valueSize = sizeof(theHeadIndent), .value = &theHeadIndent, },
        { .spec = kCTParagraphStyleSpecifierTailIndent, .valueSize = sizeof(theTailIndent), .value = &theTailIndent, },
        { .spec = kCTParagraphStyleSpecifierTabStops, .valueSize = sizeof(theTabStops), .value = &theTabStops, },
        { .spec = kCTParagraphStyleSpecifierDefaultTabInterval, .valueSize = sizeof(theDefaultTabInterval), .value = &theDefaultTabInterval, },
        { .spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(inLineBreakMode), .value = &inLineBreakMode, },
        { .spec = kCTParagraphStyleSpecifierLineHeightMultiple, .valueSize = sizeof(theLineHeightMultiple), .value = &theLineHeightMultiple, },
        { .spec = kCTParagraphStyleSpecifierMaximumLineHeight, .valueSize = sizeof(theMaximumLineHeight), .value = &theMaximumLineHeight, },
        { .spec = kCTParagraphStyleSpecifierMinimumLineHeight, .valueSize = sizeof(theMinimumLineHeight), .value = &theMinimumLineHeight, },
        { .spec = kCTParagraphStyleSpecifierLineSpacing, .valueSize = sizeof(theLineSpacing), .value = &theLineSpacing, },
        { .spec = kCTParagraphStyleSpecifierParagraphSpacing, .valueSize = sizeof(theParagraphSpacing), .value = &theParagraphSpacing, },
        { .spec = kCTParagraphStyleSpecifierParagraphSpacingBefore, .valueSize = sizeof(theParagraphSpacingBefore), .value = &theParagraphSpacingBefore, },
        { .spec = kCTParagraphStyleSpecifierBaseWritingDirection, .valueSize = sizeof(theBaseWritingDirection), .value = &theBaseWritingDirection, },
        { .spec = kCTParagraphStyleSpecifierLineSpacingAdjustment, .valueSize = sizeof(lineSpacingAdjustment), .value = &lineSpacingAdjustment, },
    };
    
    CTParagraphStyleRef newStyle = CTParagraphStyleCreate( newSettings, sizeof(newSettings)/sizeof(CTParagraphStyleSetting) );
    CFRelease(theTabStops);
    return newStyle;
}

+ (NSAttributedString *)normalizeString:(NSAttributedString *)inString settings:(id)inSettings
{
    UIFont *theFont = [inSettings valueForKey:@"font"] ?: [UIFont systemFontOfSize:17.0];
    
    NSMutableAttributedString *theMutableText = [[NSAttributedString normalizedAttributedStringForAttributedString:inString baseFont:theFont] mutableCopy];
    
    UIColor *theTextColor = [inSettings valueForKey:@"textColor"] ?: [UIColor blackColor];
    [theMutableText enumerateAttributesInRange:(NSRange){ .length = theMutableText.length } options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs[(__bridge NSString *)kCTFontAttributeName] == NULL)
        {
            [theMutableText addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)theFont.CTFont range:range];
        }
        if (attrs[(__bridge NSString *)kCTForegroundColorAttributeName] == NULL)
        {
            [theMutableText addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(__bridge id)theTextColor.CGColor range:range];
        }
    }];
    
    if ([[inSettings valueForKey:@"highlighted"] boolValue] == YES)
    {
        UIColor *theHighlightColor = [inSettings valueForKey:@"highlightedTextColor"];
        [theMutableText addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(__bridge id)theHighlightColor.CGColor range:(NSRange){ .length = theMutableText.length }];
    }
    
    UIColor *theShadowColor = [inSettings valueForKey:@"shadowColor"];
    if (theShadowColor != NULL && [[inSettings valueForKey:@"enabled"] boolValue] == YES)
    {
        NSMutableDictionary *theShadowAttributes = [NSMutableDictionary dictionary];
        theShadowAttributes[kShadowColorAttributeName] = (__bridge id)theShadowColor.CGColor;
        
        NSValue *theShadowOffset = [inSettings valueForKey:@"shadowOffset"];
        theShadowAttributes[kShadowOffsetAttributeName] = theShadowOffset;
        
        NSNumber *theShadowBlueRadius = [inSettings valueForKey:@"shadowBlurRadius"];
        theShadowAttributes[kShadowBlurRadiusAttributeName] = theShadowBlueRadius;
        
        [theMutableText addAttributes:theShadowAttributes range:(NSRange){ .length = [theMutableText length] }];
    }
    
    CTTextAlignment theTextAlignment;
    switch ([[inSettings valueForKey:@"textAlignment"] integerValue])
    {
        case NSTextAlignmentCenter:
            theTextAlignment = kCTCenterTextAlignment;
            break;
        case NSTextAlignmentRight:
            theTextAlignment = kCTRightTextAlignment;
            break;
        case NSTextAlignmentLeft:
        default:
            theTextAlignment = kCTLeftTextAlignment;
            break;
    }
    
    // NSLineBreakMode maps 1:1 to CTLineBreakMode
    CTLineBreakMode theLineBreakMode = (CTLineBreakMode)[[inSettings valueForKey:@"lineBreakMode"] unsignedIntegerValue];
    
    [theMutableText enumerateAttributesInRange:(NSRange){ .length = theMutableText.length } options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        CTParagraphStyleRef newParagraphStyle = [self createParagraphStyleForAttributes:attrs alignment:theTextAlignment lineBreakMode:theLineBreakMode];
        [theMutableText addAttribute:(__bridge NSString *)kCTParagraphStyleAttributeName value:(__bridge id)newParagraphStyle range:range];
        CFRelease(newParagraphStyle);
    }];
    
    return(theMutableText);
}
    
@end
