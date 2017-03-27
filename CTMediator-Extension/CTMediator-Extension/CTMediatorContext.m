//
//  CTMediatorContext.m
//  CTMediator-Extension
//
//  Created by yiyizuche on 2017/3/27.
//  Copyright © 2017年 yyzc. All rights reserved.
//

#import "CTMediatorContext.h"
#import "CTModule.h"
#import "CTContextMacros.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

NSArray<NSString *>* AppLordReadConfigFromSection(const char *sectionName){
    
#ifndef __LP64__
    const struct mach_header *mhp = NULL;
#else
    const struct mach_header_64 *mhp = NULL;
#endif
    
    NSMutableArray *configs = [NSMutableArray array];
    Dl_info info;
    if (mhp == NULL) {
        dladdr(AppLordReadConfigFromSection, &info);
#ifndef __LP64__
        mhp = (struct mach_header*)info.dli_fbase;
#else
        mhp = (struct mach_header_64*)info.dli_fbase;
#endif
    }
    
#ifndef __LP64__
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
#else /* defined(__LP64__) */
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
#endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        char *string = (char*)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [configs addObject:str];
    }
    
    return configs;
}

@interface CTMediatorContext ()
{
    NSMutableDictionary<NSString *, id<CTModule>>      *_modulesByName;
    NSMutableDictionary<NSString *, Class<CTModule>>   *_moduleClassesByName;
}
@end


@implementation CTMediatorContext

+ (instancetype)sharedContext{
    static CTMediatorContext* context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[self alloc] init];
    });
    return context;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _modulesByName = [[NSMutableDictionary alloc] init];
        _moduleClassesByName = [[NSMutableDictionary alloc] init];
        
        [self readModuleAndServiceRegistedInSection];
    }
    return self;
}

- (void)readModuleAndServiceRegistedInSection
{
    NSArray<NSString *> *dataListInSection = AppLordReadConfigFromSection(AppModule);
    for (NSString *item in dataListInSection) {
        NSArray *components = [item componentsSeparatedByString:@":"];
        if (components.count >= 2) {
            NSString *type = components[0];
            if ([type isEqualToString:@"M"]) {
                NSString *modName = components[1];
                Class modCls = NSClassFromString(modName);
                if (modCls) {
                    [self registerModule:modCls];
                }
            }
        }
    }
}

#pragma mark - module

- (void)registerModule:(Class)moduleClass
{
    NSParameterAssert(moduleClass != nil);
    
    if (![moduleClass conformsToProtocol:@protocol(CTModule)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 模块不符合 ALModule 协议", NSStringFromClass(moduleClass)] userInfo:nil];
    }
    
    if ([_moduleClassesByName objectForKey:NSStringFromClass(moduleClass)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 模块类已经注册", NSStringFromClass(moduleClass)] userInfo:nil];
    }
    
    NSString *key = NSStringFromClass(moduleClass);
    [_moduleClassesByName setObject:moduleClass forKey:key];
}

- (id)findModule:(Class)moduleClass
{
    NSString *key = NSStringFromClass(moduleClass);
    id<CTModule> module = [_modulesByName objectForKey:key];
    if (!module) {
        module = [self setupModuleWithClass:moduleClass];
    }
    return module;
}

- (id<CTModule>)setupModuleWithClass:(Class)moduleClass
{
    NSAssert([NSThread isMainThread], @"must run in main thread");
    id<CTModule> module = [[moduleClass alloc] init];
    [_modulesByName setObject:module forKey:NSStringFromClass(moduleClass)];
    if ([module respondsToSelector:@selector(moduleDidInit:)]) {
        [module moduleDidInit:self];
    }
    return module;
}

- (void)loadModules
{
    NSAssert([NSThread isMainThread], @"must run in main thread");
    NSArray *moduleClassArray = _moduleClassesByName.allValues;
    for (Class moduleClass in moduleClassArray) {
        
        [self setupModuleWithClass:moduleClass];
    }
}



@end
