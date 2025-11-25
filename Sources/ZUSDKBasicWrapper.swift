import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 辅助类用于获取模块 bundle
private class BundleHelper: NSObject {}

public enum ZUSDKBasicWrapper {
    /// 从 ZUSDK.bundle 中加载图片
    /// - Parameters:
    ///   - name: 图片名称（不含扩展名，例如 "pb_apple"）
    ///   - directory: 图片所在目录，默认为 "Images"
    /// - Returns: UIImage 实例，如果找不到则返回 nil
    public static func image(named name: String, inDirectory directory: String = "Images") -> UIImage? {
        let bundle = ZUSDKBasicWrapper.bundle
        
        // 注意：UIImage(named:in:compatibleWith:) 不会在子目录中查找，所以优先使用 pathForResource
        
        // 方法1: 使用 pathForResource 查找 @2x 图片（优先，因为大多数设备使用 @2x）
        if let imagePath = bundle.path(forResource: "\(name)@2x", ofType: "png", inDirectory: directory) {
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        // 方法2: 使用 pathForResource 查找 @3x 图片
        if let imagePath = bundle.path(forResource: "\(name)@3x", ofType: "png", inDirectory: directory) {
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        // 方法3: 尝试查找不带后缀的图片（如果有的话）
        if let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: directory) {
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        // 方法4: 尝试使用 UIImage(named:in:compatibleWith:) - 作为备用（虽然通常不会在子目录中工作）
        // 先尝试直接名称
        if let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
            return image
        }
        
        // 方法5: 尝试添加 @2x 后缀
        let nameWith2x = "\(name)@2x"
        if let image = UIImage(named: nameWith2x, in: bundle, compatibleWith: nil) {
            return image
        }
        
        // 方法6: 尝试添加 @3x 后缀
        let nameWith3x = "\(name)@3x"
        if let image = UIImage(named: nameWith3x, in: bundle, compatibleWith: nil) {
            return image
        }
        
        // 只在找不到图片时输出警告
        print("[ZUSDK] ⚠️ 未找到图片: \(name) 在目录: \(directory)")
        return nil
    }
    
    /// 测试方法：验证 ZUSDKBasicWrapper 是否正常工作
    /// 调用此方法会输出详细的调试信息
    public static func testZUSDKBundleAccess() {
        print("[ZUSDK] 🧪 ========== 开始测试 ZUSDK Bundle 访问 (Swift) ==========")
        
        // 测试 1: 检查类是否加载
        print("[ZUSDK] 🧪 测试 1: 访问 bundle 属性")
        let bundle = ZUSDKBasicWrapper.bundle
        print("[ZUSDK] 🧪 bundle 路径: \(bundle.bundlePath)")
        
        // 测试 2: 测试资源访问
        print("[ZUSDK] 🧪 测试 2: 测试 Localizable 目录")
        if let localizableDir = bundle.path(forResource: "Localizable", ofType: nil) {
            print("[ZUSDK] 🧪 ✅ 找到 Localizable 目录: \(localizableDir)")
            
            // 测试语言文件
            let enPath = (localizableDir as NSString).appendingPathComponent("en.lproj/Localizable.strings")
            if FileManager.default.fileExists(atPath: enPath) {
                print("[ZUSDK] 🧪 ✅ 找到英文语言文件: \(enPath)")
            } else {
                print("[ZUSDK] 🧪 ❌ 未找到英文语言文件: \(enPath)")
            }
        } else {
            print("[ZUSDK] 🧪 ❌ 未找到 Localizable 目录")
        }
        
        // 测试 3: 测试图片资源
        print("[ZUSDK] 🧪 测试 3: 测试图片资源")
        if let imagePath = bundle.path(forResource: "pb_apple@2x", ofType: "png", inDirectory: "Images") {
            print("[ZUSDK] 🧪 ✅ 找到图片路径: \(imagePath)")
            
            // 测试使用辅助方法加载图片
            if let image = ZUSDKBasicWrapper.image(named: "pb_apple") {
                print("[ZUSDK] 🧪 ✅ 成功加载图片，尺寸: \(image.size)")
            } else {
                print("[ZUSDK] 🧪 ❌ 无法加载图片")
            }
        } else {
            print("[ZUSDK] 🧪 ❌ 未找到图片路径")
        }
        
        // 测试 4: 列出所有 bundle
        print("[ZUSDK] 🧪 测试 4: 列出所有可用的 bundle")
        let allBundles = Bundle.allBundles
        print("[ZUSDK] 🧪 找到 \(allBundles.count) 个 bundle")
        for b in allBundles {
            print("[ZUSDK] 🧪 Bundle: \(b.bundlePath)")
            if let zusdkPath = b.path(forResource: "ZUSDK", ofType: "bundle") {
                print("[ZUSDK] 🧪   └─ 找到 ZUSDK.bundle: \(zusdkPath)")
            }
        }
        
        print("[ZUSDK] 🧪 ========== 测试完成 ==========")
    }
    /// 静态初始化器，在模块加载时自动执行
    /// 将 ZUSDK.bundle 从模块 bundle 复制到主应用 bundle，以便通过 Bundle.main 访问
    private static let _initialized: Void = {
        copyZUSDKBundleToMainBundle()
    }()
    
    /// 确保初始化器被执行
    private static func ensureInitialized() {
        _ = _initialized
    }
    
    /// 获取模块 bundle
    private static var moduleBundle: Bundle {
        // 使用辅助类来获取模块 bundle
        return Bundle(for: BundleHelper.self)
    }
    
    /// 将 ZUSDK.bundle 从模块 bundle 复制到主应用 bundle
    private static func copyZUSDKBundleToMainBundle() {
        // 检查主 bundle 中是否已经存在 ZUSDK.bundle
        if Bundle.main.path(forResource: "ZUSDK", ofType: "bundle") != nil {
            return // 已经存在，不需要复制
        }
        
        // 从模块 bundle 中查找 ZUSDK.bundle
        let frameworkBundle = moduleBundle
        guard let frameworkBundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle") else {
            return // 找不到源 bundle
        }
        
        // 复制 bundle 到主应用 bundle
        copyBundle(from: frameworkBundlePath, to: Bundle.main.bundlePath)
    }
    
    /// 复制 bundle 文件到目标目录
    private static func copyBundle(from sourcePath: String, to destinationDir: String) {
        let fileManager = FileManager.default
        let bundleName = (sourcePath as NSString).lastPathComponent
        let destinationPath = (destinationDir as NSString).appendingPathComponent(bundleName)
        
        // 如果目标位置已存在，先删除
        if fileManager.fileExists(atPath: destinationPath) {
            try? fileManager.removeItem(atPath: destinationPath)
        }
        
        // 复制 bundle
        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
        } catch {
            // 复制失败，静默处理（不影响正常使用）
        }
    }
    
    /// 获取ZUSDK.bundle
    /// SPM会将资源打包到模块的bundle中，通过此方法可以正确访问ZUSDK.bundle
    public static var bundle: Bundle {
        // 确保 bundle 已复制到主应用
        ensureInitialized()
        
        // 注意：Bundle.module 是 SPM 自动生成的，但可能在某些构建配置下不可用
        // 我们优先使用其他更可靠的方法
        
        // 方式1: 从主bundle中查找（优先，因为用户代码使用 Bundle.main）
        if let bundlePath = Bundle.main.path(forResource: "ZUSDK", ofType: "bundle") {
            if let bundle = Bundle(path: bundlePath) {
                return bundle
            }
        }
        
        // 方式2: 从当前模块的Resources中查找（SPM标准方式）
        let frameworkBundle = moduleBundle
        
        // 检查是否是主应用 bundle（说明 SPM 模块可能被编译成 framework）
        let mainBundlePath = Bundle.main.bundlePath
        if frameworkBundle.bundlePath == mainBundlePath {
            print("[ZUSDK] ⚠️ Swift: 模块 bundle 与主应用 bundle 相同，尝试在 Frameworks 中查找")
            
            // 在 Frameworks 目录中查找 SPM 模块
            let frameworksPath = (mainBundlePath as NSString).appendingPathComponent("Frameworks")
            let fileManager = FileManager.default
            var isDirectory: ObjCBool = false
            
            if fileManager.fileExists(atPath: frameworksPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                print("[ZUSDK] 📂 Swift: 检查 Frameworks 目录: \(frameworksPath)")
                if let frameworks = try? fileManager.contentsOfDirectory(atPath: frameworksPath) {
                    for frameworkName in frameworks {
                        // 查找可能的 SPM 模块 framework（通常以包名或 target 名命名）
                        if frameworkName.hasSuffix(".framework") || frameworkName.contains("ZUSDK") || frameworkName.contains("ZSSDK") {
                            let frameworkPath = (frameworksPath as NSString).appendingPathComponent(frameworkName)
                            print("[ZUSDK] 🔍 Swift: 检查 framework: \(frameworkPath)")
                            
                            // 尝试作为 framework bundle 加载
                            if let frameworkBundle = Bundle(path: frameworkPath) {
                                print("[ZUSDK] 📦 Swift: 找到 framework bundle: \(frameworkBundle.bundlePath)")
                                
                                // 在 framework 中查找 ZUSDK.bundle
                                if let bundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle") {
                                    print("[ZUSDK] ✅ Swift: 在 framework 中找到 ZUSDK.bundle: \(bundlePath)")
                                    if let bundle = Bundle(path: bundlePath) {
                                        print("[ZUSDK] ✅ Swift: 成功创建 bundle: \(bundle.bundlePath)")
                                        return bundle
                                    }
                                }
                                
                                // 尝试在 framework 的 resourcePath 中查找
                                if let resourcePath = frameworkBundle.resourcePath {
                                    let zusdkBundlePath = (resourcePath as NSString).appendingPathComponent("ZUSDK.bundle")
                                    print("[ZUSDK] 🔍 Swift: 尝试 framework resourcePath: \(zusdkBundlePath)")
                                    var isDir: ObjCBool = false
                                    if fileManager.fileExists(atPath: zusdkBundlePath, isDirectory: &isDir) && isDir.boolValue {
                                        print("[ZUSDK] ✅ Swift: 找到 ZUSDK.bundle: \(zusdkBundlePath)")
                                        if let bundle = Bundle(path: zusdkBundlePath) {
                                            print("[ZUSDK] ✅ Swift: 成功创建 bundle: \(bundle.bundlePath)")
                                            return bundle
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // SPM 会将资源 bundle 命名为 {PackageName}_{TargetName}.bundle
        // 例如: ZSSDK_zusdk_basic_ZUSDKBasicWrapper.bundle
        if let resourcePath = frameworkBundle.resourcePath {
            let spmBundleName = "ZSSDK_zusdk_basic_ZUSDKBasicWrapper.bundle"
            let spmBundlePath = (resourcePath as NSString).appendingPathComponent(spmBundleName)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: spmBundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                if let spmBundle = Bundle(path: spmBundlePath) {
                    // 在 SPM bundle 中查找 ZUSDK.bundle
                    if let zusdkBundlePath = spmBundle.path(forResource: "ZUSDK", ofType: "bundle") {
                        if let zusdkBundle = Bundle(path: zusdkBundlePath) {
                            return zusdkBundle
                        }
                    }
                    // 如果 SPM bundle 本身就是资源 bundle，直接返回
                    return spmBundle
                }
            }
        }
        
        if let bundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle") {
            if let bundle = Bundle(path: bundlePath) {
                return bundle
            }
        }
        
        // 尝试直接查找资源目录
        if let resourcePath = frameworkBundle.resourcePath {
            let zusdkBundlePath = (resourcePath as NSString).appendingPathComponent("ZUSDK.bundle")
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: zusdkBundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                if let bundle = Bundle(path: zusdkBundlePath) {
                    return bundle
                }
            }
        }
        
        // 方式3: 从所有框架 bundle 中查找
        let allBundles = Bundle.allBundles
        for b in allBundles {
            let bundlePath = b.bundlePath
            
            // 跳过主应用 bundle（已经检查过了）
            if bundlePath == Bundle.main.bundlePath {
                continue
            }
            
            // 方法3a: 检查是否是 SPM 资源 bundle (ZSSDK_zusdk_basic_ZUSDKBasicWrapper.bundle)
            if bundlePath.hasSuffix("ZSSDK_zusdk_basic_ZUSDKBasicWrapper.bundle") {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: bundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    // 在 SPM bundle 中查找 ZUSDK.bundle
                    if let zusdkBundlePath = b.path(forResource: "ZUSDK", ofType: "bundle") {
                        if let zusdkBundle = Bundle(path: zusdkBundlePath) {
                            return zusdkBundle
                        }
                    }
                    // 如果 SPM bundle 本身就是资源 bundle，直接返回
                    return b
                }
            }
            
            // 方法3b: 检查 bundle 路径本身是否就是 ZUSDK.bundle
            if bundlePath.hasSuffix("ZUSDK.bundle") {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: bundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    return b
                }
            }
            
            // 方法3c: 在 framework bundle 中查找
            if let path = b.path(forResource: "ZUSDK", ofType: "bundle") {
                if let bundle = Bundle(path: path) {
                    return bundle
                }
            }
            
            // 方法3d: 检查 bundle 路径的父目录中是否有 ZUSDK.bundle
            let parentDir = (bundlePath as NSString).deletingLastPathComponent
            let zusdkBundlePath = (parentDir as NSString).appendingPathComponent("ZUSDK.bundle")
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: zusdkBundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                if let bundle = Bundle(path: zusdkBundlePath) {
                    return bundle
                }
            }
            
            // 方法3e: 尝试在 framework 的 resourcePath 中查找
            if let resourcePath = b.resourcePath {
                let zusdkBundlePath2 = (resourcePath as NSString).appendingPathComponent("ZUSDK.bundle")
                var isDirectory2: ObjCBool = false
                if FileManager.default.fileExists(atPath: zusdkBundlePath2, isDirectory: &isDirectory2) && isDirectory2.boolValue {
                    if let bundle = Bundle(path: zusdkBundlePath2) {
                        return bundle
                    }
                }
            }
        }
        
        // 回退到模块bundle
        return frameworkBundle
    }
}

