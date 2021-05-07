//
//  ConsoleViewController.swift
//  SimpleVM
//
//  Created by Khaos Tian on 7/26/20.
//

import Cocoa
import SwiftTerm

class ConsoleViewController: NSViewController, TerminalViewDelegate {
    
    private lazy var terminalView: TerminalView = {
        let terminalView = TerminalView()
        terminalView.translatesAutoresizingMaskIntoConstraints = false
        terminalView.terminalDelegate = self
        return terminalView
    }()
    
    private var readPipe: Pipe?
    private var writePipe: Pipe?
    
    private var chaningSize = false
        
    override func loadView() {
        view = NSView()
    }
    
    deinit {
        readPipe?.fileHandleForReading.readabilityHandler = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(terminalView)
        chaningSize = true
        terminalView.frame = view.frame
        chaningSize = false
        terminalView.needsLayout = true
        NSLayoutConstraint.activate([
            terminalView.topAnchor.constraint(equalTo: view.topAnchor),
            terminalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            terminalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            terminalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configure(with readPipe: Pipe, writePipe: Pipe) {
        self.readPipe = readPipe
        self.writePipe = writePipe
        
        readPipe.fileHandleForReading.readabilityHandler = { [weak self] pipe in
            let data = pipe.availableData
            if let strongSelf = self {
                DispatchQueue.main.sync {
                    strongSelf.terminalView.feed(byteArray: [UInt8](data)[...])
                }
            }
        }
    }
    
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        if chaningSize {
            return
        }
        
        chaningSize = true
        
        var newFrame = terminalView.getOptimalFrameSize()
        let windowFrame = view.window!.frame
        
        newFrame = CGRect(x: windowFrame.minX, y: windowFrame.minY, width: newFrame.width, height: windowFrame.height - view.frame.height + newFrame.height)
        view.window?.setFrame(newFrame, display: true, animate: false)
        chaningSize = false
    }
    
    func setTerminalTitle(source: TerminalView, title: String) {
        
    }
    
    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        writePipe?.fileHandleForWriting.write(Data(data))
    }
    
    func scrolled(source: TerminalView, position: Double) {
        
    }
}
