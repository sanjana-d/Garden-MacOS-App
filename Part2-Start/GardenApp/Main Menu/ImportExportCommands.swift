/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The import and export command support.
*/

import SwiftUI

struct ImportExportCommands: Commands {
    var store: Store
    @State private var isShowingExport = false
    
    var body: some Commands {
        // add menu item in expected place of file menu
        CommandGroup(replacing: .importExport) {
            Section {
                // to transfer items between apps
                Button("Export...") {
                    isShowingExport = true
                }
            }
            .fileExporter(isPresented: $isShowingExport, document: store, contentType: Store.readableContentTypes.first!) {result in}// type is csv
        }
    }
}
