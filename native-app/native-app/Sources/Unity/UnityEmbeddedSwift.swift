//
//  UnityEmbeddedSwift.swift
//  native-app
//
//  Created by Michael Pavkovic on 6/5/20.
//  Copyright © 2020 Unity Technologies. All rights reserved.
//

import Foundation
import UnityFramework

protocol NativeCallsDelegate: AnyObject {
    
    func arFoundationDidReceiveCameraFrame(_ imageBytes: Data)
    
}

class UnityEmbeddedSwift: UIResponder {
    
    private var ufw : UnityFramework?
    
    private static var _instance: UnityEmbeddedSwift?
        
    ///
    /// Singleton instance of `UnityEmbeddedSwift`
    ///
    static var instance: UnityEmbeddedSwift? {
        if _instance == nil {
            _instance = UnityEmbeddedSwift()
        }
        return _instance
    }
    
    ///
    /// Launch Options for Unity application
    ///
    var launchOptions : [UIApplication.LaunchOptionsKey: Any]?
    
    ///
    /// Root view controller of Unity view
    ///
    var unityRootViewController: UIViewController? {
        get {
            return ufw?.appController()?.rootViewController
        }
    }
    
    ///
    /// Root view of Unity
    ///
    var unityRootView: UIView? {
        get {
            return ufw?.appController()?.rootView
        }
    }
    
    ///
    /// Delegate to notify a native call occured
    ///
    weak var delegate: NativeCallsDelegate?
    
    ///
    /// Connection to Unity is initialized when the `UnityFramework` instance is not `nil`, and it has an app controller
    ///
    var isInitialized: Bool {
        return ufw?.appController() != nil
    }
    
    func sendUnityMessageToGameObject(_ object: String, method: String, message: String) {
        guard isInitialized else {
            print("Cannot send message to game object before Unity is initialized")
            return
        }
        
        ufw?.sendMessageToGO(withName: object, functionName: method, message: message)
    }
    
    func load() {
        guard !isInitialized else { return }
        
        ufw = loadUnityFramework()
        ufw?.setDataBundleId("com.unity3d.framework")
        ufw?.register(self)
        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
        
        ufw?.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: launchOptions)
        
        ufw?.showUnityWindow()
    }
    
    func unload() {
        ufw?.unloadApplication()
    }
    
    private func loadUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        
        let bundle = Bundle(path: bundlePath)
        if bundle?.isLoaded == false {
            bundle?.load()
        }
        
        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {            
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
            
            ufw?.setExecuteHeader(machineHeader)
        }
        
        return ufw
    }
    
}

extension UnityEmbeddedSwift: UnityFrameworkListener {
    
    func unityDidUnload(_ notification: Notification!) {
        ufw?.unregisterFrameworkListener(self)
        ufw = nil
    }
    
}

extension UnityEmbeddedSwift: NativeCallsProtocol {
    
    func arFoundationDidReceiveCameraFrame(_ bytes: UnsafePointer<Int8>!, withCount count: Int32) {
        let data = Data(bytes: bytes, count: Int(count))
        delegate?.arFoundationDidReceiveCameraFrame(data)
    }
    
}
