//
//  AvatarView.swift
//  Accord
//
//  Created by evelyn on 2022-05-30.
//

import SwiftUI

struct AvatarView: View {
    var author: User
    var guildID: String
    var avatar: String?

    var animated: Bool {
        (avatar ?? author.avatar)?.prefix(2) == "a_"
    }

    var imageExtension: String {
        animated ? "gif" : "png"
    }

    @AppStorage("GifProfilePictures")
    var gifPfp: Bool = false

    var imageURL: String {
        if let avatar = avatar {
            return cdnURL + "/guilds/\(guildID)/users/\(author.id)/avatars/\(avatar).\(imageExtension)?size=64"
        } else if let avatar = author.avatar {
            return cdnURL + "/avatars/\(author.id)/\(avatar).\(imageExtension)?size=64"
        } else if let discriminator = Int(author.discriminator) {
            let id = String(discriminator % 5).prefix(1).stringLiteral
            return cdnURL + "/embed/avatars/\(id).png?size=48"
        }
        return cdnURL + "/embed/avatars/0.png?size=48"
    }

    @ViewBuilder
    var body: some View {
        if animated, gifPfp {
            GifView(imageURL).drawingGroup()
        } else {
            Attachment(imageURL).equatable()
        }
    }
}
