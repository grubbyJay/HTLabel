//
//  HTLinkLabel.m
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-22.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTLinkLabel.h"

@interface HTLinkLabel ()

@property (readwrite, nonatomic, strong) NSArray *linkRanges;

@end

@implementation HTLinkLabel

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) != NULL)
    {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tapRecognizer.enabled = NO;
        [self addGestureRecognizer:_tapRecognizer];
    }
    return(self);
}

- (id)initWithCoder:(NSCoder *)inCoder
{
    if ((self = [super initWithCoder:inCoder]) != NULL)
    {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tapRecognizer.enabled = NO;
        [self addGestureRecognizer:_tapRecognizer];
    }
    return(self);
}

- (void)setAttributedText:(NSAttributedString *)inText
{
    if (self.attributedText != inText)
    {
        [super setAttributedText:inText];
        
        NSMutableArray *theRanges = [NSMutableArray array];
        [self.attributedText enumerateAttribute:kMarkupLinkAttributeName inRange:(NSRange){ .length = self.attributedText.length } options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value != NULL)
            {
                [theRanges addObject:[NSValue valueWithRange:range]];
            }
        }];
        self.linkRanges = [theRanges copy];
        
        self.tapRecognizer.enabled = self.linkRanges.count > 0;
    }
}

#pragma mark -

- (void)tap:(UITapGestureRecognizer *)inGestureRecognizer
{
    CGPoint theLocation = [inGestureRecognizer locationInView:self];
    theLocation.x -= 0.0f;
    theLocation.y -= 0.0f;
    
    NSRange theRange;
    NSDictionary *theAttributes = [self attributesAtPoint:theLocation effectiveRange:&theRange];
    NSURL *theLink = theAttributes[kMarkupLinkAttributeName];
    if (theLink != NULL)
    {
        if (self.URLHandler != NULL)
        {
            self.URLHandler(theRange, theLink);
        }
    }
}

@end
