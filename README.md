#简介

`ReactiveCocoa` 在GitHub有1.5万多个星，不少大型公司的的都用它作为主流框架，比如美团，但它同时又是一个非常复杂的框架，在正式开始介绍它的核心组件前，我们先来看看它的类图，以便从宏观上了解它的层次结构：

![介绍](https://github.com/jsonmall/reactcocoalearn/blob/master/md/one.jpg)

从上面的类图中，我们可以看出，ReactiveCocoa 主要由以下四大核心组件构成：

* 信号源：RACStream 及其子类；
* 订阅者：RACSubscriber 的实现类及其子类；
* 调度器：RACScheduler 及其子类；
* 清洁工：RACDisposable 及其子类。

##ReactiveCocoa作用
>
在我们iOS开发过程中，当某些事件响应的时候，需要处理某些业务逻辑,这些事件都用不同的方式来处理。
比如按钮的点击使用`action`，`ScrollView`滚动使用`delegate`，属性值改变使用`KVO`等系统提供的方式。
>
其实这些事件，都可以通过RAC处理
`ReactiveCocoa`为事件提供了很多处理方法，而且利用`RAC`处理事件很方便，可以把要处理的事情，和监听的事情的代码放在一起，这样非常方便我们管理，就不需要跳到对应的方法里。非常符合我们开发中`高聚合`，`低耦合`的思想
>
对于一个应用来说，绝大部分的时间都是在等待某些事件的发生或响应某些状态的变化，比如用户的触摸事件、应用进入后台、网络请求成功刷新界面等等，而维护这些状态的变化，常常会使代码变得非常复杂，难以扩展。而 `ReactiveCocoa` 给出了一种非常好的解决方案，它使用信号来代表这些异步事件，提供了一种统一的方式来处理所有异步的行为，包括代理方法、`block` 回调、`target-action` `机制`、`通知`、`KVO` 等：

```

// 代理方法
[[self
    rac_signalForSelector:@selector(webViewDidStartLoad:)
    fromProtocol:@protocol(UIWebViewDelegate)]
    subscribeNext:^(id x) {
        // 实现 webViewDidStartLoad: 代理方法
    }];

// target-action
[[self.avatarButton
    rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(UIButton *avatarButton) {
        // avatarButton 被点击了
    }];

// 通知
[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kReachabilityChangedNotification object:nil]
    subscribeNext:^(NSNotification *notification) {
        // 收到 kReachabilityChangedNotification 通知
    }];

// KVO
[RACObserve(self, username) subscribeNext:^(NSString *username) {
    // 用户名发生了变化
}];

```
然而，这些还只是 `ReactiveCocoa` 的冰山一角，它真正强大的地方在于我们可以对这些不同的信号进行任意地组合和链式操作，从最原始的输入 `input` 开始直至得到最终的输出 `output` 为止：

```
[[[RACSignal
    combineLatest:@[ RACObserve(self, username), RACObserve(self, password) ]
    reduce:^(NSString *username, NSString *password) {
      return @(username.length > 0 && password.length > 0);
    }]
    distinctUntilChanged]
    subscribeNext:^(NSNumber *valid) {
        if (valid.boolValue) {
            // 用户名和密码合法，登录按钮可用
        } else {
            // 用户名或密码不合法，登录按钮不可用
        }
    }];
```

###RACSignal(信号源)

`RACSignal` 代表的是未来将会被传送的值，它是一种 push-driven 的流。`RACSignal` 可以向订阅者发送三种不同类型的事件：

* `next ：RACSignal` 通过 `next` 事件向订阅者传送新的值，并且这个值可以为 nil ；
* `error ：RACSignal` 通过 `error` 事件向订阅者表明信号在正常结束前发生了错误；
* `completed ：RACSignal` 通过 `completed` 事件向订阅者表明信号已经正常结束，不会再有后续的值传送给订阅者。


注意，`ReactiveCocoa `中的值流只包含正常的值，即通过 next 事件传送的值，并不包括 `error` 和 `completed` 事件，它们需要被特殊处理。通常情况下，一个信号的生命周期是由任意个 `next` 事件和一个 `error` 事件或一个 `completed` 事件组成的


###RACSubscriber（订阅者）

现在，我们已经知道信号源是什么了，为了获取信号源中的值，我们需要对信号源进行订阅。在 `ReactiveCocoa` 中，订阅者是一个抽象的概念，所有实现了 `RACSubscriber` 协议的类都可以作为信号源的订阅者

其中 `-sendNext`: 、`-sendError`: 和 `-sendCompleted` 分别用来从 `RACSignal` 接收 `next 、error 和 completed` 事件，而 `-didSubscribeWithDisposable`: 则用来接收代表某次订阅的 `disposable` 对象。

订阅者对信号源的一次订阅过程可以抽象为：通过 `RACSignal` 的 -`subscribe`: 方法传入一个订阅者，并最终返回一个 RACDisposable 对象的过程：

![subcir](https://github.com/jsonmall/reactcocoalearn/blob/master/md/subscribe.png)

###RACScheduler(调度器)

>有了信号源和订阅者，我们还需要由调度器来统一调度订阅者订阅信号源的过程中所涉及到的任务，这样才能保证所有的任务都能够合理有序地执行


`RACScheduler` 在 `ReactiveCocoa` 中就是扮演着调度器的角色，本质上，它就是用 GCD 的串行队列来实现的，并且支持取消操作。是的，在 `ReactiveCocoa` 中，并没有使用到 `NSOperationQueue` 和 `NSRunloop` 等技术，`RACScheduler` 也只是对 GCD 的简单封装而已

###RACDisposable(清洁工)

>正如我们前面所说的，在订阅者订阅信号源的过程中，可能会产生副作用或者消耗一定的资源，所以当我们在取消订阅或者完成订阅时，我们就需要做一些资源回收和垃圾清理的工作

`RACDisposable` 在 `ReactiveCocoa` 中就充当着清洁工的角色，它封装了取消和清理一次订阅所必需的工作。它有一个核心的方法 -`dispose` ，调用这个方法就会执行相应的清理工作，这有点类似于 `NSObject` 的 `-dealloc` 方法。`RACDisposable` 总共有四个子类，它的继承结构图如下

![RACDisposable](https://github.com/jsonmall/reactcocoalearn/blob/master/md/RACDisposable.jpg)

* `RACSerialDisposable` ：作为 `disposable` 的容器使用，可以包含一个 `disposable` 对象，并且允许将这个 `disposable` 对象通过原子操作交换出来；
* `RACKVOTrampoline` ：代表一次 KVO 观察，并且可以用来停止观察；
* `RACCompoundDisposable` ：跟 `RACSerialDisposable` 一样，* `RACCompoundDisposable` 也是作为 `disposable` 的容器使用。不同的是，它可以包含多个 `disposable` 对象，并且支持手动添加和移除 `disposable` 对象，有点类似于可变数组 `NSMutableArray` 。而当一个 `RACCompoundDisposable` 对象被 `disposed` 时，它会调用其所包含的所有 `disposable` 对象的 -`dispose` 方法，有点类似于 `autoreleasepool` 的作用;
* `RACScopedDisposable` ：当它被 `dealloc` 的时候调用本身的 `-dispose` 方法


##=========基础知识解释==========

1. `RACSubject`:`RACSubject`:信号提供者，自己可以充当信号，又能发送信号。

>使用场景:通常用来代替代理，有了它，就不必要定义代理了。

`RACReplaySubject`:重复提供信号类，`RACSubject`的子类。

`RACReplaySubject`与`RACSubject`区别:

`RACReplaySubject`可以先发送信号，在订阅信号，`RACSubject`就不可以。

>使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。

>使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。

2. `RACTuple`:元组类,类似NSArray,用来包装值

3. `RACSequence`:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典

4. `RACCommand`:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。

* 使用场景:监听按钮点击，网络请求

5. `RACScheduler`:`RAC`中的队列，用GCD封装的

6. 代替代理: `rac_signalForSelector`：用于替代代理。

7. 代替KVO : `rac_valuesAndChangesForKeyPath`：用于监听某个对象的属性改变。

8.  监听事件: `rac_signalForControlEvents`：用于监听某个事件。

9.  代替通知: `rac_addObserverForName`:用于监听某个通知。

10.  监听文本框文字改变: `rac_textSignal`:只要文本框发出改变就会发出这个信号。

11. 处理当界面有多次请求时，需要都获取到数据时，才能展示界面

`rac_liftSelector:withSignalsFromArray:Signals`:当传入的`Signals`(信号数组)，每一个`signal`都至少`sendNext`过一次，就会去触发第一个`selector`参数的方法。
使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。


#操作符用法解释


### 一. flattenMap 和 map的区别

 `Map`:用于把原信号中的内容映射成新的内容
 `flattenMap的作用`：把原信号的内容映射成一个新的信号，信号可以是任意的类型</br>
 
  > 1.FlatternMap中的Block返回信号

   >2.Map中的Block返回对象

   >3.开发中，如果信号发出的值不是信号，映射一般使用Map

   >4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap

```
   RACSequence* numbers =self.dataArrNumber.rac_sequence;
    
    // Contains: 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
 
    RACSequence* extended = [numbers flattenMap:^RACSequence *(NSString* num) {
        
        return@[num,num].rac_sequence;
        
    }];
     [[extended signal] subscribeNext:^(NSString* text) {
    
            [self logSource:@"extended" text:text];
    
        }];
```
###flatten
就像一条流水线，将源信号一个一个发出去,也可以理解成把几个水管的龙头合并成一个，按照顺序连接

###contact 
>按一定顺序拼接信号，当多个信号发出的时候有顺序的接受信号

 ```
     RACSubject *subjectA = [RACSubject subject];

    RACSubject *subjectB = [RACSubject subject];

    //把subjectA拼接到subjectB的时候只有subjectA发送完毕之后subjectB才会被激活

    // 只需要订阅拼接之后的信号，不在需要单独拼接subjectA或者subjectB,内部会自动订阅

    [[subjectA concat:subjectB] subscribeNext:^(id x) {

        NSLog(@"%@",x);

    }];

    [subjectA sendNext:@"subjectA发送完信号"];

    // 第一个信号发送完成，第二个信号才会被激活

    [subjectA sendCompleted];

    [subjectB sendNext:@"subjectB发送完信号”];

 ```
###then
>then:用于连接两个信号，当第一个信号完成才会连接then返回的信号
  使用then之前的信号会被忽略掉
  
###merge
>把多个信号合并为一个信号，任何一个信号有新值时就会调用

###zipWith
>把两个信号压缩成一个信号，只有当两个信号同时发出信号内容的时候，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件


###reduce

> 聚合：用于信号发出的内容是元组，把信号发出元组的值聚合成一个值。
 
###fiter
>使用提供的block来觉得事件是否往下传递
 
### combineLatest:reduce
>组合源信号数组中的信号，并生成一个新的信号。每次源信号数组中的一个输出新值时，reduce块都会被执行，而返回的值会作为组合信号的下一个值。

###doNext
>附加操作，并不返回一个值
 
 
 参考文档：<https://www.jianshu.com/p/87ef6720a096>
 

 
