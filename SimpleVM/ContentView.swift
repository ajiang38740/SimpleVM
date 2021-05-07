//
//  ContentView.swift
//  SimpleVM
//
//  Created by Khaos Tian on 7/26/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @ObservedObject var viewModel = VirtualMachineViewModel()

    var body: some View {
        VStack(alignment: .leading) {
    
            VStack(alignment: .leading, spacing: 1.0) {
                Text("CPU Count: ")
                    .font(.title3)
                    .foregroundColor(Color.green)
                TextField("", text: Binding($viewModel.cpuCount)!).disableAutocorrection(true)
            }
            
            VStack(alignment: .leading, spacing: 1.0) {
                Text("Memory (MB): ")
                    .font(.title3)
                    .foregroundColor(Color.green)
                TextField("", text: Binding($viewModel.memMB)!).disableAutocorrection(true)
            }
            
            VStack(alignment: .leading, spacing: 1.0) {
                Text("Boot Parameter: ")
                    .font(.title3)
                    .foregroundColor(Color.green)
                TextField("", text: Binding($viewModel.kernelParameter)!).disableAutocorrection(true)
                
            }

            VStack(alignment: .leading, spacing: 1.0) {
                Text("Mac Address: ")
                    .font(.title3)
                    .foregroundColor(Color.green)
                TextField("", text: Binding($viewModel.macAddress)!).disableAutocorrection(true)
            }
            
            Spacer()
                .padding(.vertical, 2.0)
            
            VStack(alignment: .leading, spacing: -14.0) {
                Text("vmlinux: \(viewModel.kernelURL?.lastPathComponent ?? "(Drag to here)")")
                    .font(.body)
                    .foregroundColor(Color.orange)
                    .padding([.top, .bottom])
                    .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                    processDropItem(of: .kernel, items: itemProviders)
                    return true
                }
            
                Text("initrd: \(viewModel.initialRamdiskURL?.lastPathComponent ?? "(Drag to here)")")
                    .font(.body)
                    .foregroundColor(Color.orange)
                    .padding([.top, .bottom])
                    .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                    processDropItem(of: .ramdisk, items: itemProviders)
                    return true
                }
            
                Text("image: \(viewModel.bootableImageURL?.lastPathComponent ?? "(Drag to here)")")
                    .font(.body)
                    .foregroundColor(Color.orange)
                    .padding([.top, .bottom])
                    .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                    processDropItem(of: .image, items: itemProviders)
                    return true
                }
            }
            Spacer()
            
            HStack {
                if viewModel.state == nil {
                    Button("Start") {
                        viewModel.start()
                        showConsole()
                    }
                    .disabled(!viewModel.isReady)
                } else {
                    Button("Stop") {
                        viewModel.stop()
                    }
                }
                
                Spacer()
                if let stateDescription = viewModel.stateDescription {
                    Button("Console") {
                        showConsole()
                    }
                    Spacer()
                    Text("State: \(stateDescription)")
                }
            }
            
        }
        .padding()
        .frame(width: 400)
    }
    
    private func showConsole() {
        viewModel.showConsole()
    }
    
    enum DropItemType {
        case kernel
        case ramdisk
        case image
    }
    
    private func processDropItem(of type: DropItemType,
                                 items: [NSItemProvider]) {
        guard let item = items.first else {
            return
        }
        
        item.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
            guard let data = data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            DispatchQueue.main.async {
                switch type {
                case .kernel:
                    viewModel.kernelURL = url
                case .ramdisk:
                    viewModel.initialRamdiskURL = url
                case .image:
                    viewModel.bootableImageURL = url
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
