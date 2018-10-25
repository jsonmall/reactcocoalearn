//
//  ViewController.m
//  TestRAC
//
//  Created by MacBook on 2018/10/23.
//  Copyright © 2018年 AiTeng. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (nonatomic,strong)NSArray *dataArrString;
@property (nonatomic,strong)NSArray *dataArrNumber;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *describeText;
@property (nonatomic, copy) NSString *userName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    //1.创建一个信号
    
//    [self createRACSignal];
    // 2.测试 map:映射，可以看做对玻璃球的变换、重新组装
//        [self testMap];
    
    // 3.测试 filter:过滤，不符合要求的玻璃球不允许通过
    
//        [self testFilter];
    
    
    
    // 3.测试 concat:把一个水管拼接到另一个水管之后
    
//        [self testConcat];
    
    
    
    // 4.测试 flatten :
    
//        [self testFlattenForConcat];
    
    
    
    //5. 测试 map and flatten
    
//        [self testMapAndFlatten];
    
    
    
    //6. 测试 combine
    
//        [self testCombining];
    
    
    
    //7. 测试 switching
    
//        [self testSwitching];
    
    
    
    //8. 测试RAC RAC可以看作某个属性的值与一些信号的联动
    
//        [self testRAC];
    
    
    
    //9. 测试 RACObserve监听属性的改变，使用block的KVO
    
//        [self testRACObserve];
    
    
    
    // 10.网络测试
    
//        [self testNetwork];
    
    
    
    // 11.实现一个时钟应用
    
//        [self testClockApplication];
    
    
    
    // 12.测试组合 combine
    
//        [self testCombine];
    
    
    
    // 13.测试 RACSubject的使用
    
//        [self testSubject];
    
    
    
    // 14.测试 RACReplaySubject的使用
    
//        [self testReplaySubject];
    
    
    
    //15. 测试 RACTuple和 RACSequence 的使用
    
//        [self testSequenceAndTuple];
    
    
    
    //16. 测试 RACCommand :用于处理事件的类
    
//        [self testCommand];
    
    
    
    //17. 测试 RACMulticastConnection的使用
    
//        [self testMulticastConnection];
    
    
    
    //18. 测试 RAC开发中常见用法
    
//        [self testRACMethod];
    
    
    
    //19 测试 RAC开发中常见宏
    
//    [self testMacroDefinition];
    
    // 20.测试注入效果 -doNext: -doError: -doCompleted:
    
    [self testNextAndCompleted];
    
}

- (void)createRACSignal
{
    // RACSignal使用步骤：
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 - (void)sendNext:(id)value
    
    // RACSignal底层实现：
    // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
    // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
    // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    // 2.1 subscribeNext内部会调用siganl的didSubscribe
    // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
    // 3.1 sendNext底层其实就是执行subscriber的nextBlock
    
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁");
            
        }];
    }];
    
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
        self.describeText.text = [NSString stringWithFormat:@"接收到数据%@",x];
    }];

}


#pragma mark -代表的是一个不可变的值的序列 数组，字典常用语遍历
- (void)RACSequence
{
    RACSequence* letters =self.dataArrString.rac_sequence;
    
    RACSignal* letter = letters.signal;
    
    // 依次输出 A B C D…
    
    [letter subscribeNext:^(NSString* text) {
        
        NSLog(@"text %@",text);
    }];
}

#pragma mark - 测试组合 combine

- (void)testCombine{
    
    // 在必需验证每个所填写的数值符合标准,Button才能点击
    
    RAC(self.loginBtn,selected) = [RACSignal combineLatest:@[self.usernameTextField.rac_textSignal , self.passwordTextField.rac_textSignal] reduce:^id(NSString* username ,NSString* password){
        
        self.loginBtn.enabled = username.length > 6 && password.length >6;
        self.loginBtn.backgroundColor = username.length > 6 && password.length >6 ? [UIColor yellowColor]:[UIColor greenColor];
        return@(username.length >6 && password.length >6);
        
    }];
    
}

#pragma mark - 测试 RAC开发中常见宏

- (void)testMacroDefinition{
    
    /*
     
     8.1 RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定
     
     // 只要文本框文字改变，就会修改label的文字
     
     RAC(self.labelView,text) = _textField.rac_textSignal;
     
     
     
     8.2 RACObserve(self, name):监听某个对象的某个属性,返回的是信号
     
     [RACObserve(self.view, center) subscribeNext:^(id x) {
     
     NSLog(@"%@",x);
     
     }];
     
     
     
     8.3  @weakify(Obj)和@strongify(Obj),一般两个都是配套使用,在主头文件(ReactiveCocoa.h)中并没有导入，需要自己手动导入，RACEXTScope.h才可以使用。但是每次导入都非常麻烦，只需要在主头文件自己导入就好了
     
     
     
     8.4 RACTuplePack：把数据包装成RACTuple（元组类）
     
     // 把参数中的数据包装成元组
     
     RACTuple *tuple = RACTuplePack(@10,@20);
     
     
     
     8.5 RACTupleUnpack：把RACTuple（元组类）解包成对应的数据
     
     // 把参数中的数据包装成元组
     
     RACTuple *tuple = RACTuplePack(@"xmg",@20);
     
     
     
     // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
     
     // name = @"xmg" age = @20
     
     RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
     
     */
    
}

#pragma mark - 测试 RACMulticastConnection的使用 : 用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理

- (void)testMulticastConnection
{
    
    // 使用注意:RACMulticastConnection通过RACSignal的-publish或者-muticast:方法创建
    
    /*
     
     RACMulticastConnection使用步骤:
     
     1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     
     2.创建连接 RACMulticastConnection *connect = [signal publish];
     
     3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
     
     4.连接 [connect connect]
     
     
     
     RACMulticastConnection底层原理:
     
     1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
     
     2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
     
     3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
     
     3.1.订阅原始信号，就会调用原始信号中的didSubscribe
     
     3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
     
     4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
     
     4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
     
     
     
     需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
     
     解决：使用RACMulticastConnection就能解决
     
     */
    
    
    
    // 1.创建请求信号
    
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送请求");
        
        [subscriber sendNext:@1];
        
        return nil;
        
    }];
    
    
    
    // 2.订阅信号
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    
    
    
    // 2.订阅信号
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    
    
    
    //    return;
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    
    // RACMulticastConnection:解决重复请求问题
    
    // 1.创建信号
    
    RACSignal* signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"再次发送请求");
        
        [subscriber sendNext:@1];
        
        return nil;
        
    }];
    
    
    
    // 2.创建连接
    
    RACMulticastConnection* connect = [signal2 publish];
    
    
    
    // 3.订阅信号，
    
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者一信号 %@",x);
        
    }];
    
    
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二信号 %@",x);
        
    }];
    
    
    
    // 4.连接,激活信号
    
    [connect connect];
    
}

#pragma mark - 测试 RACCommand :用于处理事件的类
- (void)testCommand
{
    /*
     
     RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程
  
     一、RACCommand使用步骤:
     
     1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
     
     2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
     
     3.执行命令 - (RACSignal *)execute:(id)input
     
     二、RACCommand使用注意:
     
     1.signalBlock必须要返回一个信号，不能传nil.
     
     2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
     
     3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
     
     4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的
     
 
     三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
     
     1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
     
     2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了
     
    
     四、如何拿到RACCommand中返回信号发出的数据。
     
     1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
     
     2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值
     
     
     五、监听当前命令是否正在执行executing
     
     
     六、使用场景,监听按钮点击，网络请求
     
     */
    
    [self test1Command];
//    [self test2Command];
    
}


- (void)test1Command
{
    // RACCommand: 处理事件
    // 不能返回空的信号
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用
        NSLog(@"%@",input); // input 为执行命令传进来的参数
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    
    // 如何拿到执行命令中产生的数据呢？
    // 订阅命令内部的信号
    // ** 方式一：直接订阅执行命令返回的信号
    
    // 2.执行命令
    RACSignal *signal =[command execute:@6]; // 这里其实用到的是replaySubject 可以先发送命令再订阅
    // 在这里就可以订阅信号了
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

- (void)test2Command
{
    // 1. 创建命令
    
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        // 创建空信号,必须返回信号
        //                return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕
            [subscriber sendCompleted];
            return nil;
            
        }];
        
    }];
    
    // 3.订阅RACCommand中的信号
    
    [command.executionSignals subscribeNext:^(id x) {
        
        [x subscribeNext:^(id x) {
            
            NSLog(@"x : %@",x);
            
        }];
        
    }];
    
    
    
    // RAC高级用法
    
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    
    //    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
    //
    //        NSLog(@"switchToLatest : %@",x);
    //
    //    }];
    
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号
    
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES){
            // 正在执行
            NSLog(@"正在执行");
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
    }];
    // 5. 执行命令
    [command execute:@3];
}
#pragma mark - 测试 RACTuple和 RACSequence 的使用

- (void)testSequenceAndTuple{
    
    /*
     
     RACTuple:元组类,类似NSArray,用来包装值
     
     RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典
     
     使用场景：1.字典转模型
     
     RACSequence和RACTuple简单使用
     
     */
    
    // 1.遍历数组
    
    NSArray *numbers =@[@1,@2,@3,@4];
    
    
    
    // 这里其实是三步
    
    // 第一步:把数组转换成集合RACSequence numbers.rac_sequence
    
    // 第二步:把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    
    // 第三步:订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        
        NSLog(@"x : %@",x);
        
    }];
    
    
    
    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    
    NSDictionary *dict =@{@"name":@"xmg",@"age":@18};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        
        RACTupleUnpack(NSString *key,NSString *value) = x;
        // 相当于以下写法
        
        //        NSString *key = x[0];
        
        //        NSString *value = x[1];
        
        NSLog(@"key : %@ value : %@",key,value);
        
    }];
    
    
    
#pragma mark - 3.字典转模型
    
#pragma mark - 3.1 OC写法
    
    /*
     
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
     NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    
     NSMutableArray *items = [NSMutableArray array];

     for (NSDictionary *dict in dictArr) {
     
     FlagItem *item = [FlagItem flagWithDict:dict];
     
     [items addObject:item];
     
     }
     
     */
#pragma mark - 3.2 RAC写法
    
    /*
     
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];

     NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
     
     NSMutableArray *flags = [NSMutableArray array];
  
     _flags = flags;
     
     // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
     
     [dictArr.rac_sequence.signal subscribeNext:^(id x) {
     
     // 运用RAC遍历字典，x：字典
     
     FlagItem *item = [FlagItem flagWithDict:x];
     
     [flags addObject:item];
    
     }];
     
     */
    
    
    
#pragma mark - 3.3 RAC高级写法:
    
    /*
     
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
     NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
     
     // map:映射的意思，目的：把原始值value映射成一个新值
     
     // array: 把集合转换成数组
     
     // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
     
     NSArray *flags = [[dictArr.rac_sequence map:^id(id value) {

     return [FlagItem flagWithDict:value];
     
     }] array];
     
     */
    
}

#pragma mark - 测试注入效果 -doNext: -doError: -doCompleted:

- (void)testNextAndCompleted{
    
    __block unsigned subscriptions = 0;
    
    RACSignal* loggingSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        subscriptions ++;
        
        [subscriber sendNext:@"eee"];
        
        [subscriber sendCompleted];
        
        return nil;
        
    }];
    
    // 不输出
    
    [loggingSignal doCompleted:^{
        
        NSLog(@"about to complete subscription %u",subscriptions);
        
    }];
    
    // 当有其它地方调用 loggingSignal时会调用
    
    loggingSignal = [loggingSignal doCompleted:^{
        
        NSLog(@"about to complete subscription %u",subscriptions);
        
    }];
    
    // 订阅
    
    [loggingSignal subscribeCompleted:^{

        NSLog(@"subscription %u",subscriptions);

    }];
    
//    [loggingSignal subscribeNext:^(id x) {
//
//        NSLog(@"x %@",x);
//
//    }];
    
}

#pragma mark - 测试 map:映射，可以看做对玻璃球的变换、重新组装

- (void)testMap
{
    
    RACSequence* letters =self.dataArrString.rac_sequence;
    
    RACSequence* mapped = [letters map:^id(NSString* value) {
        
        [self logSource:@"map"text:value];
        
        // 转换后Contains: AA BB CC DD EE FF GG HH II
        
        return [value stringByAppendingString:value];
        
    }];
    
    [mapped.signal subscribeNext:^(NSString* x) {
        
        [self logSource:@"map"text:x];
        
    }];
    
}

#pragma mark - RAC部分知识汇总

- (void)RACSomeKnowledge{
    
    /*
     
     1. 如何取消订阅一个signal？在一个completed或者error事件之后，订阅会自动移除）
     
     2. 你还可以通过RACDisposable手动移除订阅,RACSignal的订阅方法都会返回一个RACDisposable实例，它能让你通过dispose方法手动移除订阅
     
     3. 如果你创建了一个管道，但是没有订阅它，这个管道就不会执行，包括任何如doNext: block的附加操作
     
     */
    
    
    
    /*
     
     RACSignal使用步骤：
     
     1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     
     2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     
     3.发送信号 - (void)sendNext:(id)value
     
     
     
     RACSignal底层实现：
     
     1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
     
     2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
     
     2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
     
     2.1 subscribeNext内部会调用siganl的didSubscribe
     
     3.siganl的didSubscribe中调用[subscriber sendNext:@1];
     
     3.1 sendNext底层其实就是执行subscriber的nextBlock
     
     
     
     如果不在发送数据，最好发送信号完成(sendCompleted)，内部会自动调用[RACDisposable disposable]取消订阅信号。
     
     [subscriber sendCompleted];
     
     
     
     RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据
     
     
     
     RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它
     
     使用场景:不想监听某个信号时，可以通过它主动取消订阅信号
     
     
     
     RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号
     
     使用场景:通常用来代替代理，有了它，就不必要定义代理了
     
     RACReplaySubject:重复提供信号类，RACSubject的子类
     
     RACReplaySubject与RACSubject区别:
     
     RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
     
     使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
     
     使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值
     
     
     
     [self testSubject];
     
     [self testReplaySubject];
     
     
     
     
     
     RACScheduler:RAC中的队列，用GCD封装的
     
     RACUnit :表⽰stream不包含有意义的值,也就是看到这个，可以直接理解为nil
     
     RACEvent: 把数据包装成信号事件(signal event)。它主要通过RACSignal的-materialize来使用，然并卵
     
     */
    
    
    
    /*
     
     #pragma mark - ReactiveCocoa开发中常见用法
     
     rac_signalForSelector：用于替代代理
     
     rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变
     
     rac_signalForControlEvents：用于监听某个事件
     
     rac_addObserverForName:用于监听某个通知
     
     rac_textSignal:只要文本框发出改变就会发出这个信号
     
     rac_liftSelector:withSignalsFromArray:Signals:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据
     
     // 代码演示
     
     [self testRACMethod];
     
     */
    
}


- (void)btnClick:(UIButton* )button{
    
    NSLog(@"btnClick");
    
}


#pragma mark - ReactiveCocoa开发中常见用法

- (void)testRACMethod
{
    
    UIView* redV = [[UIView alloc] initWithFrame:CGRectMake(100,100, 100,100)];
    
    [self.view addSubview:redV];
    
    // 1.代替代理
    
    // 需求：自定义redView,监听红色view中按钮点击
    
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，只要调用这个方法，就会发送信号
    
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了
    
    [[redV rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        
        NSLog(@"点击红色按钮");
        
    }];
    
    
    
    // 2.KVO
    
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    
    // observer:可以传入nil
    
    [[redV rac_valuesAndChangesForKeyPath:@"center"options:NSKeyValueObservingOptionNew observer:nil]subscribeNext:^(id x) {
        
        NSLog(@"KVO %@",x);
        
    }];
    
    // 模拟center属性的改变
    
        redV.center = CGPointMake(200, 100);
    
    
    
    // 3.监听事件
    
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        
        NSLog(@"signInButton按钮被点击了");
        
    }];
    
    
    
    // 4.代替通知
    
    // 把监听到的通知转换信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"键盘弹出");
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"键盘消失");
    }];
    
    
    // 5.监听文本框的文字改变
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    
    RACSignal *request1 = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求2
        
        [subscriber sendNext:@"发送请求1"];
        
        return nil;
        
    }] throttle:5.0];
    
    
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求2
        
        [subscriber sendNext:@"发送请求2"];
        
        return nil;
        
    }];
    
    
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
    
}


// 更新UI

- (void)updateUIWithR1:(id)data r2:(id)data1

{
    
    NSLog(@"更新UI%@  %@",data,data1);
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    
}


#pragma mark - 测试 RACSubject的使用

- (void)testSubject{
    
    /*
     
     RACSubject使用步骤
     
     1.创建信号 [RACSubject subject]，跟RACSignal不一样，创建信号时没有block。
     
     2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     
     3.发送信号 sendNext:(id)value
     
     */
    
    // 1.创建信号
    
    RACSubject *subject = [RACSubject subject];
    
    
    
    [subject sendNext:@"1"];
    
    [subject sendNext:@"2"];
    
    [subject sendNext:@"3"];
    
    
    
    // 2.订阅信号
    
    [subject subscribeNext:^(id x) {
        
        // block调用时刻：当信号发出新值，就会调用.
        
        NSLog(@"第一个订阅者%@",x);
        
    }];
    
    [subject subscribeNext:^(id x) {
        
        // block调用时刻：当信号发出新值，就会调用.
        
        NSLog(@"第二个订阅者%@",x);
        
    }];
    
    // 3.发送信号
    
    [subject sendNext:@"4"];
    
    [subject sendNext:@"5"];
    
}


#pragma mark - 测试 RACReplaySubject的使用

- (void)testReplaySubject{
    
    // RACReplaySubject使用步骤:
    
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    
    // 2.可以先订阅信号，也可以先发送信号。
    
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    
    // 2.2 发送信号 sendNext:(id)value
    
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    
    // 也就是先保存值，在订阅值。
    
    
    
    // 1.创建信号
    
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    
    
    // 2.发送信号
    
    [replaySubject sendNext:@1];
    
    [replaySubject sendNext:@2];
    
    [replaySubject sendNext:@3];
    
    
    
    // 3.订阅信号
    
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
        
    }];
    
    [replaySubject sendNext:@4];
    
    [replaySubject sendNext:@"5"];
    
}


/*
 
 实现一个时钟应用
 
 实现的逻辑顺序是:设置一个间隔为一秒。从现在开始调用的函数。并把当前实际传入。这个函数返回一个NSString。然后把这个NSString和界面上的textField绑定在了一起。从而实现时钟程序。表现了流和绑定响应。
 
 */

#pragma mark - 实现一个时钟应用

- (void)testClockApplication
{
    RAC(self,describeText.text) =   [[[RACSignal interval:1.0 onScheduler:[RACScheduler currentScheduler]] startWith:[NSDate date]] map:^id _Nullable(NSDate * _Nullable value) {
        
        NSLog(@"date %@",value);
        NSDateComponents* dateCompenents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond fromDate:value];
        
        NSLog(@"dateCompenents %@",dateCompenents);
        
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld %02ld:%02ld:%02ld",(long)dateCompenents.year,(long)dateCompenents.month,(long)dateCompenents.weekday,(long)dateCompenents.hour,(long)dateCompenents.minute,(long)dateCompenents.second];
    }];
    
}


#pragma mark - 网络测试.....

#pragma mark - Network Request:这些可以通过自定义信号，也就是RACSubject(继承自RACSignal，可以理解为自由度更高的signal)来搞定

- (void)testNetwork{
    
    RACSubject* subject = [self doRequest];
    
    [subject subscribeNext:^(NSString * x) {
        
        [self logSource:@"testNetwork"text:x];
        self.describeText.text = x;
    }];
    
}


#pragma mark - 模拟网络请求,1.5秒后得到请求内容

- (RACSubject* )doRequest{
    
    RACSubject* subject = [RACSubject subject];
    
    // 模拟1.5秒后得到请求内容
    
    // 只触发1次
    
    // 尽管subscribeNext什么也没做，但如果没有的话map是不会执行的
    
    // subscribeNext就是定义了一个接收体
    [[[[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] take:1.5] map:^id (NSDate * value) {
        [self logSource:@"Network"text:value.description];
        
        [subject sendNext:@"测试"];
        
        return nil;
    }] subscribeNext:^(id  _Nullable x) {
        
    }];
    
    return subject;
    
}


#pragma mark - 测试常用宏RAC RAC可以看作某个属性的值与一些信号的联动

- (void)testRAC{
    
        RAC(self.loginBtn,enabled) = [RACSignal combineLatest:@[self.usernameTextField.rac_textSignal , self.passwordTextField.rac_textSignal] reduce:^id(NSString* userName , NSString* password){
    
            return @(userName.length >= 6 && password.length >= 6);
    
        }];
    
}


#pragma mark - 测试 RACObserve监听属性的改变，使用block的KVO

- (void)testRACObserve{
    
//        @weakify(self);
//        [self.usernameTextField.rac_textSignal subscribeNext:^(NSString* text) {
//         @strongify(self);
//            [self logSource:@"rac_textSignal" text:text];
//            self.userName = text;
//        }];
    
    //只要你的username有变化,都可以打印出来实现了KVO的功能却减少了无数的代码,体现了绑定和响应
  
    [RACObserve(self, userName) subscribeNext:^(NSString* newName) {
        
        [self logSource:@"RACObserve"text:newName];
        
    }];
    
    // 使用filter过滤,只响应部分情况
    
    [[RACObserve(self, userName) filter:^BOOL(NSString* text) {
        
        return [text hasSuffix:@"2"];//只响应以2结尾的字符串
        
    }] subscribeNext:^(NSString* text) {
        
        [self logSource:@"这是一个以2结尾的字符串"text:text];
        
    }];
    

    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(changeUserName) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}


#pragma mark - 测试 RACObserve监听属性的改变,修改监听属性的值

- (void)changeUserName{
    
    self.userName = [[NSString alloc] initWithFormat:@"userName %zi",arc4random_uniform(1000)];
    
}


#pragma mark - 测试 switching switchToLatest:取指定的那个水龙头的吐出的最新玻璃球

- (void)testSwitching{
    
    RACSubject* letters = [RACSubject subject];
    
    RACSubject* numbers = [RACSubject subject];
    
    RACSubject* signalOfSignals = [RACSubject subject];
    
    RACSignal* switched = [signalOfSignals switchToLatest];
    
    
    
    // Outputs: A B 1 D
    
    [switched subscribeNext:^(NSString* text) {
        
        [self logSource:@"switched"text:text];
        
    }];
    
    
    
    // 取指定的那个水龙头的吐出的最新玻璃球
    
    // 设置 letters为最新的水龙头
    
    [signalOfSignals sendNext:letters];
    
    [letters sendNext:@"A"];
    
    [letters sendNext:@"B"];
    
    // 设置 numbers为最新的水龙头
    
    [signalOfSignals sendNext:numbers];

    [letters sendNext:@"C"];

    [numbers sendNext:@"1"];
    
    // 设置 letters为最新的水龙头
    
    [signalOfSignals sendNext:letters];

    [numbers sendNext:@"2"];

    [letters sendNext:@"D"];
    
}


#pragma mark - 测试组合 combine  combineLatest:任何时刻取每个水龙头吐出的最新的那个玻璃球

- (void)testCombining{
    
    RACSubject* letters = [RACSubject subject];
    
    RACSubject* numbers = [RACSubject subject];
    
    RACSignal* combine = [RACSignal combineLatest:@[letters , numbers]reduce:^(NSString* letter ,NSString* number){
        
        return [letter stringByAppendingString:number];
        
    }];
    
    
    
    // Outputs: B1 B2 C2 C3
    
    [combine subscribeNext:^(NSString* x) {
        
        [self logSource:@"combine"text:x];
        
    }];
    
    //任何时刻取每个水龙头吐出的最新的那个玻璃球 , A的值被B覆盖了
    
    [letters sendNext:@"A"];
    
    [letters sendNext:@"B"];
    
    [numbers sendNext:@"1"];
    
    [numbers sendNext:@"2"];
    
//    [letters sendNext:@"C"];
//
//    [numbers sendNext:@"3"];
    
}


#pragma mark - 测试 map and flatten

- (void)testMapAndFlatten{
    
    // 先 map再 flatten
    
    [self testFlattenMap];
    
}


#pragma mark - 测试 map and flatten  -先 map 再 flatten

- (void)testFlattenMap{
    
    RACSequence* numbers =self.dataArrNumber.rac_sequence;
    
    // Contains: 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
    
    RACSequence* extended = [numbers flattenMap:^RACSequence *(NSString* num) {
        
        return@[num,num].rac_sequence;
        
    }];
    
    
    // Contains: 1_ 3_ 5_ 7_ 9_
    
    RACSequence* edited = [numbers flattenMap:^RACSequence *(NSString* num) {
        
        if (num.intValue %2 == 0){
            
            //            [self logSource:@"num.intValue" text:num];
            
            return [RACSequence empty];
            
        }else{
            
            NSString* newNum = [num stringByAppendingString:@"_"];
            
            //            [self logSource:@"newNum" text:newNum];
            
            return [RACSequence return:newNum];
            
        }
        
    }];
    
    // 排序 按照顺序输出
    
    RACSequence* queue =@[extended,edited].rac_sequence;
    
    [[queue flatten].signal subscribeNext:^(NSString* text) {
        
        [self logSource:@"queue"text:text];
        
    }];
    
    
    
    // 输出顺序会乱
    
    [[extended signal] subscribeNext:^(NSString* text) {
        
        [self logSource:@"extended" text:text];
        
    }];
    
    [edited.signal subscribeNext:^(NSString* text) {
        
        [self logSource:@"edited" text:text];
        
    }];
    
}


#pragma mark - 测试 flatten

- (void)testFlatten{
    
    // 测试flatten起连接作用 类似于cancat
    
        [self testFlattenForConcat];
    

    // Signals are merged（merge可以理解成把几个水管的龙头合并成一个，哪个水管中的玻璃球哪个先到先吐哪个玻璃球）
    
    RACSubject* letters = [RACSubject subject];
    
    RACSubject* numbers = [RACSubject subject];
    
    RACSignal* signalOfSignals = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:letters];
        
        [subscriber sendNext:numbers];
        
        [subscriber sendCompleted];
        
        return nil;
        
    }];
    
    // 用flatten合并
    
    RACSignal* flattened = [signalOfSignals flatten];
    
    // Outputs: A 1 B C 2
    
    [flattened subscribeNext:^(NSString* x) {
        
        [self logSource:@"flattened"text:x];
        
    }];
    
    
    
    // 用merging合并
    
    RACSignal* merged = [RACSignal merge:@[letters , numbers]];
    
    // Outputs: A 1 B C 2
    
    [merged subscribeNext:^(NSString* x) {
        
        [self logSource:@"merged"text:x];
        
    }];
    
    
    
    [letters sendNext:@"A"];
    
    [numbers sendNext:@"1"];
    
    [letters sendNext:@"B"];
    
    [letters sendNext:@"C"];
    
    [numbers sendNext:@"2"];
    
}


#pragma mark - 测试 flatten concat

- (void)testFlattenForConcat{
    
    // Sequences are concatenated :序列是连接
    
    RACSequence *letters =self.dataArrString.rac_sequence;
    
    RACSequence *numbers =self.dataArrNumber.rac_sequence;
    
    RACSequence *sequenceOfSequences =@[letters,numbers].rac_sequence;
    
    
    
    // Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
    
    // flatten在此起连接作用
    
    RACSequence *flattened=[sequenceOfSequences flatten];
    
    [flattened.signal subscribeNext:^(NSString* text) {
        
        [self logSource:@"flatten"text:text];
        
    }];
    
}


#pragma mark - 输出字符串

- (void)logSource:(NSString* )source text:(NSString* )text{
    
    NSLog(@"%@ %@",source,text);
    
}


#pragma mark - 测试 concat:把一个水管拼接到另一个水管之后

- (void)testConcat{
    
    RACSequence* letters =self.dataArrString.rac_sequence;
    
    RACSequence* numbers =self.dataArrNumber.rac_sequence;
    

    RACSequence* concated = [letters concat:numbers];
    
    
    // 输出 Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
    
    [concated.signal subscribeNext:^(NSString* text) {
        
        [self logSource:@"concat"text:text];
        
    }];
    
}


#pragma mark - 测试 filter:过滤，不符合要求的玻璃球不允许通过

- (void)testFilter{
    
    RACSequence* numbers =self.dataArrNumber.rac_sequence;
    
    // 转换后Contains: 2 4 6 8
    
    [[numbers filter:^BOOL(NSString* value) {
        
        return (value.intValue %2) == 0;
        
    }].signal subscribeNext:^(NSString* x) {
        
        [self logSource:@"filter"text:x];
        
    }];
    
}

- (NSArray *)dataArrNumber{
    
    if (!_dataArrNumber){
        
        _dataArrNumber = [@"1 2 3 4 5 6 7 8 9"componentsSeparatedByString:@" "];
        
    }
    
    return _dataArrNumber;
    
}

- (NSArray *)dataArrString{
    if (!_dataArrString){
        _dataArrString = [@"A B C D E F G H I"componentsSeparatedByString:@" "];
        }
     return _dataArrString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
