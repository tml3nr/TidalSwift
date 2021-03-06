//
//  AlbumGrid.swift
//  TidalSwift
//
//  Created by Melvin Gundlach on 19.08.19.
//  Copyright © 2019 Melvin Gundlach. All rights reserved.
//

import SwiftUI
import TidalSwiftLib
import ImageIOSwiftUI
import Grid

struct AlbumGrid: View {
	let albums: [Album]
	let showArtists: Bool
	let showReleaseDate: Bool
	let session: Session
	let player: Player
	
	var rowHeight: CGFloat = 190
	
	init(albums: [Album], showArtists: Bool, showReleaseDate: Bool = false, session: Session, player: Player) {
		self.albums = albums
		self.showArtists = showArtists
		self.showReleaseDate = showReleaseDate
		
		if showArtists {
			rowHeight += 18
		}
		if showReleaseDate {
			rowHeight += 18
		}
		
		self.session = session
		self.player = player
	}
	
	var body: some View {
		Grid(albums) { album in
			AlbumGridItem(album: album, showArtists: showArtists, showReleaseDate: showReleaseDate, session: session, player: player)
		}
		.gridStyle(
			ModularGridStyle(.vertical, columns: .min(170), rows: .fixed(rowHeight), spacing: 10)
		)
	}
}

struct AlbumGridItem: View {
	let album: Album
	let showArtists: Bool
	let showReleaseDate: Bool
	let session: Session
	let player: Player
	
	@EnvironmentObject var viewState: ViewState
	@EnvironmentObject var sc: SessionContainer
	
	init(album: Album, showArtists: Bool, showReleaseDate: Bool = false, session: Session, player: Player) {
		self.album = album
		self.showArtists = showArtists
		self.showReleaseDate = showReleaseDate
		self.session = session
		self.player = player
	}
	
	var body: some View {
		VStack {
			ZStack(alignment: .bottomTrailing) {
				if let albumUrl = album.getCoverUrl(session: session, resolution: 320) {
					URLImageSourceView(
						albumUrl,
						isAnimationEnabled: true,
						label: Text(album.title)
					)
						.aspectRatio(contentMode: .fill)
						.frame(width: 160, height: 160)
						.cornerRadius(CORNERRADIUS)
						.shadow(radius: SHADOWRADIUS, y: SHADOWY)
				} else {
					ZStack {
						Rectangle()
							.foregroundColor(.black)
							.frame(width: 160, height: 160)
							.cornerRadius(CORNERRADIUS)
							.shadow(radius: SHADOWRADIUS, y: SHADOWY)
						if album.streamReady ?? false {
							Text(album.title)
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
								.lineLimit(5)
								.frame(width: 160)
						} else {
							Text("Album not available")
								.foregroundColor(.white)
								.multilineTextAlignment(.center)
								.frame(width: 160)
						}
					}
				}
				if album.isOffline(session: sc.session) {
					Image("cloud.fill-big")
						.colorInvert()
						.shadow(radius: SHADOWRADIUS)
						.padding(5)
				}
			}
			HStack {
				Text(album.title)
					.lineLimit(1)
				album.attributeHStack
					.padding(.leading, -5)
					.layoutPriority(1)
			}
			.frame(width: 160)
			if showArtists {
				if let artists = album.artists { // Multiple Artists
					Text(artists.formArtistString())
						.fontWeight(.light)
						.foregroundColor(Color.secondary)
						.lineLimit(1)
						.frame(width: 160)
						.padding(.top, album.hasAttributes ? -6.5 : 0)
				} else if let artist = album.artist { // Single Artist
					Text(artist.name)
						.fontWeight(.light)
						.foregroundColor(Color.secondary)
						.lineLimit(1)
						.frame(width: 160)
				} else {
					Text("Unknown Artist")
						.fontWeight(.light)
						.foregroundColor(Color.secondary)
						.lineLimit(1)
						.frame(width: 160)
				}
			}
			if showReleaseDate, let releaseDate = album.releaseDate {
				Text(DateFormatter.dateOnly.string(from: releaseDate))
					.fontWeight(.light)
					.foregroundColor(Color.secondary)
					.lineLimit(1)
					.frame(width: 160)
			}
		}
		.padding(5)
		.toolTip(toolTipString)
		.onTapGesture(count: 2) {
			print("Second Click. \(album.title)")
			player.add(album: album, .now)
			player.play()
		}
		.onTapGesture(count: 1) {
			print("First Click. \(album.title)")
			if album.streamReady ?? false {
				viewState.push(album: album)
			}
		}
		.contextMenu {
			AlbumContextMenu(album: album, session: session, player: player)
		}
	}
	
	var toolTipString: String {
		var s = album.title
		if let artists = album.artists {
			s += " – \(artists.formArtistString())"
		}
		return s
	}
}

struct AlbumContextMenu: View {
	let album: Album
	let session: Session
	let player: Player
	
	@EnvironmentObject var viewState: ViewState
	@EnvironmentObject var playlistEditingValues: PlaylistEditingValues
	
	var body: some View {
		Group {
			Group {
				if album.streamReady ?? false {
					Button {
						player.add(album: album, .now)
					} label: {
						Text("Add Now")
					}
					Button {
						player.add(album: album, .next)
					} label: {
						Text("Add Next")
					}
					Button {
						player.add(album: album, .last)
					} label: {
						Text("Add Last")
					}
				} else {
					Text("Album not available")
						.italic()
				}
			}
			Divider()
			if let artists = album.artists, artists[0].name != "Various Artists" {
				Group {
					ForEach(album.artists!) { artist in
						Button {
							viewState.push(artist: artist)
						} label: {
							Text("Go to \(artist.name)")
						}
					}
				}
				Divider()
			}
			Group {
				if album.isInFavorites(session: session) ?? false {
					Button {
						print("Remove from Favorites")
						session.favorites?.removeAlbum(albumId: album.id)
						viewState.refreshCurrentView()
					} label: {
						Text("Remove from Favorites")
					}
				} else {
					Button {
						print("Add to Favorites")
						session.favorites?.addAlbum(albumId: album.id)
					} label: {
						Text("Add to Favorites")
					}
				}
				if album.streamReady ?? false {
					Button {
						print("Add \(album.title) to Playlist")
						if let tracks = session.getAlbumTracks(albumId: album.id) {
							playlistEditingValues.tracks = tracks
							playlistEditingValues.showAddTracksModal = true
						}
					} label: {
						Text("Add to Playlist …")
					}
					Divider()
					Group {
						if album.isOffline(session: session) {
							Button {
								print("Remove from Offline")
								album.removeOffline(session: session)
								viewState.refreshCurrentView()
							} label: {
								Text("Remove from Offline")
							}
						} else {
							Button {
								print("Add to Offline")
								album.addOffline(session: session)
							} label: {
								Text("Add to Offline")
							}
						}
						
						Button {
							print("Download")
							DispatchQueue.global(qos: .background).async {
								_ = session.helpers.download(album: album)
							}
						} label: {
							Text("Download")
						}
					}
					Divider()
					if let coverUrl = album.getCoverUrl(session: session, resolution: 1280) {
						Button {
							print("Cover")
							let controller = CoverWindowController(rootView:
								URLImageSourceView(
									coverUrl,
									isAnimationEnabled: true,
									label: Text(album.title)
								)
							)
							controller.window?.title = album.title
							controller.showWindow(nil)
						} label: {
							Text("Cover")
						}
					}
					Button {
						print("Credits")
						let controller = ResizableWindowController(rootView:
							CreditsView(session: session, album: album)
								.environmentObject(viewState)
						)
						controller.window?.title = "Credits – \(album.title)"
						controller.showWindow(nil)
					} label: {
						Text("Credits")
					}
					if let url = album.url {
						Button {
							print("Share")
							Pasteboard.copy(string: url.absoluteString)
						} label: {
							Text("Copy URL")
						}
					}
				}
			}
		}
	}
}

extension Album {
	var attributeHStack: some View {
		HStack {
			if explicit ?? false {
				Image("e.square")
			}
			if audioQuality == .master {
				Image("m.square.fill")
			} else if audioModes?.contains(.sony360RealityAudio) ?? false {
				Image("headphones")
			} else if audioModes?.contains(.dolbyAtmos) ?? false {
				Image("hifispeaker.fill")
			} else {
				Text("")
			}
		}
		.secondaryIconColor()
	}
	
	var hasAttributes: Bool {
		explicit ?? false ||
			audioQuality == .master ||
			audioModes?.contains(.sony360RealityAudio) ?? false ||
			audioModes?.contains(.dolbyAtmos) ?? false
	}
}
