//
//  ViewController.m
//  testBlocksKit
//
//  Created by 王迎博 on 16/9/20.
//  Copyright © 2016年 王迎博. All rights reserved.

//  原链：http://www.jianshu.com/p/1f6669ee0ddb

#import "ViewController.h"
#import "BlocksKit.h"
#import "BlocksKit+UIKit.h"


@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //1、第一条测试，遍历数组或者字典等
    [self testFirst_bk_each];
    
    //2、第二条测试，NSObject上的Runtime魔法
    [self testSecond_NSObject];
    
    //3、第三条测试，测试多线程GCD
    [self testThird_GCD];
    
    //4、第四条测试，测试使用Block封装KVO
    [self testForth_KVO];
    
    //5、第五条测试，测试UIKit的block
    [self testFifth_UIKit];
    
}

/**
 *  5、第五条测试，测试UIKit的block
 */
- (void)testFifth_UIKit
{
    //1-UITapGestureRecognizer的封装
    UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(50, 100, 60, 60)];
    testView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:testView];
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        NSLog(@"第一个延迟了0秒后手势响应了");
    } delay:.0];
    [ testView addGestureRecognizer:tapGesture];
    
    //2-UIView的touch点击封装
    UIView *testView1 = [[UIView alloc]initWithFrame:CGRectMake(50, 200, 60, 60)];
    testView1.backgroundColor = [UIColor brownColor];
    [self.view addSubview:testView1];
    [testView1 bk_whenTapped:^{
        NSLog(@"第二个view响应了手势");
    }];
    [testView1 bk_whenTouches:1 tapped:1 handler:^{
    }];
    
    //3-UIButton的event时间响应封装
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(50, 300, 60, 60)];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"button" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button bk_addEventHandler:^(id sender) {
        NSLog(@"点击了按钮，响应了按钮的方法");
    } forControlEvents:UIControlEventTouchUpInside];
    
    //4-UIAlertView示例
    UIButton *buttonAlert = [[UIButton alloc]initWithFrame:CGRectMake(50, 400, 100, 60)];
    buttonAlert.backgroundColor = [UIColor lightGrayColor];
    [buttonAlert setTitle:@"AlertView示例" forState:UIControlStateNormal];
    [buttonAlert setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonAlert.titleLabel.font = [UIFont systemFontOfSize:13.];
    [self.view addSubview:buttonAlert];
    [buttonAlert bk_addEventHandler:^(id sender) {
        
        UIAlertView*alertView=[[UIAlertView alloc]bk_initWithTitle:@"提示"message:@"提示信息"];
        [alertView bk_setCancelButtonWithTitle:@"取消"handler:nil];
        [alertView bk_addButtonWithTitle:@"确定"handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert,NSInteger index){
            if(index==1){
                NSLog(@"%ld clicked",index);
            }
        }];
        [alertView show];
    } forControlEvents:UIControlEventTouchUpInside];
    
    //5-UIActionSheet封装
    UIView *actionSheetView = [[UIView alloc]initWithFrame:CGRectMake(50+[UIScreen mainScreen].bounds.size.width/2, 100, 60, 60)];
    actionSheetView.backgroundColor = [UIColor redColor];
    [self.view addSubview:actionSheetView];
    [actionSheetView bk_whenTapped:^{
        
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"王颖博"];
        [actionSheet bk_addButtonWithTitle:@"第一个" handler:^{
            NSLog(@"点击了第一个");
        }];
        [actionSheet bk_addButtonWithTitle:@"第二个" handler:^{
            NSLog(@"点击了第二个");
        }];
        [actionSheet bk_handlerForButtonAtIndex:
         [actionSheet bk_addButtonWithTitle:@"第三个" handler:^{
            NSLog(@"点击了第三个");
        }]
         ];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            NSLog(@"点击了取消");
        }];
        [actionSheet bk_setHandler:^{
            NSLog(@"点击了第1个");
        } forButtonAtIndex:1];
        [actionSheet showInView:self.view];
    }];
}

/**
 *  4、第四条测试，测试使用Block封装KVO
 */
- (void)testForth_KVO
{
    //KVO的用法参见：http://blog.sina.com.cn/s/blog_621403ef0100ywc9.html
    
    [self bk_addObserverForKeyPath:@"test_wang" task:^(id target) {
    }];
    
    [self bk_addObserverForKeyPath:@"test_ying" identifier:@"identifier_ying" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        
    }];
    
}

/**
 *  3、第三条测试，测试多线程GCD
 */
- (void)testThird_GCD
{
    [self bk_performBlock:^(id obj) {
        NSLog(@"延迟两秒以后");
    } afterDelay:2.0];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable" //消除警告
    dispatch_queue_t queue = dispatch_queue_create("wangyingbo", DISPATCH_QUEUE_SERIAL);//生成一个串行队
    dispatch_queue_t queue1 = dispatch_queue_create("com.dispatch.concurrent", DISPATCH_QUEUE_CONCURRENT); //生成一个并发执行队列，block被分发到多个线程去执行
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //获得程序进程缺省产生的并发队列，可设定优先级来选择高、中、低三个优先级队列
    dispatch_queue_t queue3 = dispatch_get_main_queue(); //获得主线程的dispatch队列，实际是一个串行队列。同样无法控制主线程dispatch队列的执行继续或中断。
    //接下来我们可以使用dispatch_async或dispatch_sync函数来加载需要运行的block。
    dispatch_async(queue1, ^{
        //block具体代码
    }); //异步执行block，函数立即返回
    dispatch_sync(queue2, ^{
        //block具体代码
    });
    //同步执行block，函数不返回，一直等到block执行完毕。编译器会根据实际情况优化代码，所以有时候你会发现block其实还在当前线程上执行，并没用产生新线程,尽可能避免使用dispatch_sync，嵌套使用时还容易引起程序死锁
#pragma clang diagnostic pop
    
    //使用BlocksKit实现GCD队列
    [self bk_performBlock:^(id obj) {
        NSLog(@"延迟4秒");
    } onQueue:queue afterDelay:4.];
}

/**
 *  2、第二条测试，NSObject上的Runtime魔法
 */
- (void)testSecond_NSObject
{
    //添加 AssociatedObject，动态给类添加属性
    NSObject *test = [[NSObject alloc] init];
    [test bk_associateValue:@"Draveness" withKey:@"name"];
    NSLog(@"%@",[test bk_associatedValueForKey:@"name"]);
    
}

/**
 *  1、第一条测试，遍历数组或者字典等
 */
- (void)testFirst_bk_each
{
    //遍历数组
    [@[@"test1",@"test2",@[@1,@2]] bk_each:^(id obj) {
        NSLog(@"%@",obj);
    }];
    
    //等同于enumerateObjectsUsingBlock
    [@[@"test1",@"test2",@[@1,@2]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", obj);
    }];
}


@end
