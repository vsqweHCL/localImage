//
//  LAAttacheV.h
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@class LAAttacheV;
@protocol LAAttacheVDelegate <NSObject>

- (void)attacheV:(LAAttacheV *)attacheV didClickImageV:(LAImageModel *)imgModel;
- (void)attacheV:(LAAttacheV *)attacheV didClickCloseV:(LAImageModel *)imgModel;

@end

@interface LAAttacheV : UIView

@property (nonatomic, strong) LAImageModel *model;
@property (nonatomic, weak) id<LAAttacheVDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
