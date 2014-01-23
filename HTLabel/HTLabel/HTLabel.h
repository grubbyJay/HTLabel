//
//  HTLabel.h
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-21.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTRenderer.h"

/**
 *  富文本展示控件，基类！！！
 */
@interface HTLabel : UIView

/**
 *  外部提供的NSAttributedString实例类，每次赋值都会跑setNeedsDisplay
 */
@property (nonatomic, strong) NSAttributedString *attributedText;

/**
 *  实际处理绘制操作的类
 */
@property (readonly, nonatomic, strong) HTRenderer *renderer;

/**
 *  根据inText和inSize来获取控件实际的size，这个方法要在setAttributedText:之前使用
 *
 *  @param inText NSAttributedString实例类
 *  @param inSize 控件限制的最大区域
 *
 *  @return 控件的实际的size
 */
+ (CGSize)sizeForString:(NSAttributedString *)inText
      constrainedToSize:(CGSize)inSize;
/**
 *  在固定范围内各个run的rect
 *
 *  @param inRange 指定范围
 *
 *  @return 一个run的rect数组
 */
- (NSArray *)rectsForRange:(NSRange)inRange;

/**
 *  获取某点的文本是属性，以及这个属性相连的范围
 *
 *  @param inPoint  文本内的某点
 *  @param outRange 具有这点属性的相连的部分
 *
 *  @return 返回文本某点的所有属性
 */
- (NSDictionary *)attributesAtPoint:(CGPoint)inPoint
                     effectiveRange:(NSRange *)outRange;


@end
