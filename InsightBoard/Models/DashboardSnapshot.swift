//
//  DashboardSnapshot.swift
//  InsightBoard
//

import Foundation

struct DashboardSnapshot: Equatable {
    let users: [User]
    let posts: [Post]
    let comments: [Comment]
    let todos: [Todo]
    let albums: [Album]

    let usersByID: [Int: User]
    let commentCountByPostID: [Int: Int]
    let postCountByUserID: [Int: Int]

    init(users: [User], posts: [Post], comments: [Comment], todos: [Todo], albums: [Album]) {
        self.users = users.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        self.posts = posts.sorted { $0.id > $1.id }
        self.comments = comments
        self.todos = todos
        self.albums = albums

        var usersByID: [Int: User] = [:]
        for user in users {
            usersByID[user.id] = user
        }
        self.usersByID = usersByID

        var commentCounts: [Int: Int] = [:]
        for comment in comments {
            commentCounts[comment.postId, default: 0] += 1
        }
        self.commentCountByPostID = commentCounts

        var postCounts: [Int: Int] = [:]
        for post in posts {
            postCounts[post.userId, default: 0] += 1
        }
        self.postCountByUserID = postCounts
    }

    static let empty = DashboardSnapshot(users: [], posts: [], comments: [], todos: [], albums: [])

    var isEmpty: Bool {
        users.isEmpty && posts.isEmpty && comments.isEmpty && todos.isEmpty && albums.isEmpty
    }

    var completedTodoCount: Int {
        todos.filter(\.completed).count
    }

    var openTodos: [Todo] {
        todos.filter { !$0.completed }.sorted { $0.id < $1.id }
    }

    var completionRate: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedTodoCount) / Double(todos.count)
    }

    func user(id: Int) -> User? {
        usersByID[id]
    }

    func commentCount(for postID: Int) -> Int {
        commentCountByPostID[postID, default: 0]
    }

    func postCount(for userID: Int) -> Int {
        postCountByUserID[userID, default: 0]
    }
}
