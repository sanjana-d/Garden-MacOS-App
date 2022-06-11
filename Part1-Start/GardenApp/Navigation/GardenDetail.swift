/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The detail view for each garden.
*/

import SwiftUI

struct GardenDetail: View {

    enum ViewMode: String, CaseIterable, Identifiable {
        // want to see a table or picture view? pass these as bindings into the bosy view
        var id: Self { self }
        case table
        case gallery
    }

    @EnvironmentObject var store: Store
    @Binding var gardenId: Garden.ID?
    @State var searchText: String = ""
    @SceneStorage("viewMode") private var mode: ViewMode = .table
    @State private var selection = Set<Plant.ID>()

    @State var sortOrder: [KeyPathComparator<Plant>] = [
        .init(\.variety, order: SortOrder.forward)
    ]
    
    var table: some View {
        Table (plants, selection: $selection, sortOrder: $sortOrder) {
            // created a table with a single column
            TableColumn("Variety", value: \.variety)
            TableColumn("Days to Maturity", value: \.daysToMaturity) { plant
                in
                Text(plant.daysToMaturity.formatted())
            }
            TableColumn("Date Planted", value: \.datePlanted) { plant in
                Text(plant.datePlanted.formatted(date: .abbreviated, time: .omitted))
            }

            TableColumn("Harvest Date", value: \.harvestDate) { plant in
                Text(plant.harvestDate.formatted(date: .abbreviated, time: .omitted))
            }

            TableColumn("Last Watered", value: \.lastWateredOn) { plant in
                Text(plant.lastWateredOn.formatted(date: .abbreviated, time: .omitted))
            }

            TableColumn("Favorite", value: \.favorite, comparator: BoolComparator()) { plant in
                Toggle("Favorite", isOn: gardenBinding[plant.id].favorite)
                    .labelsHidden()
            }
            .width(50)
        }
    }
    
    var body: some View {
        table
        // tells the system to expose these values and keypath when the entire scence is in focus
            .focusedSceneValue(\.garden, gardenBinding)
            .focusedSceneValue(\.selection , $selection)
        // can search for plants
            .searchable(text: $searchText)
            .toolbar{
                // list or other type of view
                DisplayModePicker(mode: $mode)
                Button(action: addPlant){
                    Label("Add Plant", systemImage: "plus")
                }
            }
            .navigationTitle(garden.name)
            .navigationSubtitle("\(garden.displayYear)")
    }
}

struct GardenDetailPreviews: PreviewProvider {
    static var store = Store()
    static var previews: some View {
        GardenDetail(gardenId: .constant(store.gardens(in: 2021).first!.id))
            .environmentObject(store)
            .frame(width: 450)
    }
}

extension GardenDetail {

    var garden: Garden {
        store[gardenId]
    }

    var gardenBinding: Binding<Garden> {
        $store[gardenId]
    }

    func addPlant() {
        let plant = Plant()
        gardenBinding.wrappedValue.plants.append(plant)
        selection = Set([plant.id])
    }

    var plants: [Plant] {
        return garden.plants
            .filter {
                searchText.isEmpty ? true : $0.variety.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOrder)
    }

}

private struct BoolComparator: SortComparator {
    typealias Compared = Bool

    func compare(_ lhs: Bool, _ rhs: Bool) -> ComparisonResult {
        switch (lhs, rhs) {
        case (true, false):
            return order == .forward ? .orderedDescending : .orderedAscending
        case (false, true):
            return order == .forward ? .orderedAscending : .orderedDescending
        default: return .orderedSame
        }
    }

    var order: SortOrder = .forward
}
