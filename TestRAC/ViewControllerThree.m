//
//  ViewControllerThree.m
//  TestRAC
//
//  Created by 郭大侠 on 2018/10/25.
//  Copyright © 2018年 AiTeng. All rights reserved.
//

#import "ViewControllerThree.h"

@interface ViewControllerThree ()

@property (weak, nonatomic) IBOutlet UITextField *showTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation ViewControllerThree

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.showTextField.text = self.toString;
    GPWeakSelf(self);
    [[self.confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        GPStrongSelf(self);
        if (self.delegateSignal) {
            [self.delegateSignal sendNext:[NSString stringWithFormat:@"就是我，回传数据 %@",self.showTextField.text]];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
