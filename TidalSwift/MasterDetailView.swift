//
//  MasterDetailView.swift
//  TidalSwift
//
//  Created by Melvin Gundlach on 20.08.19.
//  Copyright © 2019 Melvin Gundlach. All rights reserved.
//

import SwiftUI
import TidalSwiftLib

struct MasterDetailView: View {
    let session: Session
	let player: Player
	
	@State var selection: String? = nil
	@State var searchText: String = ""
	@State var fixedSearchText: String = ""
	
	var body: some View {
		NavigationView {
			MasterView(session: session, selection: $selection, searchText: $searchText, fixedSearchText: $fixedSearchText)
			DetailView(viewType: selection ?? "", session: session, player: player, fixedSearchText: $fixedSearchText)
		}
//		.frame(width: 1100, height: 700)
	}
}

struct MasterView: View {
	let session: Session
	
	@Binding var selection: String?
	@Binding var searchText: String
	@Binding var fixedSearchText: String
	
	private let favorites = ["Playlists", "Albums", "Tracks", "Videos", "Artists"]
	
	var body: some View {
		VStack {
			TextField("Search", text: $searchText, onCommit: {
				print(self.searchText)
				self.fixedSearchText = self.searchText
				self.selection = "Search"
			})
//			TextField("Search", text: $searchText)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.top, 10)
				.padding([.leading, .trailing], 5)
			List(selection: $selection) {
				Section(header: Text("Favorites")) {
					ForEach(favorites, id: \.self) { viewType in
						Text(viewType)
					}
				}
			}.listStyle(SidebarListStyle())
		}
	}
}

struct DetailView: View {
	var viewType: String
	let session: Session
	let player: Player
	
	@Binding var fixedSearchText: String
	
	var body: some View {
		VStack {
			PlayerInfoView(session: session, player: player)
//			PlayerView()
			HStack {
				if viewType == "Playlists" {
					FavoritePlaylists(session: session, player: player)
				} else if viewType == "Albums" {
					FavoriteAlbums(session: session, player: player)
				} else if viewType == "Tracks" {
					FavoriteTracks(session: session, player: player)
				} else if viewType == "Videos" {
					FavoriteVideos(session: session, player: player)
				} else if viewType == "Artists" {
					FavoriteArtists(session: session, player: player)
				} else if viewType == "Search" {
					// TODO: Keep SearchView from redrawing with every change of searchText
					SearchView(searchText: fixedSearchText, session: session, player: player)
				}
			}
			if viewType == "" {
				Spacer()
			}
		}
//		.frame(width: 800, height: 700)
	}
}


//struct MasterDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MasterDetailView()
//    }
//}
