//
//  VisitImpactView.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI
import FirebaseAuth

struct VisitImpactView: View {

    @StateObject private var adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()

    var currentUser = Auth.auth().currentUser
    @State var logsInteractionDev = [VisitLog]()
    @State private var didReceiveInteractionDev = false
    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0

    @State var showActionSheet = false
    @State var isLoading = false
    //@State private var navigateToAddNew = false
    @State var isNavigationActive = false
    @State var showLoginMessage = false
    @State var showAlert = false
    @State var user: User?
    @Binding var selection: Int
    @State private var showCustomAlert = false
    @State private var doNotShowAgain = false
    @State var logsOld = [VisitLog]()
    @State var logsNew = [VisitLog]()
    @State private var didReceiveOldLogs = false
    @State private var didReceiveNewLogs = false
   
    @AppStorage("hideProvidedHelpAlert") private var hideProvidedHelpAlert: Bool = false
    //Popup control state variable
    @State private var showWebRedirectPopup = false


    var body: some View {
        ZStack {
            NavigationStack {
                mainContent
            }

            if showCustomAlert {
                VisitImpactProvidedHelpAlert(
                    doNotShowAgain: $doNotShowAgain,
                    onConfirm: handleProvidedHelpAlertConfirmation
                )
            }
        }
    }

    private var mainContent: some View {
        VStack {
            VisitImpactHeaderSection(
                peopleHelped: peopleHelped,
                outreaches: outreaches,
                itemsDonated: itemsDonated
            )

            VisitImpactAddButton(action: handleAddNewTapped)

            Divider()
                .frame(maxWidth: UIScreen.main.bounds.width - 150, minHeight: 0.5)
                .background(Color.black)
                .padding(.top, 8)

            VisitImpactHistorySection(
                history: history,
                publishedLogIDs: adapter.publishedLogIDs,
                pendingLogIDs: adapter.pendingLogIDs,
                rejectedLogIDs: adapter.rejectedLogIDs
            )

            Spacer()
        }
        .alert(NSLocalizedString("loginRequiredTitle", comment: ""), isPresented: $showLoginMessage) {
            Button("OK", role: .cancel) {
                selection = 3
            }
            Button("Cancel", role: .destructive) { }
        } message: {
            Text(NSLocalizedString("loginRequiredMessage", comment: ""))
        }
        .navigationDestination(isPresented: $isNavigationActive) {
            VisitLogEntry()
                .onDisappear(perform: refreshLogs)
        }
        .loadingAnimation(isLoading: isLoading)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: configureView)
    }

    private func handleAddNewTapped() {
        if user != nil {
            if hideProvidedHelpAlert {
                isNavigationActive = true
            } else {
                showCustomAlert = true
            }
        } else {
            showLoginMessage = true
        }
    }

    private func handleProvidedHelpAlertConfirmation() {
        if doNotShowAgain {
            hideProvidedHelpAlert = true
        }
        showCustomAlert = false
        isNavigationActive = true
    }

    private func refreshLogs() {
        adapter.refresh()
        adapter.refresh_new()
        adapter.refreshInteractionLogDev()
    }

    private func configureView() {
        print("Impact view onAppear")
        adapter.delegate = self
        Auth.auth().addStateDidChangeListener { _, currentUser in
            self.user = currentUser
        }
        if Auth.auth().currentUser != nil {
            refreshLogs()
            self.isLoading = true
        } else {
            adapter.resetLogs()
            history = [VisitLog]()
            peopleHelped = 0
            outreaches = 0
            itemsDonated = 0
        }
    }
    
    private func mergeLogs() {
        self.history = (logsOld + logsNew)
            .sorted { $0.whenVisit > $1.whenVisit }  // Sort newest first
    }
    private func tryMergeAndUpdate() {
        guard didReceiveOldLogs && didReceiveNewLogs && didReceiveInteractionDev else { return }
        self.history = (logsOld + logsNew + logsInteractionDev)
            .sorted { $0.whenVisit > $1.whenVisit }
        self.updateCounts()
        self.isLoading = false
    }


    private func updateCounts() {
        
        self.outreaches = history.count
        
        self.peopleHelped = history.reduce(0) { total, log in
            if log.peopleHelped > 0 {
                return total + log.peopleHelped
            } else if log.numberOfHelpers > 0 {
                return total + log.numberOfHelpers
            } else {
                return total
            }
        }
        self.itemsDonated = history.reduce(0) { total, log in
            var count = 0
            count = log.listOfSupportsProvided.count
            // If nothing was found, check web-created logs
            if count == 0 {
                count += log.whatGiven.count
            }

            return total + count
        }
    }
    
} // end struct

extension VisitImpactView: VisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.logsOld = logs
        self.didReceiveOldLogs = true
        tryMergeAndUpdate()
    }

    func visitLogDataRefreshedNew(_ logs: [VisitLog]) {
        self.logsNew = logs
        self.didReceiveNewLogs = true
        tryMergeAndUpdate()
    }
    func visitLogDataRefreshedInteractionDev(_ logs: [VisitLog]) {
        self.logsInteractionDev = logs
        self.didReceiveInteractionDev = true
        tryMergeAndUpdate()
       // tryMergeAndUpdate()
       // tryMergeAndUpdate()
    }
}



struct VisitImpactView_Previews: PreviewProvider {
    static var previews: some View {
        VisitImpactView(selection: .constant(1))
    }
}
