import Foundation

/// 辅助类用于获取模块 bundle
private class BundleHelper: NSObject {}

public enum ZUSDKBasicWrapper {
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
            print("[ZUSDK] 🧪 ✅ 找到图片: \(imagePath)")
        } else {
            print("[ZUSDK] 🧪 ❌ 未找到图片")
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
        print("[ZUSDK] 🚀 Swift: bundle 属性被访问")
        
        // 确保 bundle 已复制到主应用
        ensureInitialized()
        
        // 方式1: 从主bundle中查找（优先，因为用户代码使用 Bundle.main）
        print("[ZUSDK] 🔍 Swift: 方法1 - 从主 bundle 查找")
        if let bundlePath = Bundle.main.path(forResource: "ZUSDK", ofType: "bundle") {
            print("[ZUSDK] 📦 Swift: 主 bundle 中找到路径: \(bundlePath)")
            if let bundle = Bundle(path: bundlePath) {
                print("[ZUSDK] ✅ Swift: 成功创建 bundle: \(bundle.bundlePath)")
                return bundle
            } else {
                print("[ZUSDK] ❌ Swift: 无法从路径创建 bundle: \(bundlePath)")
            }
        } else {
            print("[ZUSDK] ⚠️ Swift: 主 bundle 中未找到 ZUSDK.bundle")
        }
        
        // 方式2: 从当前模块的Resources中查找（SPM标准方式）
        print("[ZUSDK] 🔍 Swift: 方法2 - 从模块 bundle 查找")
        let frameworkBundle = moduleBundle
        print("[ZUSDK] 📦 Swift: 模块 bundle 路径: \(frameworkBundle.bundlePath)")
        print("[ZUSDK] 📦 Swift: 模块 bundle resourcePath: \(frameworkBundle.resourcePath ?? "(nil)")")
        
        // 列出模块 bundle 中的所有资源
        if let resourcePath = frameworkBundle.resourcePath {
            print("[ZUSDK] 📂 Swift: 模块资源目录内容:")
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                for item in contents {
                    print("[ZUSDK] 📂   - \(item)")
                }
            }
        }
        
        if let bundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle") {
            print("[ZUSDK] 📦 Swift: 模块 bundle 中找到路径: \(bundlePath)")
            if let bundle = Bundle(path: bundlePath) {
                print("[ZUSDK] ✅ Swift: 成功创建 bundle: \(bundle.bundlePath)")
                return bundle
            } else {
                print("[ZUSDK] ❌ Swift: 无法从路径创建 bundle: \(bundlePath)")
            }
        } else {
            print("[ZUSDK] ⚠️ Swift: 模块 bundle 中未找到 ZUSDK.bundle")
            
            // 尝试直接查找资源目录
            if let resourcePath = frameworkBundle.resourcePath {
                let zusdkBundlePath = (resourcePath as NSString).appendingPathComponent("ZUSDK.bundle")
                print("[ZUSDK] 🔍 Swift: 尝试直接路径: \(zusdkBundlePath)")
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: zusdkBundlePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    print("[ZUSDK] ✅ Swift: 找到 ZUSDK.bundle 目录: \(zusdkBundlePath)")
                    if let bundle = Bundle(path: zusdkBundlePath) {
                        print("[ZUSDK] ✅ Swift: 成功创建 bundle: \(bundle.bundlePath)")
                        return bundle
                    }
                } else {
                    print("[ZUSDK] ❌ Swift: 路径不存在或不是目录")
                }
            }
        }
        
        // 方式3: 从所有框架 bundle 中查找
        print("[ZUSDK] 🔍 Swift: 方法3 - 从所有 bundle 查找")
        let allBundles = Bundle.allBundles
        print("[ZUSDK] 📦 Swift: 找到 \(allBundles.count) 个 bundle")
        for b in allBundles {
            print("[ZUSDK] 📦 Swift: 检查 bundle: \(b.bundlePath)")
            if let path = b.path(forResource: "ZUSDK", ofType: "bundle") {
                print("[ZUSDK] ✅ Swift: 在 bundle 中找到 ZUSDK.bundle: \(path)")
                if let bundle = Bundle(path: path) {
                    return bundle
                }
            }
        }
        
        // 回退到模块bundle
        print("[ZUSDK] ⚠️ Swift: 所有方法都失败，回退到模块 bundle: \(frameworkBundle.bundlePath)")
        return frameworkBundle
    }
}

