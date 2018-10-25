//
//  ViewControllerOne.m
//  TestRAC
//
//  Created by MacBook on 2018/10/24.
//  Copyright © 2018年 AiTeng. All rights reserved.
//
#import "ViewControllerOne.h"

@interface ViewControllerOne ()

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, copy) NSString *userName;

@property (weak, nonatomic) IBOutlet UILabel *decribText;

@end

@implementation ViewControllerOne


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     1.账号和密码都是6-16位，由数字、字母和下划线组成。
     2.账号和密码输入框在输入符合规则的时候高亮、否则置灰。
     3.账号和密码都符合规则的时候登录按钮才可用，否则置灰不可点击。
     4.登录时登录按钮不可用，并提示登录信息。
     **/
    
    [self logoinExample];
    
}

#pragma mark - 登录流程
- (void)logoinExample
{
    //监听两个输入信号，然后进行过滤
    RACSignal *validUserNameSignal = [self.usernameTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        //map转为新的内容
        if (value.length>17) {
          self.usernameTextField.text = [value substringToIndex:17];
        }
        return @([self isValid:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValid:value]);
    }];
    
//    GPWeakSelf(self);
//    [[self.usernameTextField.rac_textSignal filter:^BOOL(NSString* value) {
//        GPStrongSelf(self);
//        //过滤
//        if (value.length>17) {
//            self.usernameTextField.text = [value substringToIndex:17];
//        }
//        return value.length >5;
//    }] subscribeNext:^(id x) {
//        GPStrongSelf(self);
//        self.decribText.text = x;
//        NSLog(@"%@",x);
//    }];
    
    //
    RAC(self.usernameTextField, backgroundColor) = [validUserNameSignal map:^id _Nullable(id  _Nullable value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor groupTableViewBackgroundColor];
    }];
    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^id _Nullable(id  _Nullable value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor groupTableViewBackgroundColor];
    }];
    
    //Signals能够用来导出状态,RAC通过signals and operations让表示属性变得有可能
    
    //连接两个属性的值,只有当两个属性的值满足一定的条件时,按钮才可以被点击
    RAC(self , signInButton.enabled) = [[RACSignal combineLatest:@[validUserNameSignal,validPasswordSignal] reduce:^(NSNumber * first ,NSNumber *second){
          return @([first boolValue] && [second boolValue]);
    }] flattenMap:^__kindof RACSignal * _Nullable(NSNumber   *value) {
        NSLog(@"xxx: %ld",[value integerValue]);
        //再转换成一个新的信号
        self.signInButton.backgroundColor = value.boolValue == YES ? [UIColor redColor]:[UIColor grayColor];
        return [RACSignal return:value];
    }];
    
    //监听按钮点击的事件
    [[[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
    //附加操作，并不返回一个值
    }] flattenMap:^id(id value) {
        //信号转换
        return [self loginSignal];
    }]
     subscribeNext:^(NSDictionary *reult) {
         //订阅注册信号，
         NSString *message = [reult valueForKey:@"message"];
         self.decribText.text = message;
       
     }];
    
}
//添加一个判断账号或密码输入有效的方法
- (BOOL)isValid:(NSString *)str {
    /*
     给密码定一个规则：由字母、数字和_组成的6-16位字符串
     */
    NSString *regularStr = @"[a-zA-Z0-9_]{6,16}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", regularStr];
    return [predicate evaluateWithObject:str];
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password comletion:(void (^)(bool success, NSDictionary *responseDic))comletion {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([userName isEqualToString:@"guodaxia"]) {
            if ([password isEqualToString:@"123456"]) {
                comletion(YES, @{@"userName": userName, @"password": password, @"code": @(0), @"message": @"登录成功"});
            } else {
                comletion(YES, @{@"userName": userName, @"password": password, @"code": @(1), @"message": @"密码错误"});
            }
        } else {
            if ([userName isEqualToString:@"daxia666"])
            {//用账号模拟网络请求失败
                comletion(NO,  @{@"code": @(3), @"message": @"网络出错"});
            } else {
                comletion(YES, @{@"userName": userName, @"password": password, @"code": @(2), @"message": @"账号不存在"});
            }
        }
    });
}

#pragma mark - 创建一个登录请求的信息
- (RACSignal *)loginSignal
{
    GPWeakSelf(self);
    RACSignal *request1 = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        GPStrongSelf(self);
        // 发送请求2
        [self loginWithUserName:self.usernameTextField.text password:self.passwordTextField.text comletion:^(bool success, NSDictionary *responseDic) {
            if (success) {
                NSLog(@"%@", responseDic[@"message"]);
                if ([responseDic[@"code"] integerValue] == 0) {
                    [subscriber sendNext:@{@"success": @(YES), @"message": responseDic[@"message"]}];
                } else {
                    [subscriber sendNext:@{@"success": @(NO), @"message": responseDic[@"message"]}];
                }
            } else {
                NSString *message = @"请求失败";
                NSLog(@"%@", message);
                [subscriber sendNext:@{@"success": @(NO), @"message": message}];
            }
            [subscriber sendCompleted];
        }];
        
        return nil;
        
    }] throttle:2.0];
    
    return request1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
