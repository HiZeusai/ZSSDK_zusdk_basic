//
//  ZUSDKBasicWrapper.h
//  ZUSDKBasicWrapper
//
//  Created for SPM bundle resource access
//

#import <Foundation/Foundation.h>

#if __has_include(<UIKit/UIKit.h>)
@class UIImage;
#endif

NS_ASSUME_NONNULL_BEGIN

/// ZUSDKBasicWrapper 提供访问 ZUSDK.bundle 资源的辅助方法
/// 用于解决 SPM 包中资源访问的问题
@interface ZUSDKBasicWrapper : NSObject

/// 获取 ZUSDK.bundle 的 Bundle 实例
/// SPM会将资源打包到模块的bundle中，通过此方法可以正确访问ZUSDK.bundle
/// @return ZUSDK.bundle 的 Bundle 实例，如果找不到则返回模块bundle
+ (NSBundle *)zusdkBundle;

/// 获取 ZUSDK.bundle 中 Localizable 目录的路径
/// 用于访问本地化字符串文件
/// @param languageFileName 语言文件名，例如 "en.lproj/Localizable.strings"
/// @return Localizable 目录的完整路径，如果找不到则返回 nil
+ (nullable NSString *)localizablePathForLanguageFile:(NSString *)languageFileName;

/// 获取 ZUSDK.bundle 中指定资源的路径
/// @param resourceName 资源名称
/// @param resourceType 资源类型（扩展名，不含点号）
/// @param subdirectory 子目录，例如 "Images" 或 "Localizable"
/// @return 资源的完整路径，如果找不到则返回 nil
+ (nullable NSString *)pathForResource:(NSString *)resourceName
                                 ofType:(nullable NSString *)resourceType
                          inDirectory:(nullable NSString *)subdirectory;

#if __has_include(<UIKit/UIKit.h>)
/// 从 ZUSDK.bundle 中加载图片
/// @param name 图片名称（不含扩展名和 @2x/@3x 后缀，例如 "pb_apple"）
/// @param directory 图片所在目录，默认为 "Images"
/// @return UIImage 实例，如果找不到则返回 nil
+ (nullable UIImage *)imageNamed:(NSString *)name inDirectory:(nullable NSString *)directory;
#endif

/// 测试方法：验证 ZUSDKBasicWrapper 是否正常工作
/// 调用此方法会输出详细的调试信息
+ (void)testZUSDKBundleAccess;

@end

NS_ASSUME_NONNULL_END

