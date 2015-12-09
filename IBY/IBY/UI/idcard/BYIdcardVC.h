//
//  BYIdcardVC.h
//  IBY
//
//  Created by chenglei on 15/12/3.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYBaseVC.h"

@class BYIdcardService;

@interface BYIdcardVC : BYBaseVC <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) BYIdcardService *idcardService;

@end
