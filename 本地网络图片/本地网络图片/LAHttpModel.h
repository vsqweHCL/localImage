//
//  LAHttpModel.h
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LAHttpModelTypeDefault  = 0, // 默认
    LAHttpModelTypeAuditing = 1, // 审核
    LAHttpModelTypeUnPass   = 2 // 不通过
} LAHttpModelType;

@interface LAHttpModel : NSObject

/** 各种状态 */
@property (nonatomic, assign) LAHttpModelType type;
/** 图片url数组 */
@property (nonatomic, strong) NSArray<NSString *> *imagesList;


#pragma mark - 辅助属性

/** 用户选择的图片数组 */
@property (nonatomic, strong, nullable) NSMutableArray *userImagesList;
/** 后台旧的图片数组，数据一开始请求下来就赋值，后续用它来操作数据，不需要动imagesList */
@property (nonatomic, strong) NSMutableArray *oldImagesList;
/** 图片数组：本地+后台 */
@property (nonatomic, strong) NSMutableArray *totalM;

@end

NS_ASSUME_NONNULL_END
