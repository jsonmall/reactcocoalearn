//
//  ViewControllerThree.h
//  TestRAC
//
//  Created by 郭大侠 on 2018/10/25.
//  Copyright © 2018年 AiTeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerThree : UIViewController

@property (nonatomic, strong) RACSubject *delegateSignal;

@property (nonatomic, copy) NSString *toString;

@end
