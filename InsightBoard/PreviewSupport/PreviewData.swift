//
//  PreviewData.swift
//  InsightBoard
//

#if DEBUG
import Foundation
import SwiftUI

enum PreviewData {
    static let leanne = User(
        id: 1,
        name: "Leanne Graham",
        username: "Bret",
        email: "Sincere@april.biz",
        address: .init(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998-3874", geo: .init(lat: "-37.3159", lng: "81.1496")),
        phone: "1-770-736-8031 x56442",
        website: "hildegard.org",
        company: .init(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net", bs: "harness real-time e-markets")
    )

    static let ervin = User(
        id: 2,
        name: "Ervin Howell",
        username: "Antonette",
        email: "Shanna@melissa.tv",
        address: .init(street: "Victor Plains", suite: "Suite 879", city: "Wisokyburgh", zipcode: "90566-7771", geo: .init(lat: "-43.9509", lng: "-34.4618")),
        phone: "010-692-6593 x09125",
        website: "anastasia.net",
        company: .init(name: "Deckow-Crist", catchPhrase: "Proactive didactic contingency", bs: "synergize scalable supply-chains")
    )

    static let clementine = User(
        id: 3,
        name: "Clementine Bauch",
        username: "Samantha",
        email: "Nathan@yesenia.net",
        address: .init(street: "Douglas Extension", suite: "Suite 847", city: "McKenziehaven", zipcode: "59590-4157", geo: .init(lat: "-68.6102", lng: "-47.0653")),
        phone: "1-463-123-4447",
        website: "ramiro.info",
        company: .init(name: "Romaguera-Jacobson", catchPhrase: "Face to face bifurcated interface", bs: "e-enable strategic applications")
    )

    static let patricia = User(
        id: 4,
        name: "Patricia Lebsack",
        username: "Karianne",
        email: "Julianne.OConner@kory.org",
        address: .init(street: "Hoeger Mall", suite: "Apt. 692", city: "South Elvis", zipcode: "53919-4257", geo: .init(lat: "29.4572", lng: "-164.2990")),
        phone: "493-170-9623 x156",
        website: "kale.biz",
        company: .init(name: "Robel-Corkery", catchPhrase: "Multi-tiered zero tolerance productivity", bs: "transition cutting-edge web services")
    )

    static let users = [leanne, ervin, clementine, patricia]

    static let posts: [Post] = [
        Post(userId: 1, id: 6, title: "dolorem eum magni eos aperiam quia", body: "ut aspernatur corporis harum nihil quis provident sequi\nmollitia nobis aliquid molestiae\nperspiciatis et ea nemo ab reprehenderit accusantium quas"),
        Post(userId: 1, id: 5, title: "nesciunt quas odio", body: "repudiandae veniam quaerat sunt sed\nalias aut fugiat sit autem sed est\nvoluptatem omnis possimus esse voluptatibus quis"),
        Post(userId: 2, id: 4, title: "eum et est occaecati", body: "ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa\nquis hic commodi nesciunt rem tenetur doloremque"),
        Post(userId: 3, id: 3, title: "ea molestias quasi exercitationem repellat qui ipsa sit aut", body: "et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur"),
        Post(userId: 2, id: 2, title: "qui est esse", body: "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque"),
        Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam"),
    ]

    static let comments: [Comment] = [
        Comment(postId: 1, id: 1, name: "id labore ex et quam laborum", email: "Eliseo@gardner.biz", body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus"),
        Comment(postId: 1, id: 2, name: "quo vero reiciendis velit similique earum", email: "Jayne_Kuhic@sydney.com", body: "est natus enim nihil est dolore omnis voluptatem numquam"),
        Comment(postId: 3, id: 3, name: "fugit labore quia mollitia", email: "Veronica_Goodwin@timmothy.net", body: "ut dolorum nostrum id quia aut est\nfuga est inventore vel eligendi"),
    ]

    static let todos: [Todo] = [
        Todo(userId: 1, id: 1, title: "delectus aut autem", completed: false),
        Todo(userId: 1, id: 2, title: "quis ut nam facilis et officia qui", completed: false),
        Todo(userId: 2, id: 3, title: "fugiat veniam minus", completed: true),
        Todo(userId: 3, id: 4, title: "et porro tempora", completed: true),
        Todo(userId: 4, id: 5, title: "laboriosam mollitia et enim quasi adipisci quia", completed: true),
        Todo(userId: 2, id: 6, title: "qui ullam ratione quibusdam voluptatem", completed: true),
    ]

    static let albums: [Album] = [
        Album(userId: 1, id: 1, title: "quidem molestiae enim"),
        Album(userId: 1, id: 2, title: "sunt qui excepturi placeat culpa"),
        Album(userId: 2, id: 3, title: "omnis laborum odio"),
        Album(userId: 3, id: 4, title: "non esse culpa molestiae omnis sed optio"),
    ]

    static let snapshot = DashboardSnapshot(
        users: users,
        posts: posts,
        comments: comments,
        todos: todos,
        albums: albums
    )

    static let post = posts[0]
    static let user = leanne
}

struct PreviewRepository: DashboardRepository {
    var commentsByPost: [Comment] = PreviewData.comments

    func loadDashboard() async throws -> DashboardSnapshot {
        PreviewData.snapshot
    }

    func comments(for postID: Int) async throws -> [Comment] {
        commentsByPost.filter { $0.postId == postID }
    }
}

extension RootView {
    static var loadedPreview: RootView {
        RootView(preview: PreviewRepository(), phase: .loaded(PreviewData.snapshot))
    }
}

#Preview("Loaded") {
    RootView(preview: PreviewRepository(), phase: .loaded(PreviewData.snapshot))
}

#Preview("Loading") {
    RootView(preview: PreviewRepository(), phase: .loading)
}

#Preview("Error") {
    RootView(
        preview: PreviewRepository(),
        phase: .failed("No internet connection. Check your network and try again.")
    )
}

#Preview("Empty") {
    RootView(preview: PreviewRepository(), phase: .loaded(.empty))
}

#Preview("No results") {
    RootView(
        preview: PreviewRepository(),
        phase: .loaded(PreviewData.snapshot),
        searchText: "zzzz"
    )
}

#Preview("Post") {
    NavigationStack {
        PostDetailView(
            post: PreviewData.posts[5],
            author: PreviewData.leanne,
            repository: PreviewRepository()
        )
    }
}

#Preview("Post without comments") {
    NavigationStack {
        PostDetailView(
            post: PreviewData.posts[1],
            author: PreviewData.leanne,
            repository: PreviewRepository()
        )
    }
}
#endif
