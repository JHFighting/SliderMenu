//
//  JHUnderViewController.m
//  SliderMenu
//
//  Created by e1858 on 15/4/15.
//  Copyright (c) 2015年 JH. All rights reserved.
//      

#import "JHUnderViewController.h"
#import "JHMainViewController.h"
#import "JHMenuTableViewController.h"
#import "UIView+JH.h"

#define JHMenuWidth (self.view.frame.size.width * 0.75)

#define kScreenH               [UIScreen mainScreen].bounds.size.height
#define kScreenW               [UIScreen mainScreen].bounds.size.width

@interface JHUnderViewController ()

@property (nonatomic, strong) JHMenuTableViewController *menuVc;
@property (nonatomic, strong) JHMainViewController *centerVc;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesturer;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *navView;

@end

@implementation JHUnderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"主界面";
    
    JHMainViewController *centerVc = [[JHMainViewController alloc] init];
    centerVc.view.frame = self.view.bounds;
    [self.view addSubview:centerVc.view];
    [self addChildViewController:centerVc];
    
    JHMenuTableViewController *menuVc = [[JHMenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    menuVc.view.width = JHMenuWidth;
    menuVc.view.height = [[UIApplication sharedApplication].delegate window].frame.size.height;
    menuVc.view.x = -JHMenuWidth;
    menuVc.view.y = 0;
    [[[UIApplication sharedApplication].delegate window] addSubview:menuVc.view];
    
    [self addChildViewController:menuVc];
    
    self.menuVc = menuVc;
    self.centerVc = centerVc;
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0;
    [self.centerVc.view addSubview:_topView];
    
    [self.centerVc.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCenterView:)]];
    
    [self createNav];
}

- (void)createNav
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"列表" style:UIBarButtonItemStylePlain target:self action:@selector(onListButtonDown)];
}

- (UITapGestureRecognizer *)tapGesturer
{
    if (_tapGesturer == nil) {
        _tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onListButtonDown)];
    }
    return _tapGesturer;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kScreenW, 64)];
    _navView.backgroundColor = [UIColor blackColor];
    _navView.alpha = 0;
    [self.navigationController.navigationBar addSubview:_navView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.menuVc.view.transform = CGAffineTransformIdentity;
    _topView.alpha = 0;
    [self.centerVc.view removeGestureRecognizer:self.tapGesturer];
    
    [_navView removeFromSuperview];
}

/**
 *  点击列表事件
 */
- (void)onListButtonDown
{
    [UIView animateWithDuration:0.2 animations:^{
        
        if (self.menuVc.view.frame.origin.x == 0) {
            
            self.menuVc.view.transform = CGAffineTransformIdentity;
            _topView.alpha = 0;
            _navView.alpha = 0;
            [self.centerVc.view removeGestureRecognizer:self.tapGesturer];
            
        } else {
            self.menuVc.view.transform = CGAffineTransformMakeTranslation(JHMenuWidth, 0);
            _topView.alpha = 0.8;
            _navView.alpha = 0.8;
            [self.centerVc.view addGestureRecognizer:self.tapGesturer];
        }
    }];
}

- (void)dragCenterView:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.menuVc.view];
    // 结束拖拽
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded) {
        if (self.menuVc.view.x >= -JHMenuWidth * 0.5) { // 往右边至少走动了JHMenuWidth一半
            
            [UIView animateWithDuration:0.3 animations:^{
                self.menuVc.view.transform = CGAffineTransformMakeTranslation(JHMenuWidth, 0);
                _topView.alpha = 0.8;
                _navView.alpha = 0.8;
                [self.centerVc.view addGestureRecognizer:self.tapGesturer];
            }];
        } else { // 走动距离的没有达到JHMenuWidth一半
            [UIView animateWithDuration:0.3 animations:^{
                self.menuVc.view.transform = CGAffineTransformIdentity;
                _topView.alpha = 0;
                _navView.alpha = 0;
                [self.centerVc.view removeGestureRecognizer:self.tapGesturer];
            }];
        }
    } else { // 正在拖拽中
        self.menuVc.view.transform = CGAffineTransformTranslate(self.menuVc.view.transform, point.x, 0);
        _topView.alpha = (self.menuVc.view.frame.origin.x + JHMenuWidth) * 0.8 /JHMenuWidth;
        _navView.alpha = (self.menuVc.view.frame.origin.x + JHMenuWidth) * 0.8 /JHMenuWidth;
        [pan setTranslation:CGPointZero inView:self.menuVc.view];
        if (self.menuVc.view.x >= 0) {
            self.menuVc.view.transform = CGAffineTransformMakeTranslation(JHMenuWidth, 0);
            _topView.alpha = 0.8;
            _navView.alpha = 0.8;
        } else if (self.menuVc.view.x <= -JHMenuWidth) {
            self.menuVc.view.transform = CGAffineTransformIdentity;
        }
    }
}


@end
