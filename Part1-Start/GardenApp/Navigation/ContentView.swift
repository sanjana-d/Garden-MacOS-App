/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main content view for this sample.
*/

import SwiftUI
// well have a 2 col layout
struct ContentView: View {
    @SceneStorage("selection") var selection: Garden.ID? // to see on right
    var body: some View {
        NavigationView {
            SideBar(selection: $selection)
            GardenDetail(gardenId: $selection)
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Store())
    }
}

// extracted view
struct SideBar: View {
    @EnvironmentObject var store: Store
    // adding this so that everytime we open the app, the tabs expanded remain the same
    // scene storage wrapper - reload state when window is restored
    @SceneStorage("expansionState") var expansionState = ExpansionState()
    @Binding var selection: Garden.ID? // to see on right
    
    var body: some View {
        // show list of gardens in current year
        List (selection: $selection){
            DisclosureGroup (isExpanded: $expansionState[store.currentYear]){
                ForEach(store.gardens(in: store.currentYear))
                {   garden in
                    Label(garden.name, systemImage: "leaf")
                        .badge(garden
                            .numberOfPlantsNeedingWater)
                }
            } label: {
                Label("Current", systemImage: "chart.bar.doc.horizontal")
            }
            
            Section("History") {
                GardenHistoryOutline(range: store.previousYears, expansionState: $expansionState)
            }
        }
        .frame(minWidth: 250)
    }
}
