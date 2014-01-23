//
//  HTLinkLabel.h
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-22.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTLabel.h"

/**
 *  展示链接并做出反应的类
 */
@interface HTLinkLabel : HTLabel

@property (readonly, nonatomic, strong) NSArray *linkRanges;

@property (readwrite, nonatomic, copy) BOOL (^URLHandler)(NSRange,NSURL *);
@property (readwrite, nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end
