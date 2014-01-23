//
//  HTLabel.m
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-21.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTLabel.h"

// For conenience CCoreTextRenderer deals with CFRanges, CCoreTextLabel deals with NSRanges.
#define CFRangeToNSRange_(r) ({ const CFRange r_ = (r); (NSRange){ (NSUInteger)r_.location, (NSUInteger)r_.length }; })
#define NSRangeToCFRange_(r) ({ const NSRange r_ = (r); (CFRange){ (CFIndex)r_.location, (CFIndex)r_.length }; })

@interface HTLabel ()

/**
 *  实际处理绘制操作的类
 */
@property (nonatomic, strong) HTRenderer *renderer;

/**
 *  控件是否需要绘制，就靠这个变量了，默认为NO
 */
@property (nonatomic, assign) BOOL needToDraw;

@end

@implementation HTLabel

#pragma mark - Superclass API

/**
 *  控件的初始化
 *
 *  @param frame 控件的初始化大小
 *
 *  @return 返回控件实际类
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; //!< 默认清空背景颜色
        self.renderer = [[HTRenderer alloc] init]; //!< 初始化绘制操作类
        self.needToDraw = NO; //!< 初始为NO
    }
    return self;
}

/**
 *  控件的绘制
 *
 *  @param rect 绘画区域
 */
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //...
    
    /**
     *  _needToDraw 为NO时，不做任何绘制操作
     */
    if (!self.needToDraw)
    {
        return;
    }
    self.needToDraw = NO;
    
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    // ### Get and set up the context...
    CGContextSaveGState(theContext);
    
    // ### Work out the inset bounds...
	CGRect theBounds = self.bounds;
    
    CGContextTranslateCTM(theContext, theBounds.origin.x, theBounds.origin.y);
        
    [self.renderer drawInContext:theContext
               forAttributedText:self.attributedText
                          inSize:theBounds.size];
    
    CGContextRestoreGState(theContext);
}

#pragma mark - Set API

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([_attributedText isEqualToAttributedString:attributedText])
    {
        return;
    }
    _attributedText = attributedText;
    _needToDraw = YES;
    [self setNeedsDisplay];
}

#pragma mark - Public API

+ (CGSize)sizeForString:(NSAttributedString *)inText
      constrainedToSize:(CGSize)inSize
{
    CGSize theSize = [HTRenderer sizeForString:inText
                                              thatFits:inSize];
    return(theSize);
}

- (NSArray *)rectsForRange:(NSRange)inRange
{
    NSMutableArray *theRects = [NSMutableArray array];
	for (NSValue *theRectValue in [self.renderer rectsForRange:NSRangeToCFRange_(inRange)])
    {
		CGRect theRect = [theRectValue CGRectValue];
		theRect.origin.x += 0;
		theRect.origin.y += 0;
		[theRects addObject:[NSValue valueWithCGRect:theRect]];
    }
    
    return(theRects);
}

- (NSDictionary *)attributesAtPoint:(CGPoint)inPoint
                     effectiveRange:(NSRange *)outRange
{
    NSDictionary *theDictionary = [self.renderer attributesAtPoint:inPoint effectiveRange:(CFRange *)outRange];
    return(theDictionary);
}

@end
