//
//  ChatControlsView.swift
//  ChatControlsView
//
//  Created by evelyn on 2021-08-23.
//

import Foundation
import SwiftUI

struct ChatControls: View {
//    enum FocusedElements: Hashable {
//        case mainTextField
//        case none
//    }
//
//    @FocusState private var focusedField: FocusedElements?

    @State var chatTextFieldContents: String = ""
    @State var pfps: [String: NSImage] = [:]
    var guildID: String
    var channelID: String
    var chatText: String
    @Binding var replyingTo: Message?
    @Binding var mentionUser: Bool
    var permissions: Permissions
    @State var nitroless = false
    @State var emotes = false
    @State var fileImport: Bool = false
    @Binding var fileUpload: Data?
    @Binding var fileUploadURL: URL?
    @State var dragOver: Bool = false
    @State var pluginPoppedUp: [Bool] = Array(repeating: false, count: AccordCoreVars.plugins.count)
    @StateObject var viewModel = ChatControlsViewModel()
    @State var typing: Bool = false
    weak var textField: NSTextField?
    @AppStorage("Nitroless") var nitrolessEnabled: Bool = false

    var textFieldText: String {
        permissions.contains(.sendMessages) ?
            viewModel.percent ?? chatText :
            "You do not have permission to speak in this channel."
    }

    private func send() {
        messageSendQueue.async { [weak viewModel] in
            guard (viewModel?.textFieldContents != "" || fileUploadURL != nil), let contents = viewModel?.textFieldContents else { return }
            if contents.prefix(1) != "/" {
                viewModel?.emptyTextField()
            }
            if let fileUpload = fileUpload, let fileUploadURL = fileUploadURL {
                viewModel?.send(text: contents, file: [fileUploadURL], data: [fileUpload], channelID: self.channelID)
                DispatchQueue.main.async {
                    self.fileUpload = nil
                    self.fileUploadURL = nil
                }
            } else if let replyingTo = replyingTo {
                viewModel?.send(text: contents, replyingTo: replyingTo, mention: self.mentionUser, guildID: guildID)
                DispatchQueue.main.async {
                    self.replyingTo = nil
                    self.mentionUser = true
                }
            } else if viewModel?.textFieldContents.prefix(1) == "/" {
                try? viewModel?.executeCommand(guildID: guildID, channelID: channelID)
            } else {
                viewModel?.send(text: contents, guildID: guildID, channelID: channelID)
            }
            // self.focusIfUnfocused()
        }
    }

//    func focusIfUnfocused() {
//        DispatchQueue.main.async {
//            print(self.focusedField)
//            if self.focusedField != .mainTextField {
//                self.focusedField = .mainTextField
//            }
//        }
//    }

    var matchedUsersView: some View {
        MatchesView(
            elements: viewModel.matchedUsers.sorted(by: >).prefix(10),
            id: \.key,
            action: { [weak viewModel] key, _ in
                if let range = viewModel?.textFieldContents.ranges(of: "@").last {
                    viewModel?.textFieldContents.removeSubrange(range.lowerBound ..< viewModel!.textFieldContents.endIndex)
                }
                viewModel?.textFieldContents.append("<@!\(key)> ")
            },
            label: { _, username in
                HStack {
                    Text(username)
                    Spacer()
                }
            }
        )
    }

    var matchedCommandsView: some View {
        MatchesView(
            elements: viewModel.matchedCommands.prefix(10),
            id: \.id,
            action: { [weak viewModel] command in
                var contents = "/\(command.name)"
                command.options?.forEach { arg in
                    contents.append(" \(arg.name)\(arg.type == 1 ? "" : ":")")
                }
                viewModel?.command = command
                viewModel?.textFieldContents = contents
                viewModel?.matchedCommands.removeAll()
            },
            label: { command in
                HStack {
                    if let command = command, let avatar = command.avatar {
                        Attachment(cdnURL + "/avatars/\(command.application_id)/\(avatar).png?size=48")
                            .equatable()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text(command.name)
                            .fontWeight(.semibold)
                        Text(command.description)
                    }
                    Spacer()
                }
            }
        )
    }

    var matchedEmojiView: some View {
        MatchesView(
            elements: viewModel.matchedEmoji.prefix(10),
            id: \.id,
            action: { [weak viewModel] emoji in
                if let range = viewModel?.textFieldContents.ranges(of: ":").last {
                    viewModel?.textFieldContents.removeSubrange(range.lowerBound ..< viewModel!.textFieldContents.endIndex)
                }
                viewModel?.textFieldContents.append("<\((emoji.animated ?? false) ? "a" : ""):\(emoji.name):\(emoji.id)> ")
                viewModel?.matchedEmoji.removeAll()
            },
            label: { emoji in
                HStack {
                    Attachment(cdnURL + "/emojis/\(emoji.id).png?size=80", size: CGSize(width: 48, height: 48))
                        .equatable()
                        .frame(width: 20, height: 20)
                    Text(emoji.name)
                    Spacer()
                }
            }
        )
    }

    var matchedChannelsView: some View {
        MatchesView(
            elements: viewModel.matchedChannels.prefix(10),
            id: \.id,
            action: { [weak viewModel] channel in
                if let range = viewModel?.textFieldContents.ranges(of: "#").last {
                    viewModel?.textFieldContents.removeSubrange(range.lowerBound ..< viewModel!.textFieldContents.endIndex)
                }
                viewModel?.textFieldContents.append("<#\(channel.id)> ")
            },
            label: { channel in
                HStack {
                    Text(channel.name ?? "Unknown Channel")
                    Spacer()
                }
            }
        )
    }

    var mainTextField: some View {
        TextField(textFieldText, text: $viewModel.textFieldContents)
            // .focused($focusedField, equals: .mainTextField)
            .onSubmit {
                typing = false
                send()
            }
            .layoutPriority(1)
            .animation(nil, value: UUID())
            .fixedSize(horizontal: false, vertical: true)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("red.evelyn.accord.PasteEvent"))) { [weak viewModel] _ in
                let data = NSPasteboard.general.pasteboardItems?.first?.data(forType: .fileURL)
                if let rawData = data,
                   let string = String(data: rawData, encoding: .utf8),
                   let url = URL(string: string),
                   let data = try? Data(contentsOf: url)
                {
                    self.fileUpload = data
                    self.fileUploadURL = url
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let textCount = viewModel?.textFieldContents.count,
                           let pathComponentsCount = url.pathComponents.last?.count
                        {
                            if textCount >= pathComponentsCount {
                                viewModel?.textFieldContents.removeLast(pathComponentsCount)
                            }
                        }
                    }
                } else if let image = NSImage(pasteboard: NSPasteboard.general) {
                    self.fileUpload = image.png
                    self.fileUploadURL = URL(string: "file:///image0.png")!
                }
            }
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                    self.focusIfUnfocused()
//                })
//            }
    }

    var fileImportButton: some View {
        Button(action: {
            fileImport.toggle()
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 17.5, height: 17.5)
    }

    var nitrolessButton: some View {
        Button(action: {
            nitroless.toggle()
        }) {
            Image(systemName: "rectangle.grid.3x2.fill")
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 17.5, height: 17.5)
        .popover(isPresented: $nitroless, content: {
            NitrolessView(chatText: $viewModel.textFieldContents).equatable()
                .frame(width: 300, height: 400)
        })
    }

    var emotesButton: some View {
        Button(action: {
            emotes.toggle()
        }) {
            Image(systemName: "face.smiling.fill")
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 17.5, height: 17.5)
        .keyboardShortcut("e", modifiers: [.command])
        .popover(isPresented: $emotes, content: {
            NavigationLazyView(EmotesView(chatText: $viewModel.textFieldContents).equatable())
                .frame(width: 300, height: 400)
        })
    }

    var body: some View {
        HStack { [unowned viewModel] in
            ZStack(alignment: .trailing) {
                VStack {
                    if !(viewModel.matchedUsers.isEmpty) ||
                        !(viewModel.matchedEmoji.isEmpty) ||
                        !(viewModel.matchedChannels.isEmpty) ||
                        !(viewModel.matchedCommands.isEmpty) &&
                        !viewModel.textFieldContents.isEmpty
                    {
                        VStack {
                            matchedUsersView
                            matchedCommandsView
                            matchedEmojiView
                            matchedChannelsView
                            Divider()
                        }
                        .padding(.bottom, 7)
                    }
                    HStack {
                        fileImportButton
                        Divider().frame(height: 20)
                        mainTextField
                        if nitrolessEnabled {
                            nitrolessButton
                        }
                        emotesButton
                        HStack {
                            if fileUpload != nil {
                                Image(systemName: "doc.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17.5, height: 17.5)
                                    .foregroundColor(Color.secondary)
                            }
                        }
                    }
                    .disabled(!self.permissions.contains(.sendMessages))
                    .onReceive(viewModel.$textFieldContents) { [weak viewModel] _ in
                        if !typing, viewModel?.textFieldContents != "" {
                            messageSendQueue.async {
                                viewModel?.type(channelID: self.channelID, guildID: self.guildID)
                            }
                            typing = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                typing = false
                            }
                        }
                        // viewModel?.markdown()
                        textQueue.async {
                            viewModel?.checkText(guildID: guildID, channelID: channelID)
                        }
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .fileImporter(isPresented: $fileImport, allowedContentTypes: [.data]) { result in
                    fileUpload = try! Data(contentsOf: try! result.get())
                    fileUploadURL = try! result.get()
                }
                .onExitCommand { self.replyingTo = nil }
            }
        }
    }
}

extension Data {
    mutating func append(string: String, encoding: String.Encoding) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict: [Element: Bool] = .init()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = removingDuplicates()
    }
}

/*
 if AccordCoreVars.plugins != [] {
     ForEach(AccordCoreVars.plugins.enumerated().reversed().reversed(), id: \.offset) { offset, plugin in
         if pluginPoppedUp.indices.contains(offset) {
             Button(action: {
                 pluginPoppedUp[offset].toggle()
             }) {
                 Image(systemName: plugin.symbol)
             }
             .buttonStyle(BorderlessButtonStyle())
             .popover(isPresented: $pluginPoppedUp[offset], content: {
                 NSViewWrapper(plugin.body ?? NSView())
                     .frame(width: 200, height: 200)
             })
         }
     }
 }
 */
