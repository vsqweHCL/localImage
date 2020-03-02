//
//  LAImageModel.h
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LAImageModel : NSObject

/** 可以为本地UIImage，也可以为网络https */
@property (nonatomic, strong) id image;
/** 是否编辑 */
@property (nonatomic, assign) BOOL editor;
/** 是否是加号图片 */
@property (nonatomic, assign) BOOL add;
/** 对应的下标 */
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
