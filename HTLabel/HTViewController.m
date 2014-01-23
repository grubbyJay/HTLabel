//
//  HTViewController.m
//  HTLabel
//
//  Created by wb-shangguanhaitao on 14-1-22.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTViewController.h"
#import "HTLinkLabel.h"

@interface HTViewController ()

@end

@implementation HTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *string = @"http://t.cnwojfowagoiegioewgwioegoigoigogggo";
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [mutableAttributedString addAttributes:@{kMarkupLinkAttributeName: string
                                             }
                                     range:NSMakeRange(0, string.length)];
    NSAttributedString *attributedString = [NSAttributedString normalizeString:mutableAttributedString
                                                                      settings:nil];
    HTLinkLabel *linkLabel = [[HTLinkLabel alloc] initWithFrame:CGRectMake(100.0f, 100.0f, 120.0f, 100.0f)];
    CGSize aSize = [HTLinkLabel sizeForString:attributedString
                            constrainedToSize:linkLabel.frame.size];
    linkLabel.frame = CGRectMake(CGRectGetMinX(linkLabel.frame), CGRectGetMinY(linkLabel.frame), aSize.width, aSize.height);
    linkLabel.attributedText = attributedString;
    [self.view addSubview:linkLabel];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        linkLabel.attributedText = nil;
    });
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
