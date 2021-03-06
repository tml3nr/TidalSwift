//
//  MyMixes.swift
//  TidalSwift
//
//  Created by Melvin Gundlach on 27.10.19.
//  Copyright © 2019 Melvin Gundlach. All rights reserved.
//

import SwiftUI
import TidalSwiftLib
import ImageIOSwiftUI
import Grid

struct MyMixes: View {
	let session: Session
	let player: Player
	
	@EnvironmentObject var viewState: ViewState
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				HStack {
					Text("My Mixes")
						.font(.largeTitle)
					Spacer()
					LoadingSpinner()
				}
				
				if let mixes = viewState.stack.last?.mixes {
					MixGrid(mixes: mixes, session: session, player: player)
				}
				Spacer(minLength: 0)
			}
			.padding(.horizontal)
		}
	}
}

struct MixGrid: View {
	let mixes: [MixesItem]
	let session: Session
	let player: Player
	
	var body: some View {
		Grid(mixes) { mix in
			MixGridItem(mix: mix, session: session, player: player)
		}
		.gridStyle(
			ModularGridStyle(.vertical, columns: .min(170), rows: .fixed(210), spacing: 10)
		)
	}
}

struct MixGridItem: View {
	let mix: MixesItem
	let session: Session
	let player: Player
	
	@EnvironmentObject var viewState: ViewState
	
	var body: some View {
		VStack {
			MixImage(mix: mix, session: session)
				.frame(width: 160, height: 160)
				.cornerRadius(CORNERRADIUS)
				.shadow(radius: SHADOWRADIUS, y: SHADOWY)
			
			Text(mix.title)
				.frame(width: 160)
			Text(mix.subTitle)
				.fontWeight(.light)
				.foregroundColor(Color.secondary)
				.lineLimit(1)
				.frame(width: 160)
		}
		.padding(5)
		.onTapGesture(count: 2) {
			print("Second Click. \(mix.title)")
			if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
				player.add(tracks: tracks, .now)
				player.play()
			}
		}
		.onTapGesture(count: 1) {
			print("First Click. \(mix.title)")
			viewState.push(mix: mix)
		}
		.contextMenu {
			MixContextMenu(mix: mix, session: session, player: player)
		}
	}
}

struct MixPlaylistView: View {
	let session: Session
	let player: Player
	
	@EnvironmentObject var viewState: ViewState
	
	var body: some View {
		ZStack {
			ScrollView {
				VStack(alignment: .leading) {
					if let mix = viewState.stack.last?.mix, let tracks = viewState.stack.last?.tracks {
						HStack {
							MixImage(mix: mix, session: session)
								.frame(width: 100, height: 100)
								.cornerRadius(CORNERRADIUS)
								.shadow(radius: SHADOWRADIUS, y: SHADOWY)
								.onTapGesture {
									if let imageUrl = mix.graphic.images[0].getImageUrl(session: session, resolution: 320) {
										let controller = CoverWindowController(rootView:
																				URLImageSourceView(
																					imageUrl,
																					isAnimationEnabled: true,
																					label: Text(mix.title)
																				)
										)
										controller.window?.title = mix.title
										controller.showWindow(nil)
									}
								}
							
							VStack(alignment: .leading) {
								Text(mix.title)
									.font(.title)
									.lineLimit(2)
								Text(mix.subTitle)
									.foregroundColor(.secondary)
							}
							Spacer(minLength: 0)
							LoadingSpinner()
						}
						.frame(height: 100)
						.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
						
						TrackList(wrappedTracks: tracks.wrapped(), showCover: true, showAlbumTrackNumber: false,
								  showArtist: true, showAlbum: true, playlist: nil,
								  session: session, player: player)
					}
					Spacer(minLength: 0)
				}
				.padding(.top, 40)
				
			}
			BackButton()
		}
	}
}

struct MixImage: View {
	let mix: MixesItem
	let session: Session
	
	@State var scrollImages = false
	
	var body: some View {
		GeometryReader { metrics in
			if mix.graphic.images.count >= 5 {
				ZStack {
					VStack {
						HStack {
							Text(mix.title)
								.font(.system(size: metrics.size.width * 0.1))
								.bold()
								.foregroundColor(Color(hex: mix.graphic.images[0].vibrantColor) ?? Color.gray)
								.padding(metrics.size.width * 0.1)
							Spacer()
						}
						Spacer()
					}
					
					// Animated Images
					VStack {
						HStack {
							// 4
							if let imageUrl = mix.graphic.images[4].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							// 0 1
							if let imageUrl = mix.graphic.images[0].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[1].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							// 2 3 4
							if let imageUrl = mix.graphic.images[2].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[3].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[4].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							// 0 1
							if let imageUrl = mix.graphic.images[0].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[1].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							Spacer()
								.frame(width: metrics.size.width * 0.2)
						}
						HStack {
							Spacer()
								.frame(width: metrics.size.width * 0.2)
							
							// 2 3 4
							if let imageUrl = mix.graphic.images[2].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(.trailing, metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[3].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[4].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							// 0 1
							if let imageUrl = mix.graphic.images[0].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[1].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							
							// 2 3 4
							if let imageUrl = mix.graphic.images[2].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[3].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
							if let imageUrl = mix.graphic.images[4].getImageUrl(session: session, resolution: 160) {
								URLImageSourceView(
									imageUrl,
									isAnimationEnabled: true,
									label: Text(mix.title)
								)
								.frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4)
								.padding(metrics.size.width * 0.01)
							}
						}
					}
					.padding(metrics.size.width * 0.06)
					.offset(x: scrollImages ? metrics.size.width * -2.7 : metrics.size.width * -0.35)
					.rotationEffect(Angle(degrees: -12))
					.position(CGPoint(x: metrics.size.width * 2, y: metrics.size.width * 0.4))
					.scaleEffect(1)
					.animation(Animation.linear(duration: 10).repeatForever(autoreverses: false))
					.onAppear {
						scrollImages.toggle()
					}
				}
				.contentShape(Rectangle())
				.clipped()
				.overlay(
					RoundedRectangle(cornerRadius: CORNERRADIUS)
						.stroke(Color(hex: mix.graphic.images[0].vibrantColor) ?? Color.gray, lineWidth: metrics.size.width * 0.1)
				)
				.background((Color(hex: mix.graphic.images[0].vibrantColor) ?? Color.gray).colorMultiply(Color.gray))
			} else {
				Rectangle()
					.foregroundColor(Color.black)
			}
		}
	}
}

struct MixContextMenu: View {
	let mix: MixesItem
	let session: Session
	let player: Player
	
	@EnvironmentObject var playlistEditingValues: PlaylistEditingValues
	
	var body: some View {
		Group {
			Button {
				if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
					player.add(tracks: tracks, .now)
				}
			} label: {
				Text("Add Now")
			}
			Button {
				if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
					player.add(tracks: tracks, .next)
				}
			} label: {
				Text("Add Next")
			}
			Button {
				if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
					player.add(tracks: tracks, .last)
				}
			} label: {
				Text("Add Last")
			}
			Divider()
			Button {
				print("Add \(mix.title) to Playlist")
				if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
					playlistEditingValues.tracks = tracks
					playlistEditingValues.showAddTracksModal = true
				}
			} label: {
				Text("Add to Playlist …")
			}
			Divider()
			Button {
				print("Download")
				DispatchQueue.global(qos: .background).async {
					if let tracks = session.getMixPlaylistTracks(mixId: mix.id) {
						_ = session.helpers.download(tracks: tracks, parentFolder: mix.title)
					}
				}
			} label: {
				Text("Download")
			}
		}
	}
}


// MARK: - Color Extension

extension Color {
	public init?(hex: String) {
		let r, g, b, a: Double
		
		if hex.hasPrefix("#") {
			let start = hex.index(hex.startIndex, offsetBy: 1)
			let hexColor = String(hex[start...])
			
			if hexColor.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = Double((hexNumber & 0xff000000) >> 24) / 255
					g = Double((hexNumber & 0x00ff0000) >> 16) / 255
					b = Double((hexNumber & 0x0000ff00) >> 8) / 255
					a = Double(hexNumber & 0x000000ff) / 255
					
					self.init(red: r, green: g, blue: b, opacity: a)
					return
				}
			} else if hexColor.count == 6 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = Double((hexNumber & 0xff0000) >> 16) / 255
					g = Double((hexNumber & 0x00ff00) >> 8) / 255
					b = Double(hexNumber & 0x0000ff) / 255
					
					self.init(red: r, green: g, blue: b)
					return
				}
			}
		}
		
		return nil
	}
}
