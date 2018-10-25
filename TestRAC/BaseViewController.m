//
//  BaseViewController.m
//  TestRAC
//
//  Created by 郭大侠 on 2018/10/25.
//  Copyright © 2018年 AiTeng. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewControllerOne.h"
#import "ViewController.h"
#import "ViewControllerThree.h"


@interface BaseViewController ()



@end

@implementation BaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (IBAction)clickBtn:(UIButton *)sender {
    // 1.获取当前的StoryBoard面板
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 2.通过标识符找到对应的页面
    ViewControllerThree *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ViewControllerThree"];
    
    vc.delegateSignal = [RACSubject subject];
    vc.toString = sender.titleLabel.text;
    
    [vc.delegateSignal subscribeNext:^(id  _Nullable x) {
            NSLog(@"点击了通知按钮 --%@,",x);
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
