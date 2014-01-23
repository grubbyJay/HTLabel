//
//  HTCoreTextRenderer.m
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-22.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTRenderer.h"

@interface HTRenderer ()

/**
 *  要绘制的attributedString
 */
@property (nonatomic, copy)     NSAttributedString *text;

/**
 *  可以绘制的最大区域
 */
@property (nonatomic, assign)   CGSize size;

/**
 *  绘制之前对一些区块的内容做些操作
 */
@property (readwrite, nonatomic, strong) NSMutableDictionary *prerenderersForAttributes;

/**
 *  绘制之后对一些区块的内容做些操作
 */
@property (readwrite, nonatomic, strong) NSMutableDictionary *postRenderersForAttributes;

/**
 *  每一行的原地位置
 */
@property (readwrite, nonatomic, assign) CGPoint *lineOrigins;

/**
 *  每一行的Data数据
 */
@property (readwrite, nonatomic, strong) NSMutableData *lineOriginsData;

/**
 *  这两个变量，看苹果文档哈~~
 */
@property (readwrite, nonatomic, assign) CTFramesetterRef framesetter;
@property (readwrite, nonatomic, assign) CTFrameRef frame;

@end

@implementation HTRenderer

#pragma mark - Dealloc API

- (void)dealloc
{
    if (_frame)
    {
        CFRelease(_frame);
        _frame = NULL;
    }
    
    if (_framesetter)
    {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
}

#pragma mark - Set & Get API

- (CTFramesetterRef)framesetter
{
    if (_framesetter == NULL && self.text != NULL)
    {
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.text);
        if (_framesetter == NULL)
        {
            NSLog(@"Could not create CTFramesetter");
        }
    }
    return(_framesetter);
}

- (CTFrameRef)frame
{
    if (_frame == NULL && self.text != NULL)
    {
        CGPathRef thePath = CGPathCreateWithRect((CGRect){ .size = self.size }, NULL);
        
        _frame = CTFramesetterCreateFrame(self.framesetter, (CFRange){}, thePath, NULL);
        
        if (_frame == NULL)
        {
            NSLog(@"Could not create CTFrameRef");
        }
        
        CFRelease(thePath);
    }
    return(_frame);
}

- (void)setText:(NSAttributedString *)inText
{
    if (_text != inText)
    {
        _text = [inText copy];
        
        [self reset];
    }
}

- (void)setSize:(CGSize)inSize
{
    _size = inSize;
    
    [self reset];
}

- (CGPoint *)lineOrigins
{
    if (_lineOriginsData == NULL)
    {
        NSArray *theLines = (__bridge NSArray *)CTFrameGetLines(self.frame);
        
        _lineOriginsData = [NSMutableData dataWithLength:sizeof(CGPoint) * theLines.count];
        CTFrameGetLineOrigins(self.frame, (CFRange){}, [_lineOriginsData mutableBytes]);
    }
    return([_lineOriginsData mutableBytes]);
}

#pragma mark - Private API

- (void)reset
{
    if (_frame)
    {
        CFRelease(_frame);
        self.frame = NULL;
    }
    
    if (_framesetter)
    {
        CFRelease(_framesetter);
        self.framesetter = NULL;
    }
    
    self.lineOrigins = NULL;
    self.lineOriginsData = NULL;
}

/**
 *  枚举每行，并对其进行处理
 *
 *  @param inHandler 处理的区块
 */
- (void)enumerateLines:(void (^)(CTLineRef line, NSUInteger idx, BOOL *stop))inHandler
{
    NSParameterAssert(inHandler != NULL);
    
    // ### Iterate through each line...
    NSArray *theLines = (__bridge NSArray *)CTFrameGetLines(self.frame);
    [theLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CTLineRef theLine = (__bridge CTLineRef)obj;
        inHandler(theLine, idx, stop);
    }];
}

/**
 *  枚举每行中的Run区域，并对其进行处理
 *
 *  @param inHandler 处理的区块
 */
- (void)enumerateRuns:(void (^)(CTRunRef, CGRect))inHandler
{
    NSParameterAssert(inHandler != NULL);
    
    // ### Iterate through each line...
    [self enumerateLines:^(CTLineRef line, NSUInteger idx, BOOL *stop) {
        // ### Get the line rect offseting it by the line origin
        const CGPoint theLineOrigin = self.lineOrigins[idx];
        
        // ### Iterate each run... Keeping track of our X position...
        __block CGFloat theXPosition = 0;
        NSArray *theRuns = (__bridge NSArray *)CTLineGetGlyphRuns(line);
        [theRuns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx2, BOOL *stop2) {
            CTRunRef theRun = (__bridge CTRunRef)obj;
            
            // ### Get the ascent, descent, leading, width and produce a rect for the run...
            CGFloat theAscent, theDescent, theLeading;
            double theWidth = CTRunGetTypographicBounds(theRun, (CFRange){}, &theAscent, &theDescent, &theLeading);
            CGRect theRunRect = {
                .origin = { theLineOrigin.x + theXPosition, theLineOrigin.y - theDescent },
                .size = { (CGFloat)theWidth, theAscent + theDescent },
            };
            
            inHandler(theRun, theRunRect);
            
            theXPosition += theWidth;
        }];
    }];
}

#pragma mark - Public API

+ (CGSize)sizeForString:(NSAttributedString *)inString
               thatFits:(CGSize)inSize
{
    if (inString == NULL)
    {
        NSLog(@"Could not create CTFramesetter");
        return(CGSizeZero);
    }
    
    CTFramesetterRef theFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)inString);
    if (theFramesetter == NULL)
    {
        NSLog(@"Could not create CTFramesetter");
        return(CGSizeZero);
    }
    
    CGSize theSize = CTFramesetterSuggestFrameSizeWithConstraints(theFramesetter, (CFRange){}, NULL, inSize, NULL);
    CFRelease(theFramesetter);
    
    if (inSize.width < CGFLOAT_MAX && inSize.height == CGFLOAT_MAX)
    {
        theSize.width = inSize.width;
    }
    
    // On iOS 5.0 the function `CTFramesetterSuggestFrameSizeWithConstraints` returns rounded float values (e.g. "15.0").
    // Prior to iOS 5.0 the function returns float values (e.g. "14.7").
    // Make sure the return value for `sizeForString:thatFits:" is equal for both versions:
    theSize = (CGSize){ .width = ceilf(theSize.width), .height = ceilf(theSize.height) };
    
    return(theSize);
}

- (NSArray *)rectsForRange:(CFRange)inRange
{
    NSMutableArray *theRects = [NSMutableArray array];
    
    [self enumerateRuns:^(CTRunRef inRun, CGRect inRect) {
        
        //    NSIntersectionRange(inRange,
        
        CFRange theRunRange = CTRunGetStringRange(inRun);
        if (theRunRange.location >= (CFIndex)inRange.location && theRunRange.location <= (CFIndex)inRange.location + (CFIndex)inRange.length)
        {
            inRect.origin.y *= -1;
            inRect.origin.y += self.size.height -  inRect.size.height;
            
            [theRects addObject:[NSValue valueWithCGRect:inRect]];
        }
    }];
    
    return(theRects);
}

- (NSDictionary *)attributesAtPoint:(CGPoint)inPoint effectiveRange:(CFRange *)outRange
{
    const NSUInteger theIndex = [self indexAtPoint:inPoint];
    if (theIndex == NSNotFound || theIndex >= self.text.length)
    {
        return(NULL);
    }
    else
    {
        NSDictionary *theAttributes = [self.text attributesAtIndex:theIndex effectiveRange:(NSRange *)outRange];
        return(theAttributes);
    }
}

- (NSUInteger)indexAtPoint:(CGPoint)inPoint
{
    inPoint.y *= -1;
    inPoint.y += self.size.height;
    
    __block CGPoint theLastLineOrigin = (CGPoint){ 0, CGFLOAT_MAX };
    __block CFIndex theIndex = NSNotFound;
    
    [self enumerateLines:^(CTLineRef line, NSUInteger idx, BOOL *stop) {
        CGPoint theLineOrigin;
        CTFrameGetLineOrigins(self.frame, CFRangeMake((CFIndex)idx, 1), &theLineOrigin);
        
        if (inPoint.y > theLineOrigin.y && inPoint.y < theLastLineOrigin.y)
        {
            theIndex = CTLineGetStringIndexForPosition(line, (CGPoint){ .x = inPoint.x - theLineOrigin.x, inPoint.y - theLineOrigin.y });
            if (theIndex != NSNotFound && (NSUInteger)theIndex < self.text.length)
            {
                *stop = YES;
            }
        }
        theLastLineOrigin = theLineOrigin;
    }];
    
    return((NSUInteger)theIndex);
}

- (void)addPrerendererBlock:(void (^)(CGContextRef, CTRunRef, CGRect))inBlock
            forAttributeKey:(NSString *)inKey
{
    if (self.prerenderersForAttributes == NULL)
    {
        self.prerenderersForAttributes = [NSMutableDictionary dictionary];
    }
    
    (self.prerenderersForAttributes)[inKey] = [inBlock copy];
}

- (void)addPostRendererBlock:(void (^)(CGContextRef, CTRunRef, CGRect))inBlock
             forAttributeKey:(NSString *)inKey
{
    if (self.postRenderersForAttributes == NULL)
    {
        self.postRenderersForAttributes = [NSMutableDictionary dictionary];
    }
    
    (self.postRenderersForAttributes)[inKey] = [inBlock copy];
}

- (void)drawInContext:(CGContextRef)inContext
    forAttributedText:(NSAttributedString *)inString
               inSize:(CGSize)inSize
{
    self.text = inString;
    self.size = inSize;
    
    
    if (self.text.length == 0)
    {
        return;
    }
    
    // ### Get and set up the context...
    CGContextSaveGState(inContext);
    
    CGContextScaleCTM(inContext, 1.0, -1.0);
    CGContextTranslateCTM(inContext, 0, -self.size.height);
    
    // ### If we have any pre-render blocks we enumerate over the runs and fire the blocks if the attributes match...
    if (self.prerenderersForAttributes.count > 0)
    {
        [self enumerateRuns:^(CTRunRef inRun, CGRect inRect) {
            NSDictionary *theAttributes = (__bridge NSDictionary *)CTRunGetAttributes(inRun);
            [self.prerenderersForAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (theAttributes[key])
                {
                    void (^theBlock)(CGContextRef, CTRunRef, CGRect) = obj;
                    theBlock(inContext, inRun, inRect);
                }
            }];
        }];
    }
    
    // ### Reset the text position (important!)
    CGContextSetTextPosition(inContext, 0, 0);
    
    // ### Render the text...
    const CGPoint *theLineOrigins = self.lineOrigins;
    
    [self enumerateLines:^(CTLineRef line, NSUInteger idx, BOOL *stop) {
        // ### Get the line rect offseting it by the line origin
        const CGPoint theLineOrigin = theLineOrigins[idx];
        
        CGContextSetTextPosition(inContext, theLineOrigin.x, theLineOrigin.y);
        
        // ### Iterate each run... Keeping track of our X position...
        NSArray *theRuns = (__bridge NSArray *)CTLineGetGlyphRuns(line);
        [theRuns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx2, BOOL *stop2) {
            
            CTRunRef theRun = (__bridge CTRunRef)obj;
            
            // TODO: Optimisation instead of constantly saving/restoring state and setting shadow we can keep track of current shadow and only save/restore/set when there's a change.
            NSDictionary *theAttributes = (__bridge NSDictionary *)CTRunGetAttributes(theRun);
            CGColorRef theShadowColor = (__bridge CGColorRef)theAttributes[kShadowColorAttributeName];
            CGSize theShadowOffset = CGSizeZero;
            NSValue *theShadowOffsetValue = theAttributes[kShadowOffsetAttributeName];
            if (theShadowColor != NULL && theShadowOffsetValue != NULL)
            {
                theShadowOffset = [theShadowOffsetValue CGSizeValue];
                
                CGFloat theShadowBlurRadius = [theAttributes[kShadowBlurRadiusAttributeName] floatValue];
                
                CGContextSaveGState(inContext);
                CGContextSetShadowWithColor(inContext, theShadowOffset, theShadowBlurRadius, theShadowColor);
            }
            
            // Render!
            CTRunDraw(theRun, inContext, (CFRange){});
            
            // Restore state if we were in a shadow
            if (theShadowColor != NULL && theShadowOffsetValue != NULL)
            {
                CGContextRestoreGState(inContext);
            }
            
        }];
        
    }];
    
    // ### Reset the text position (important!)
    CGContextSetTextPosition(inContext, 0, 0);
    
    // ### If we have any pre-render blocks we enumerate over the runs and fire the blocks if the attributes match...
    if (self.postRenderersForAttributes.count > 0)
    {
        [self enumerateRuns:^(CTRunRef inRun, CGRect inRect) {
            NSDictionary *theAttributes = (__bridge NSDictionary *)CTRunGetAttributes(inRun);
            [self.postRenderersForAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (theAttributes[key])
                {
                    void (^theBlock)(CGContextRef, CTRunRef, CGRect) = obj;
                    theBlock(inContext, inRun, inRect);
                }
            }];
        }];
    }
    
    CGContextRestoreGState(inContext);
    
    // ### Now that the CTM is restored. Iterate through each line and render any attachments.
    [self enumerateRuns:^(CTRunRef inRun, CGRect inRect) {
        NSDictionary *theAttributes = (__bridge NSDictionary *)CTRunGetAttributes(inRun);
        // ### If we have an image we draw it...
        CCoreTextAttachment *theAttachment = theAttributes[kMarkupAttachmentAttributeName];
		if (theAttachment != NULL)
        {
			inRect.origin.y *= -1;
			inRect.origin.y += self.size.height - inRect.size.height;
			inRect = UIEdgeInsetsInsetRect(inRect, theAttachment.insets);
            
			if (theAttachment.type == kCoreTextAttachmentType_Renderer)
            {
				CoreTextAttachmentRenderer theRenderer = theAttachment.representedObject;
				theRenderer(theAttachment, inContext, inRect);
            }
			else
            {
//				CGContextStrokeRect(inContext, inRect);
            }
        }
    }];

}

@end
