//
//  ImageEditViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/5.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "ImageEditViewController.h"

@interface ImageEditViewController (){
    UIImage *_image;
}

@end

static ImageDeleteBlock _deleteblock;
@implementation ImageEditViewController

-(void)deleteButtonClicked:(id)sender{
    _deleteblock(_image);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setImageBlock:(ImageDeleteBlock)imageBlock{
    _deleteblock = imageBlock;
}
-(void)chonfigeNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setTitle:@"删除" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self chonfigeNavigationRightItem];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    imageView.image = _image;
    [self.view addSubview:imageView];
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
