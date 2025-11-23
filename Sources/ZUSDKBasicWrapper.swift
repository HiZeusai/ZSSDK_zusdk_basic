import Foundation

public enum ZUSDKBasicWrapper {
    /// 静态初始化器，在模块加载时自动执行
    /// 将 ZUSDK.bundle 从模块 bundle 复制到主应用 bundle，以便通过 Bundle.main 访问
    private static let _initialized: Void = {
        copyZUSDKBundleToMainBundle()
    }()
    
    /// 确保初始化器被执行
    private static func ensureInitialized() {
        _ = _initialized
    }
    
    /// 将 ZUSDK.bundle 从模块 bundle 复制到主应用 bundle
    private static func copyZUSDKBundleToMainBundle() {
        // 检查主 bundle 中是否已经存在 ZUSDK.bundle
        if Bundle.main.path(forResource: "ZUSDK", ofType: "bundle") != nil {
            return // 已经存在，不需要复制
        }
        
        // 从模块 bundle 中查找 ZUSDK.bundle
        guard let sourceBundlePath = Bundle.module.path(forResource: "ZUSDK", ofType: "bundle") else {
            // 如果模块 bundle 中也没有，尝试从框架 bundle 中查找
            let frameworkBundle = Bundle(for: ZUSDKBasicWrapper.self)
            guard let frameworkBundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle") else {
                return // 找不到源 bundle
            }
            copyBundle(from: frameworkBundlePath, to: Bundle.main.bundlePath)
            return
        }
        
        // 复制 bundle 到主应用 bundle
        copyBundle(from: sourceBundlePath, to: Bundle.main.bundlePath)
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
            // 用户仍然可以通过 Bundle.module 访问资源
        }
    }
    
    /// 获取ZUSDK.bundle
    /// SPM会将资源打包到模块的bundle中，通过此方法可以正确访问ZUSDK.bundle
    public static var bundle: Bundle {
        // 确保 bundle 已复制到主应用
        ensureInitialized()
        
        // 方式1: 从主bundle中查找（优先，因为用户代码使用 Bundle.main）
        if let bundlePath = Bundle.main.path(forResource: "ZUSDK", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        
        // 方式2: 从当前模块的Resources中查找（SPM标准方式）
        if let bundlePath = Bundle.module.path(forResource: "ZUSDK", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        
        // 方式3: 从框架bundle中查找
        if let frameworkBundle = Bundle(for: ZUSDKBasicWrapper.self),
           let bundlePath = frameworkBundle.path(forResource: "ZUSDK", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        
        // 回退到模块bundle（即使找不到ZUSDK.bundle，也返回模块bundle）
        return Bundle.module
    }
}

