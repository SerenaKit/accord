//
//  SettingsViewRedesign.swift
//  Accord
//
//  Created by evewyn on 2021-07-14.
//

import Foundation
import SwiftUI

@available(macOS 11.0, *)
struct SettingsViewRedesign: View {

    @AppStorage("pfpShown") var profilePictures: Bool = pfpShown
    @AppStorage("sortByMostRecent") var recent: Bool = sortByMostRecent
    @AppStorage("darkMode") var dark: Bool = darkMode
    @AppStorage("proxyIP") var proxyIP: String = ""
    @AppStorage("proxyPort") var proxyPort: String = ""
    @AppStorage("proxyEnabled") var proxyEnable: Bool = proxyEnabled
    @AppStorage("pastelColors") var pastel: Bool = pastelColors
    @AppStorage("discordStockSettings") var discordSettings: Bool = pastelColors
    @AppStorage("enableSuffixRemover") var suffixes: Bool = false
    @AppStorage("pronounDB") var pronounDB: Bool = false

    @State var user: User? = AccordCoreVars.user
    @State var selectedPlatform: Platforms = musicPlatform ?? Platforms.appleMusic
    @State var loading: Bool = false
    @State var bioText: String = " "
    @State var username: String = AccordCoreVars.user?.username ?? "Unknown User"

    var body: some View {
        List {
            LazyVStack(alignment: .leading) {
                Text("Accord Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Email")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(user?.email ?? "No email found")
                        }
                        .padding(.bottom, 10)
                        VStack(alignment: .leading) {
                            Text("Phone number")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("not done yet, placeholder")
                        }
                        .padding(.bottom, 10)
                        Spacer()
                    }
                    .padding()
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Bio")
                            .font(.title3)
                            .fontWeight(.bold)
                        TextEditor(text: $bioText)
                            .frame(height: 75)
                        Text("Username")
                            .font(.title3)
                            .fontWeight(.bold)
                        TextField("username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
                    }
                    .frame(idealWidth: 250, idealHeight: 200)
                    .padding()
                    Divider()
                    VStack(alignment: .leading) {
                        GifView(url: "https://cdn.discordapp.com/avatars/\(user?.id ?? "")/\(user?.avatar ?? "").gif")
                            .clipShape(Circle())
                            .frame(width: 45, height: 45)
                            .shadow(radius: 5)
                        Text(user?.username ?? "Unknown User")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(user?.username ?? "Unknown User")#\(user?.discriminator ?? "0000")")
                            .font(.subheadline)
                            .foregroundColor(Color.secondary)
                        Divider()
                        Text(bioText)
                        Spacer()
                    }
                    .frame(idealWidth: 200, idealHeight: 200)
                    .padding()
                    Spacer()
                }
                .padding(5)
                .background(Color.black.opacity(0.25))
                .cornerRadius(15)
                .padding()
                VSplitView {
                    SettingsToggleView(toggled: $profilePictures, title: "Show profile pictures")
                    SettingsToggleView(toggled: $discordSettings, title: "Use stock discord settings")
                    SettingsToggleView(toggled: $recent, title: "Sort servers by recent messages")
                    SettingsToggleView(toggled: $proxyEnable, title: "Enable Proxy")
                    SettingsToggleView(toggled: $suffixes, title: "Enable useless suffix remover")
                    SettingsToggleView(toggled: $pronounDB, title: "Enable PronounDB integration")
                    SettingsToggleView(toggled: $dark, title: "Always dark mode")
                    HStack(alignment: .top) {
                        Text("Music platform")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding()
                        Spacer()
                        Picker(selection: $selectedPlatform, content: {
                            Text("Amazon Music").tag(Platforms.amazonMusic)
                            Text("Apple Music").tag(Platforms.appleMusic)
                            Text("Deezer").tag(Platforms.deezer)
                            Text("iTunes").tag(Platforms.itunes)
                            Text("Napster").tag(Platforms.napster)
                            Text("Pandora").tag(Platforms.pandora)
                            Text("Soundcloud").tag(Platforms.soundcloud)
                            Text("Spotify").tag(Platforms.spotify)
                            Text("Tidal").tag(Platforms.tidal)
                            Text("Youtube Music").tag(Platforms.youtubeMusic)
                        }, label: {
                        })
                        .padding()
                    }
                }
                .toggleStyle(SwitchToggleStyle())
                .pickerStyle(MenuPickerStyle())
                .padding(5)
                .background(Color.black.opacity(0.25))
                .cornerRadius(15)
                .padding()
                Text("Proxy Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                VStack {
                    SettingsToggleView(toggled: $proxyEnable, title: "Enable Proxy")
                    HStack(alignment: .top) {
                        Text("Proxy IP")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding()
                        Spacer()
                        TextField("IP", text: $proxyIP)
                            .padding()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 250)
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("Proxy Port")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding()
                        Spacer()
                        TextField("Port", text: $proxyPort)
                            .padding()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 250)
                    }
                    HStack {
                        Text("Load plugin")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding()
                        Spacer()
                        Button("Load") {
                            self.loading.toggle()
                        }
                    }
                    .fileImporter(isPresented: $loading, allowedContentTypes: [.data], onCompletion: { result in
                        do {
                            let url = try result.get()
                            let path = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask)[0].appendingPathComponent(UUID().uuidString)
                            if FileManager.default.secureCopyItem(at: url, to: path) {
                                print("Plugin successfully copied")
                            }
                        } catch {

                        }
                    })
                }
                .padding(5)
                .background(Color.black.opacity(0.25))
                .cornerRadius(15)
                .padding()
                Text("Accord (red.evelyn.accord) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                    .padding(.leading, 20)
                    .foregroundColor(.secondary)
                Text("OS: macOS \(String(describing: ProcessInfo.processInfo.operatingSystemVersionString))")
                    .padding(.leading, 20)
                    .foregroundColor(.secondary)
            }
            .onDisappear {
                darkMode = dark
                sortByMostRecent = recent
                pfpShown = profilePictures
                pastelColors = pastel
                discordStockSettings = discordSettings
            }
        }
    }
}

extension FileManager {

    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch let error {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

}

struct SettingsToggleView: View {
    @Binding var toggled: Bool
    var title: String
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .padding()
            Spacer()
            Toggle(isOn: $toggled) {
            }
            .padding()
        }
    }
}
