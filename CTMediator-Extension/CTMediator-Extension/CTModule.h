//
//  CTModule.h
//  CTMediator-Extension
//
//  Created by yiyizuche on 2017/3/27.
//  Copyright © 2017年 yyzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMediatorContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CTModule <NSObject>

/**
 *  module did create
 */
- (void)moduleDidInit:(CTMediatorContext *)context;

@end

NS_ASSUME_NONNULL_END
