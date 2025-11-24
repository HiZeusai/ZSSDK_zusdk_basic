//
//  ZUSDKBasicWrapper.m
//  ZUSDKBasicWrapper
//
//  Created for SPM bundle resource access
//

#import "ZUSDKBasicWrapper.h"
#import <objc/runtime.h>
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

// 注意：这是一个纯 Objective-C target，不导入 Swift 代码
// Swift 代码在 ZUSDKBasicWrapper target 中

@implementation ZUSDKBasicWrapper

/// 在类加载时自动执行，设置方法交换
/// 这样用户的代码就可以通过 Bundle.main 访问资源，无需修改调用方式
+ (void)load {
    NSLog(@"[ZUSDK] 🚀 ZUSDKBasicWrapper 类加载中...");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[ZUSDK] 🔧 开始设置方法交换...");
        [self swizzleBundleMainPathForResource];
        NSLog(@"[ZUSDK] ✅ 方法交换设置完成");
    });
}

/// 在类初始化时也执行一次（确保被调用）
+ (void)initialize {
    if (self == [ZUSDKBasicWrapper class]) {
        NSLog(@"[ZUSDK] 🔄 ZUSDKBasicWrapper initialize 被调用");
    }
}

/// 保存原始方法的实现
static NSString * (*original_pathForResource_ofType_)(id, SEL, NSString *, NSString *) = NULL;

/// 方法交换：拦截 Bundle.main 的 pathForResource:ofType: 方法
/// 当查找 "ZUSDK.bundle/Localizable" 或 "ZUSDK.bundle/Images" 时，从模块 bundle 中查找
+ (void)swizzleBundleMainPathForResource {
    NSLog(@"[ZUSDK] 🔧 开始执行方法交换...");
    Class bundleClass = [NSBundle class];
    
    // 获取原始方法
    Method originalMethod = class_getInstanceMethod(bundleClass, @selector(pathForResource:ofType:));
    NSLog(@"[ZUSDK] 📋 原始方法: %@", originalMethod ? @"找到" : @"未找到");
    
    // 获取新方法（如果不存在则添加）
    Method swizzledMethod = class_getInstanceMethod(bundleClass, @selector(zusdk_pathForResource:ofType:));
    NSLog(@"[ZUSDK] 📋 交换方法: %@", swizzledMethod ? @"找到" : @"未找到");
    
    if (originalMethod && swizzledMethod) {
        // 保存原始实现
        original_pathForResource_ofType_ = (NSString * (*)(id, SEL, NSString *, NSString *))method_getImplementation(originalMethod);
        NSLog(@"[ZUSDK] 💾 已保存原始方法实现");
        
        // 检查是否已经交换过（避免重复交换）
        IMP originalIMP = method_getImplementation(originalMethod);
        IMP swizzledIMP = method_getImplementation(swizzledMethod);
        
        if (originalIMP != swizzledIMP) {
            // 交换实现
            method_exchangeImplementations(originalMethod, swizzledMethod);
            NSLog(@"[ZUSDK] ✅ 方法交换成功完成");
        } else {
            NSLog(@"[ZUSDK] ⚠️ 方法已经交换过，跳过");
        }
    } else {
        NSLog(@"[ZUSDK] ❌ 方法交换失败：找不到方法");
    }
}

/// 交换后的 pathForResource:ofType: 方法
/// 当在 Bundle.main 中查找 ZUSDK.bundle 相关资源时，从模块 bundle 中查找
- (NSString *)zusdk_pathForResource:(NSString *)name ofType:(NSString *)ext {
    // 只处理 Bundle.main 的情况
    if ([self isEqual:[NSBundle mainBundle]]) {
        // 检查是否查找 ZUSDK.bundle 相关资源
        if (name && [name containsString:@"ZUSDK.bundle"]) {
            NSLog(@"[ZUSDK] 🎯 方法交换拦截到 ZUSDK.bundle 资源查找: name=%@, ext=%@", name, ext ?: @"(nil)");
            NSLog(@"[ZUSDK] 🎯 调用栈: %@", [NSThread callStackSymbols]);
            // 解析路径：例如 "ZUSDK.bundle/Localizable" -> "Localizable"
            NSString *resourcePath = name;
            if ([resourcePath hasPrefix:@"ZUSDK.bundle/"]) {
                resourcePath = [resourcePath substringFromIndex:@"ZUSDK.bundle/".length];
            }
            
            // 从模块 bundle 中查找 ZUSDK.bundle
            NSBundle *moduleBundle = [NSBundle bundleForClass:[ZUSDKBasicWrapper class]];
            NSLog(@"[ZUSDK] 🔍 查找 ZUSDK.bundle - 模块 bundle: %@", moduleBundle.bundlePath);
            
            NSString *zusdkBundlePath = [moduleBundle pathForResource:@"ZUSDK" ofType:@"bundle"];
            NSLog(@"[ZUSDK] 📦 pathForResource 返回路径: %@", zusdkBundlePath ?: @"(nil)");
            
            // 确保路径不为空且有效
            if (zusdkBundlePath && zusdkBundlePath.length > 0 && [zusdkBundlePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
                // 验证路径是否存在
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL isDirectory = NO;
                BOOL exists = [fileManager fileExistsAtPath:zusdkBundlePath isDirectory:&isDirectory];
                NSLog(@"[ZUSDK] 📂 路径检查 - 存在: %@, 是目录: %@, 路径: %@", exists ? @"YES" : @"NO", isDirectory ? @"YES" : @"NO", zusdkBundlePath);
                
                if (exists && isDirectory) {
                    // 再次验证路径不为空（防止某些边缘情况）
                    NSString *trimmedPath = [zusdkBundlePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSLog(@"[ZUSDK] ✂️ 去除空白后路径: %@ (长度: %lu)", trimmedPath, (unsigned long)trimmedPath.length);
                    
                    if (trimmedPath.length > 0) {
                        NSLog(@"[ZUSDK] 🔨 尝试创建 NSBundle，路径: %@", trimmedPath);
                        NSBundle *zusdkBundle = [NSBundle bundleWithPath:trimmedPath];
                        if (zusdkBundle) {
                            NSLog(@"[ZUSDK] ✅ NSBundle 创建成功: %@", zusdkBundle.bundlePath);
                            // 在 ZUSDK.bundle 中查找资源
                            // 如果 resourcePath 是 "Localizable"，查找目录
                            // 如果 resourcePath 是 "Images"，查找目录
                            NSString *path = [zusdkBundle pathForResource:resourcePath ofType:nil];
                            if (path && path.length > 0) {
                                return path;
                            }
                            
                            // 如果 resourcePath 包含路径分隔符，尝试作为目录查找
                            if ([resourcePath containsString:@"/"]) {
                                NSArray *components = [resourcePath pathComponents];
                                if (components.count > 0) {
                                    NSString *directory = components[0];
                                    path = [zusdkBundle pathForResource:directory ofType:nil];
                                    if (path && path.length > 0) {
                                        // 返回目录路径，用户可以继续拼接
                                        return path;
                                    }
                                }
                            }
                        } else {
                            NSLog(@"[ZUSDK] ❌ NSBundle 创建失败，路径: %@", trimmedPath);
                        }
                    } else {
                        NSLog(@"[ZUSDK] ⚠️ 去除空白后路径为空");
                    }
                } else {
                    NSLog(@"[ZUSDK] ⚠️ 路径不存在或不是目录");
                }
            } else {
                NSLog(@"[ZUSDK] ⚠️ 路径为空或无效 (原始路径: %@, 长度: %lu)", zusdkBundlePath ?: @"(nil)", (unsigned long)(zusdkBundlePath ? zusdkBundlePath.length : 0));
            }
        }
    }
    
    // 其他情况，调用原始方法
    if (original_pathForResource_ofType_) {
        return original_pathForResource_ofType_(self, @selector(pathForResource:ofType:), name, ext);
    }
    
    // 如果原始方法不可用（理论上不应该发生），使用标准方法
    // 由于方法已交换，调用 zusdk_pathForResource 会调用原始实现
    // 但为了避免递归，我们直接返回 nil
    return nil;
}

/// 将 ZUSDK.bundle 从模块 bundle 复制到主应用 bundle（如果可能）
/// 注意：iOS 主 bundle 是只读的，所以实际上无法复制到主 bundle
/// 但我们可以通过 swizzling 或提供辅助方法来让用户的代码正常工作
+ (void)copyZUSDKBundleToMainBundleIfNeeded {
    // iOS 主 bundle 是只读的，无法在运行时复制文件到其中
    // 但我们可以通过方法交换让用户的代码正常工作
    // 方法交换已经在 +load 中完成
}

+ (NSBundle *)zusdkBundle {
    NSLog(@"[ZUSDK] 🚀 zusdkBundle 方法被调用");
    
    // 确保 bundle 已复制到主应用
    [self copyZUSDKBundleToMainBundleIfNeeded];
    
    // 优先从主 bundle 中查找（用户代码使用 Bundle.main）
    NSLog(@"[ZUSDK] 🔍 方法1: 从主 bundle 查找");
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ZUSDK" ofType:@"bundle"];
    NSLog(@"[ZUSDK] 📦 主 bundle pathForResource 返回: %@", bundlePath ?: @"(nil)");
    
    if (bundlePath && bundlePath.length > 0) {
        NSString *trimmedPath = [bundlePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"[ZUSDK] ✂️ 主 bundle 路径去除空白后: %@", trimmedPath);
        if (trimmedPath.length > 0) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDirectory = NO;
            BOOL exists = [fileManager fileExistsAtPath:trimmedPath isDirectory:&isDirectory];
            NSLog(@"[ZUSDK] 📂 主 bundle 路径检查 - 存在: %@, 是目录: %@", exists ? @"YES" : @"NO", isDirectory ? @"YES" : @"NO");
            if (exists && isDirectory) {
                NSLog(@"[ZUSDK] 🔨 尝试从主 bundle 创建 NSBundle: %@", trimmedPath);
                NSBundle *zusdkBundle = [NSBundle bundleWithPath:trimmedPath];
                if (zusdkBundle) {
                    NSLog(@"[ZUSDK] ✅ 从主 bundle 成功创建 NSBundle: %@", zusdkBundle.bundlePath);
                    return zusdkBundle;
                } else {
                    NSLog(@"[ZUSDK] ❌ 从主 bundle 创建 NSBundle 失败: %@", trimmedPath);
                }
            }
        }
    } else {
        NSLog(@"[ZUSDK] ⚠️ 主 bundle 中未找到 ZUSDK.bundle");
    }
    
    // 从模块 bundle 中查找（SPM 标准方式）
    NSLog(@"[ZUSDK] 🔍 方法2: 从模块 bundle 查找");
    NSBundle *moduleBundle = [NSBundle bundleForClass:[ZUSDKBasicWrapper class]];
    NSLog(@"[ZUSDK] 📦 模块 bundle: %@", moduleBundle.bundlePath);
    bundlePath = [moduleBundle pathForResource:@"ZUSDK" ofType:@"bundle"];
    NSLog(@"[ZUSDK] 📦 模块 bundle pathForResource 返回: %@", bundlePath ?: @"(nil)");
    if (bundlePath && bundlePath.length > 0) {
        NSString *trimmedPath = [bundlePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"[ZUSDK] ✂️ 模块 bundle 路径去除空白后: %@", trimmedPath);
        if (trimmedPath.length > 0) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDirectory = NO;
            BOOL exists = [fileManager fileExistsAtPath:trimmedPath isDirectory:&isDirectory];
            NSLog(@"[ZUSDK] 📂 模块 bundle 路径检查 - 存在: %@, 是目录: %@", exists ? @"YES" : @"NO", isDirectory ? @"YES" : @"NO");
            if (exists && isDirectory) {
                NSLog(@"[ZUSDK] 🔨 尝试从模块 bundle 创建 NSBundle: %@", trimmedPath);
                NSBundle *zusdkBundle = [NSBundle bundleWithPath:trimmedPath];
                if (zusdkBundle) {
                    NSLog(@"[ZUSDK] ✅ 从模块 bundle 成功创建 NSBundle: %@", zusdkBundle.bundlePath);
                    return zusdkBundle;
                } else {
                    NSLog(@"[ZUSDK] ❌ 从模块 bundle 创建 NSBundle 失败: %@", trimmedPath);
                }
            }
        }
    } else {
        NSLog(@"[ZUSDK] ⚠️ 模块 bundle 中未找到 ZUSDK.bundle");
    }
    
    // 从所有框架 bundle 中查找
    NSLog(@"[ZUSDK] 🔍 方法3: 从所有框架 bundle 查找");
    NSArray *allBundles = [NSBundle allBundles];
    NSLog(@"[ZUSDK] 📦 找到 %lu 个 bundle", (unsigned long)allBundles.count);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSBundle *bundle in allBundles) {
        NSString *path = [bundle pathForResource:@"ZUSDK" ofType:@"bundle"];
        NSLog(@"[ZUSDK] 🔍 检查 bundle: %@, 路径: %@", bundle.bundlePath, path ?: @"(nil)");
        if (path && path.length > 0) {
            NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmedPath.length > 0) {
                BOOL isDirectory = NO;
                BOOL exists = [fileManager fileExistsAtPath:trimmedPath isDirectory:&isDirectory];
                NSLog(@"[ZUSDK] 📂 框架 bundle 路径检查 - 存在: %@, 是目录: %@, 路径: %@", exists ? @"YES" : @"NO", isDirectory ? @"YES" : @"NO", trimmedPath);
                if (exists && isDirectory) {
                    NSLog(@"[ZUSDK] 🔨 尝试从框架 bundle 创建 NSBundle: %@", trimmedPath);
                    NSBundle *zusdkBundle = [NSBundle bundleWithPath:trimmedPath];
                    if (zusdkBundle) {
                        NSLog(@"[ZUSDK] ✅ 从框架 bundle 成功创建 NSBundle: %@", zusdkBundle.bundlePath);
                        return zusdkBundle;
                    } else {
                        NSLog(@"[ZUSDK] ❌ 从框架 bundle 创建 NSBundle 失败: %@", trimmedPath);
                    }
                }
            }
        }
    }
    
    // 回退到模块 bundle
    NSLog(@"[ZUSDK] ⚠️ 所有方法都失败，回退到模块 bundle: %@", moduleBundle.bundlePath);
    return moduleBundle;
}

+ (nullable NSString *)localizablePathForLanguageFile:(NSString *)languageFileName {
    NSBundle *zusdkBundle = [self zusdkBundle];
    
    // languageFileName 格式通常是: "en.lproj/Localizable.strings" 或 "zh-Hans.lproj/Localizable.strings"
    // 我们需要在 ZUSDK.bundle 的 Localizable 目录下查找
    
    // 方法1: 获取 Localizable 目录路径，然后拼接语言文件路径（最可靠的方式）
    NSString *localizableDir = [zusdkBundle pathForResource:@"Localizable" ofType:nil];
    if (localizableDir) {
        NSString *fullPath = [localizableDir stringByAppendingPathComponent:languageFileName];
        // 检查文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            return fullPath;
        }
    }
    
    // 方法2: 使用 pathForResource:ofType:inDirectory: 方法
    // 如果 languageFileName 是 "en.lproj/Localizable.strings"
    // 我们需要分离出文件名和目录
    NSArray *pathComponents = [languageFileName pathComponents];
    if (pathComponents.count >= 2) {
        // 例如: ["en.lproj", "Localizable.strings"]
        NSString *lprojDir = pathComponents[0]; // "en.lproj"
        NSString *fileName = pathComponents[1]; // "Localizable.strings"
        
        // 在 Localizable/en.lproj 目录下查找 Localizable.strings
        NSString *subDirectory = [@"Localizable" stringByAppendingPathComponent:lprojDir];
        NSString *resourceName = [fileName stringByDeletingPathExtension]; // "Localizable"
        NSString *resourceType = [fileName pathExtension]; // "strings"
        
        NSString *path = [zusdkBundle pathForResource:resourceName 
                                                ofType:resourceType 
                                           inDirectory:subDirectory];
        if (path) {
            return path;
        }
    }
    
    // 方法3: 如果 languageFileName 只是文件名（不含路径），在 Localizable 目录下查找
    if (![languageFileName containsString:@"/"]) {
        NSString *path = [zusdkBundle pathForResource:languageFileName ofType:nil inDirectory:@"Localizable"];
        if (path) {
            return path;
        }
    }
    
    // 方法4: 尝试直接查找（适用于完整路径的情况）
    NSString *path = [zusdkBundle pathForResource:nil ofType:nil inDirectory:[@"Localizable" stringByAppendingPathComponent:languageFileName]];
    if (path) {
        return path;
    }
    
    return nil;
}

+ (nullable NSString *)pathForResource:(NSString *)resourceName
                                 ofType:(nullable NSString *)resourceType
                          inDirectory:(nullable NSString *)subdirectory {
    NSBundle *zusdkBundle = [self zusdkBundle];
    return [zusdkBundle pathForResource:resourceName ofType:resourceType inDirectory:subdirectory];
}

+ (nullable UIImage *)imageNamed:(NSString *)name inDirectory:(nullable NSString *)directory {
    if (!name || name.length == 0) {
        return nil;
    }
    
    NSString *imageDirectory = directory ?: @"Images";
    NSBundle *zusdkBundle = [self zusdkBundle];
    
    // 方法1: 使用 UIImage(named:in:compatibleWith:) - 推荐方式
    // 先尝试直接名称（系统会自动选择 @2x/@3x）
    UIImage *image = [UIImage imageNamed:name inBundle:zusdkBundle compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    }
    
    // 方法2: 尝试添加 @2x 后缀
    NSString *nameWith2x = [NSString stringWithFormat:@"%@@2x", name];
    image = [UIImage imageNamed:nameWith2x inBundle:zusdkBundle compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    }
    
    // 方法3: 尝试添加 @3x 后缀
    NSString *nameWith3x = [NSString stringWithFormat:@"%@@3x", name];
    image = [UIImage imageNamed:nameWith3x inBundle:zusdkBundle compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    }
    
    // 方法4: 使用 pathForResource 手动加载
    NSString *imagePath = [zusdkBundle pathForResource:name ofType:@"png" inDirectory:imageDirectory];
    if (imagePath) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            return image;
        }
    }
    
    // 方法5: 尝试带 @2x 的路径
    imagePath = [zusdkBundle pathForResource:nameWith2x ofType:@"png" inDirectory:imageDirectory];
    if (imagePath) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            return image;
        }
    }
    
    // 方法6: 尝试带 @3x 的路径
    imagePath = [zusdkBundle pathForResource:nameWith3x ofType:@"png" inDirectory:imageDirectory];
    if (imagePath) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            return image;
        }
    }
    
    NSLog(@"[ZUSDK] ⚠️ 未找到图片: %@ 在目录: %@", name, imageDirectory);
    return nil;
}

/// 测试方法：验证 ZUSDKBasicWrapper 是否正常工作
+ (void)testZUSDKBundleAccess {
    NSLog(@"[ZUSDK] 🧪 ========== 开始测试 ZUSDK Bundle 访问 ==========");
    
    // 测试 1: 检查类是否加载
    NSLog(@"[ZUSDK] 🧪 测试 1: 类加载检查");
    NSLog(@"[ZUSDK] 🧪 ZUSDKBasicWrapper 类: %@", [ZUSDKBasicWrapper class]);
    
    // 测试 2: 测试 zusdkBundle 方法
    NSLog(@"[ZUSDK] 🧪 测试 2: 调用 zusdkBundle 方法");
    NSBundle *bundle = [self zusdkBundle];
    NSLog(@"[ZUSDK] 🧪 zusdkBundle 返回: %@", bundle ? bundle.bundlePath : @"(nil)");
    
    // 测试 3: 测试方法交换是否生效
    NSLog(@"[ZUSDK] 🧪 测试 3: 测试方法交换");
    NSString *testPath = [[NSBundle mainBundle] pathForResource:@"ZUSDK.bundle/Localizable" ofType:nil];
    NSLog(@"[ZUSDK] 🧪 Bundle.main.pathForResource 返回: %@", testPath ?: @"(nil)");
    
    // 测试 4: 测试 localizablePathForLanguageFile
    NSLog(@"[ZUSDK] 🧪 测试 4: 测试 localizablePathForLanguageFile");
    NSString *langPath = [self localizablePathForLanguageFile:@"en.lproj/Localizable.strings"];
    NSLog(@"[ZUSDK] 🧪 localizablePathForLanguageFile 返回: %@", langPath ?: @"(nil)");
    
    // 测试 5: 列出所有 bundle
    NSLog(@"[ZUSDK] 🧪 测试 5: 列出所有可用的 bundle");
    NSArray *allBundles = [NSBundle allBundles];
    for (NSBundle *b in allBundles) {
        NSLog(@"[ZUSDK] 🧪 Bundle: %@", b.bundlePath);
        NSString *zusdkPath = [b pathForResource:@"ZUSDK" ofType:@"bundle"];
        if (zusdkPath) {
            NSLog(@"[ZUSDK] 🧪   └─ 找到 ZUSDK.bundle: %@", zusdkPath);
        }
    }
    
    NSLog(@"[ZUSDK] 🧪 ========== 测试完成 ==========");
}

@end

