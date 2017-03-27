//
//  CTMediatorContext.h
//  CTMediator-Extension
//
//  Created by yiyizuche on 2017/3/27.
//  Copyright © 2017年 yyzc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMediatorContext : NSObject

/**
 *  Get the singletion
 */
+ (instancetype)sharedContext;

@end


@interface CTMediatorContext (Module)

/**
 *  register a module with it's class name
 */
- (void)registerModule:(Class)moduleClass;

/**
 *  init all the module registered
 */
- (void)loadModules;

/**
 *  Find the module instance
 */
- (__nullable id)findModule:(Class)moduleClass;



@end

NS_ASSUME_NONNULL_END
