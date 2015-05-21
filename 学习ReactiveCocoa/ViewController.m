//
//  ViewController.m
//  学习ReactiveCocoa
//
//  Created by liuchunlao on 15/5/21.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;

/** 验证文字改变 */
@property (nonatomic, copy)  NSString *userName;

/** 验证密码 */
@property (nonatomic, copy)  NSString *password;
/** 确认密码 */
@property (nonatomic, copy)  NSString *passwordConfirmation;

@property (nonatomic, assign) BOOL createEnabled;

@property (weak, nonatomic) IBOutlet UIButton *button;

/** 异步网络操作 */
@property (nonatomic, strong) RACCommand *loginCommand;


@end

@implementation ViewController
- (IBAction)textChange:(UITextField *)sender {
    self.userName = sender.text;
}

- (IBAction)password:(UITextField *)sender {
    self.password = sender.text;
}

- (IBAction)passwordConfirmation:(UITextField *)sender {
    self.passwordConfirmation = sender.text;
}


// 1.监听某个变量值的变化，如userName的文字发生变化就会打印
- (void)demo1 {

     [RACObserve(self, userName) subscribeNext:^(NSString *newName) {
         NSLog(@"%@", newName);
     }];

}

// 2.监听某个变量值得变化，增加限制条件，满足条件再打印
- (void)demo2 {
    /**
     如果首字母是j才往下一步进行
     */
    
    [[RACObserve(self, userName)
     filter:^BOOL(NSString *newName) {
          return [newName hasPrefix:@"j"];
      }]
     subscribeNext:^(NSString *newName) {
         NSLog(@"%@", newName);
     }];
}

// 3.验证密码
- (void)demo3 {
    // 如果两次输入结果一直则返回的 1 否则返回 0
    
    RAC(self, createEnabled) = [RACSignal combineLatest:@[RACObserve(self, password), RACObserve(self, passwordConfirmation)] reduce:^(NSString *password, NSString *passwordConfirm){
        BOOL equal = [password isEqualToString:passwordConfirm];
        if (equal) {
            NSLog(@"密码相同");
        } else {
            NSLog(@"密码不同");
        }
        return [NSNumber numberWithBool:equal];
    }];
}
// 4.接收按钮事件
- (void)demo4 {
    self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"button was pressed");
        return [RACSignal empty];
    }];
}

// 5.异步网络操作
- (void)demo5 {
    // >1 设定异步网络请求操作
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self loginOperation]; // 注意：返回的也必须是RACSignal类型的信号流
    }];
    
    // >2 成功之后的操作
    [self.loginCommand.executionSignals subscribeNext:^(RACSignal *loginSingal) {
        [loginSingal subscribeCompleted:^{
            NSLog(@"logged in successfully");
        }];
    }];
    
    // >3 按钮点击的时候触发事件
    self.button.rac_command = self.loginCommand;
}

- (RACSignal *)loginOperation {
    return [RACSignal empty];
}

// 6.在两个网络请求完成后在控制面板打印一条信息
- (void)demo6 {
    [[RACSignal merge:@[[self fetchUserRepos], [self fetchOrgRepos]]] subscribeCompleted:^{
        NSLog(@"两项网络操作都已经完成");
    }];
}
- (RACSignal *)fetchUserRepos {
    
    NSLog(@"第一个网络操作完成");
    return [RACSignal empty];
    
}

- (RACSignal *)fetchOrgRepos {
    
    NSLog(@"第二个网络操作完成");
    return [RACSignal empty];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameField.delegate = self;
    
//    [self demo1];
    [self demo2];
    [self demo3];
    [self demo4];
    [self demo5];
    [self demo6];
    
    
    
}






@end
