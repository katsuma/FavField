import SwiftUI

struct ContentView: View {
    @State private var favoriteTeamAbbr = TeamPreferences.shared.favoriteTeamAbbr ?? ""

    var body: some View {
        NavigationStack {
            Group {
                if favoriteTeamAbbr.isEmpty {
                    TeamPickerView { abbr in
                        favoriteTeamAbbr = abbr
                    }
                } else {
                    ScoreView(teamAbbr: favoriteTeamAbbr) {
                        favoriteTeamAbbr = ""
                    }
                }
            }
            .navigationTitle("FavField")
        }
        .onAppear {
            favoriteTeamAbbr = TeamPreferences.shared.favoriteTeamAbbr ?? ""
        }
    }
}

#Preview {
    ContentView()
}
