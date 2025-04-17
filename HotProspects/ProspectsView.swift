//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Kamol Madaminov on 16/04/25.
//

import CodeScanner
import SwiftData
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @State private var isShowingScanner = false
    
    @State private var selectedProspects = Set<Prospect>()
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            "All prospects"
        case .contacted:
            "Contacted prospects"
        case .uncontacted:
            "Uncontacted prospects"
        }
    }
    
    var body: some View {
        NavigationStack{
            List(prospects, selection: $selectedProspects) { prospect in
                VStack(alignment: .leading){
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.email)
                        .foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive){
                        modelContext.delete(prospect)
                    }
                    
                    if prospect.isContacted{
                        Button("Mark uncontacted", systemImage: "person.crop.circle.badge.xcmark"){
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                    }
                }
                .tag(prospect)
            }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Scan", systemImage: "qrcode.viewfinder"){
                            isShowingScanner = true
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    
                    if selectedProspects.isEmpty == false {
                        ToolbarItem(placement: .bottomBar) {
                            Button("Delete selected", action: delete)
                        }
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Kamol Madaminov\nkamolmadaminov@gmail.com", completion: handleScan)
                }
        }
    }
    
    init(filter: FilterType){
        self.filter = filter
        
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate{
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        switch result{
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect(name: details[0], email: details[1], isContacted: false)
            modelContext.insert(person)
            
        case .failure(let error):
            print("Scanning error: \(error.localizedDescription)")
        }
    }
    
    func delete(){
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
