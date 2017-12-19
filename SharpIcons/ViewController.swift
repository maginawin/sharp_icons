//
//  ViewController.swift
//  SharpIcons
//
//  Created by 王文东 on 2017/12/16.
//  Copyright © 2017年 maginawin. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController, SettingsViewControllerProtocol  {
    
    let iOS_CheckBox_Key = "iOS_CheckBox_Key"
    let android_CheckBox_Key = "android_CheckBox_Key"
    let macOS_CheckBox_Key = "macOS_CheckBox_Key"
    
    @IBOutlet weak var iOSCheckBox: NSButton!
    @IBOutlet weak var androidCheckBox: NSButton!
    @IBOutlet weak var macOSCheckBox: NSButton!
    
    @IBOutlet weak var dirNameTextField: NSTextField!
    
    var dirName: String {
        return dirNameTextField.stringValue.isEmpty ? "Sharp Icons" : dirNameTextField.stringValue
    }
    
    var isSettingsLoaded: Bool = false
    
    var selectedImage: NSImage? = nil
    
    var panel: NSOpenPanel! = NSOpenPanel()

    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Sharp Icons"
        
        
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        
        panel.message = "Choose a PNG file..."
        panel.allowedFileTypes = ["png", "PNG"]
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.windowWillClose), name: NSWindow.willCloseNotification, object: nil)
        
        reloadCheckBoxes()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier?.rawValue.elementsEqual("showSettings")) == true {
            let settingsViewController = (segue.destinationController as! SettingsViewController)
            settingsViewController.delegate = self
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func choosePNGFileAction(_ sender: Any) {
        // IKPictureTaker.pictureTaker().begin(withDelegate: self, didEnd: #selector(ViewController.pictureTakerDidEnd(_:returnCode:contextInfo:)), contextInfo: nil)
        
        panel.beginSheetModal(for: self.view.window!) { [weak self] (resp: NSApplication.ModalResponse) in
            if NSApplication.ModalResponse.OK == resp {
                let path = self?.panel.urls.first?.path
                debugPrint("choose \(path ?? "none")")
                self?.selectedImage = NSImage(contentsOf: URL.init(fileURLWithPath: path!))
                self?.imageView.image = self?.selectedImage
            }
        }
    }
    
    @IBAction func listAction(_ sender: Any) {
        if isSettingsLoaded == true {
            return
        }
        
        NotificationCenter.default.removeObserver(self)
        
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("showSettings"), sender: nil)
    }
    
    @IBAction func generatePNGsActions(_ sender: Any) {
        guard let _ = selectedImage else {
            debugPrint("selectedImage is nil")
            return
        }
        
        let models: [ListModel] = ListObject.default.listModels()
        
        let deskURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.desktopDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        
        var dirURL = deskURL.appendingPathComponent(dirName)
        dirURL = checkURL(dirURL)
        
        var iOSURL = dirURL.appendingPathComponent("iOS_icons")
        if iOSCheckBox.state == .on {
            iOSURL = checkURL(iOSURL)
        }
        
        var androidURL = dirURL.appendingPathComponent("Android_icons")
        if androidCheckBox.state == .on {
            androidURL = checkURL(androidURL)
        }
        
        var macOSURL = dirURL.appendingPathComponent("macOS_icons")
        if macOSCheckBox.state == .on {
            macOSURL = checkURL(macOSURL)
        }
        
        for (_, value) in models.enumerated() {
            if value.type == ListModelType.iOS {
                
                if iOSCheckBox.state != .on {
                    continue
                }
                
                for index in 1...3 {
                    let curSize = value.size * CGFloat(index)
                    var name = ""
                    if Int(value.size * 10) % 10 > 0 {
                        name = "\(value.size)_\(value.size)@\(index)x.png"
                    } else {
                        name = "\(Int(value.size))_\(Int(value.size))@\(index)x.png"
                    }
                    saveImage(selectedImage, at: iOSURL, with: NSMakeSize(curSize, curSize), name: name)
                }
                
            } else if value.type == ListModelType.android {
                
                if androidCheckBox.state != .on {
                    continue
                }
                
                let curSize = CGFloat(value.size)
                var name = ""
                if Int(value.size * 10) % 10 > 0 {
                    name = "\(value.size)_\(value.size).png"
                } else {
                    name = "\(Int(value.size))_\(Int(value.size)).png"
                }
                saveImage(selectedImage, at: androidURL, with: NSMakeSize(curSize, curSize), name: name)
                
            } else if value.type == ListModelType.macOS {
                
                if macOSCheckBox.state != .on {
                    continue
                }
                
                for index in 1...2 {
                    let curSize = value.size * CGFloat(index)
                    var name = ""
                    if Int(value.size * 10) % 10 > 0 {
                        name = "\(value.size)_\(value.size)@\(index)x.png"
                    } else {
                        name = "\(Int(value.size))_\(Int(value.size))@\(index)x.png"
                    }
                    saveImage(selectedImage, at: macOSURL, with: NSMakeSize(curSize, curSize), name: name)
                }
                
            } else {
                continue
            }
        }
    }
    
    
    @IBAction func checkBoxesStateChangedAction(_ sender: Any) {
        saveCheckBoxes()
    }
    
    func reloadCheckBoxes() {
        if UserDefaults.standard.string(forKey: "first_launch") == nil {
            UserDefaults.standard.set("hello, world!", forKey: "first_launch")
            saveCheckBoxes()
            return
        }
        
        let iOSState = UserDefaults.standard.integer(forKey: iOS_CheckBox_Key)
        let androidState = UserDefaults.standard.integer(forKey: android_CheckBox_Key)
        let macOSState = UserDefaults.standard.integer(forKey: macOS_CheckBox_Key)
        
        iOSCheckBox.state = NSControl.StateValue.init(iOSState)
        androidCheckBox.state = NSControl.StateValue.init(androidState)
        macOSCheckBox.state = NSControl.StateValue.init(macOSState)
    }
    
    func saveCheckBoxes() {
        UserDefaults.standard.set(iOSCheckBox.state.rawValue, forKey: iOS_CheckBox_Key)
        UserDefaults.standard.set(androidCheckBox.state.rawValue, forKey: android_CheckBox_Key)
        UserDefaults.standard.set(macOSCheckBox.state.rawValue, forKey: macOS_CheckBox_Key)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - SettingsViewContrllerDelegate
    
    func settingsViewControllerDidAppear(_ viewController: SettingsViewController) {
        isSettingsLoaded = true
    }
    
    func settingsViewControllerDidDisappear(_ viewController: SettingsViewController) {
        isSettingsLoaded = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.windowWillClose), name: NSWindow.willCloseNotification, object: nil)
    }
    
    @objc private func pictureTakerDidEnd(_ sheet: IKPictureTaker, returnCode: NSInteger, contextInfo: UnsafeMutableRawPointer) {
        guard let image: NSImage = sheet.outputImage() else {
            return
        }
        
        if NSApplication.ModalResponse.OK.rawValue == returnCode {
            selectedImage = image
        }
    }
    
    private func resizeImage(_ sourceImage: NSImage, newSize: CGSize) -> Data? {
        let scale = NSScreen.main!.backingScaleFactor
        let image = NSImage.init(size: CGSize(width: newSize.width / scale, height: newSize.height / scale))
        
        image.lockFocus()
        
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = NSImageInterpolation.medium
        
        sourceImage.draw(in: NSMakeRect(0, 0, image.size.width, image.size.height), from: NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height), operation: NSCompositingOperation.copy, fraction: 1.0)
        
        image.unlockFocus()
        
        return image.tiffRepresentation
    }
    
    
    @objc private func windowWillClose() {
        NSApplication.shared.terminate(nil)
    }
    
    private func checkURL(_ url: URL) -> URL {
        var curURL: URL = url
        var index: Int = 1
        var isDir: ObjCBool = ObjCBool(false)
        while FileManager.default.fileExists(atPath: curURL.relativePath, isDirectory: &isDir) && isDir.boolValue {
            curURL = URL(fileURLWithPath: "\(url.relativePath) \(index)")
            index += 1
        }
        
        do {
            try FileManager.default.createDirectory(at: curURL, withIntermediateDirectories: false, attributes: [:])
        } catch {
            debugPrint(error)
        }
        
        return curURL
    }
    
    private func saveImage(_ image: NSImage?, at path: URL, with size: CGSize, name: String) {
        if image == nil { return; }
        guard let data = resizeImage(image!, newSize: size) else {
            return
        }
        do {
            try data.write(to: path.appendingPathComponent(name))
        } catch {
            debugPrint(error)
        }
    }
}

