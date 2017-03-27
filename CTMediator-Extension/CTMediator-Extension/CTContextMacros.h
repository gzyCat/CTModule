//
//  CTContextMacros.h
//  CTMediator-Extension
//
//  Created by yiyizuche on 2017/3/27.
//  Copyright © 2017年 yyzc. All rights reserved.
//

#ifndef CTContextMacros_h
#define CTContextMacros_h

#define AppModule "AppModuleLord"

#define CTAnnotationDATA __attribute((used, section("__DATA,"#AppModule"")))

/**
 *  Use this to annotation a `module`
 *  like this: @AppLordModule()
 */
#define CTModule(modName) \
protocol CTModule; \
char * kAppLordModule_##modName CTAnnotationDATA = "M:"#modName"";

#endif /* CTContextMacros_h */
