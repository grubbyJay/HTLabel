//
//  HTCoreTextRenderer.h
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-22.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CCoreTextAttachment.h"
#import "NSAttributedString_Extensions.h"
#import "UIColor+Hex.h"
#import "UIFont_CoreTextExtensions.h"
#import "UIImage+AnimatedConveniences.h"

/**
 *  负责富文本渲染的类
 */
@interface HTRenderer : NSObject

/**
 *  获取绘制富文本所需的实际Size
 *
 *  @param inString NSAttributedString 实例
 *  @param inSize   绘制最大能达到的区域
 *
 *  @return 实际的绘制size
 */
+ (CGSize)sizeForString:(NSAttributedString *)inString
               thatFits:(CGSize)inSize;

/**
 *  在固定范围内各个run的rect
 *
 *  @param inRange 指定范围
 *
 *  @return 一个run的rect数组
 */
- (NSArray *)rectsForRange:(CFRange)inRange;

/**
 *  获取某点的文本是属性，以及这个属性相连的范围
 *
 *  @param inPoint  文本内的某点
 *  @param outRange 具有这点属性的相连的部分
 *
 *  @return 返回文本某点的所有属性
 */
- (NSDictionary *)attributesAtPoint:(CGPoint)inPoint
                     effectiveRange:(CFRange *)outRange;

/**
 *  获得文本某点在整个文本中的位置
 *
 *  @param inPoint 文本中的某点
 *
 *  @return 返回文本某点在整个文本中的位置
 */
- (NSUInteger)indexAtPoint:(CGPoint)inPoint;

/**
 *  绘制之前对一些区块的内容做些操作
 *
 *  @param inBlock 用Block的形式处理某个区块
 *  @param inKey   针对的是attribute的某个属性
 */
- (void)addPrerendererBlock:(void (^)(CGContextRef, CTRunRef, CGRect))inBlock
            forAttributeKey:(NSString *)inKey;

/**
 *  绘制之后对一些区块的内容做些操作
 *
 *  @param inBlock 用Block的形式处理某个区块
 *  @param inKey   针对的是attribute的某个属性
 */
- (void)addPostRendererBlock:(void (^)(CGContextRef, CTRunRef, CGRect))inBlock
             forAttributeKey:(NSString *)inKey;


/**
 *  富文本渲染
 *
 *  @param inContext      绘画上下文
 *  @param attributedText NSAttributedString 实例
 *  @param inSize         绘制最大能达到的区域
 */
- (void)drawInContext:(CGContextRef)inContext
    forAttributedText:(NSAttributedString *)inString
               inSize:(CGSize)inSize;

@end
