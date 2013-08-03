//
//  FirstViewController.m
//  sample
//
//  Created by hirokazu sato on 2013/08/02.
//  Copyright (c) 2013年 hirokazu sato. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
{
    //UILabel *lb;
    UIButton *bt;
}
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //ボタン生成
    bt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt.frame = CGRectMake(0, 0 , 100, 100);
    bt.center = self.view.center ;
    bt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin ;
    
    [bt setTitle:@"購入" forState:UIControlStateNormal];
    
    //[bt setTitle:@"販売終了" forState:UIControlStateDisabled];
    
    //イベント取得
    [bt addTarget:self action:@selector(bt_touchdown:)
             forControlEvents:UIControlEventTouchDown];
     
    self.view.backgroundColor = [UIColor whiteColor];
    
    //[self.view addSubview:lb];
    [self.view addSubview:bt];
    
	// Do any additional setup after loading the view, typically from a nib.
}

//タップされた際の処理
- (IBAction)bt_touchdown:(UIButton *)sender
{
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"購入" message:@"ありがとうございます。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] ;
    [av show] ;
//    lb.text = @"ありがとうございます。" ;
//    bt.enabled = NO ;
//    [lb sizeToFit] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
