//
//  SQLiteManager.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.
//

import Foundation
import SQLite3

struct FavoriteBook {
    let workKey: String
    let title: String
    let authors: String
    let coverId: Int?
    let detailsJSON: String?
    let savedAt: TimeInterval
}

final class SQLiteManager {
    static let shared = SQLiteManager()
    private var db: OpaquePointer?

    internal var dbPath: String = "favorites.sqlite"
    
    internal func openDB() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbURL = docs.appendingPathComponent(dbPath)

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("SQLite: unable to open DB at \(dbURL.path)")
            db = nil
        }
    }

    //MARK: Create Table
    internal func createTable() -> Bool {
        let sql = """
        CREATE TABLE IF NOT EXISTS favorites (
            work_key TEXT PRIMARY KEY,
            title TEXT,
            authors TEXT,
            cover_id INTEGER,
            details_json TEXT,
            saved_at REAL
        );
        """
        var err: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            if let e = err { print("SQLite create error:", String(cString: e)) }
            return false
        }
        return true
    }

    internal func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
            self.db = nil
        }
    }

    private init() {
        openDB()
        let _ = createTable()
    }
    
    //MARK: Save Favorite
    @discardableResult
    func saveFavorite(book: BookDoc, detailsJSON: String?) -> Bool {
        let workKey = book.key.hasPrefix("/") ? String(book.key.dropFirst()) : book.key
        let sql = "INSERT OR REPLACE INTO favorites (work_key, title, authors, cover_id, details_json, saved_at) VALUES (?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK { return false }

        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (workKey as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, ((book.title ?? "") as NSString).utf8String, -1, nil)

        let authors = book.author_name?.joined(separator: ", ") ?? ""
        sqlite3_bind_text(stmt, 3, (authors as NSString).utf8String, -1, nil)

        if let cid = book.cover_i {
            sqlite3_bind_int(stmt, 4, Int32(cid))
        } else {
            sqlite3_bind_null(stmt, 4)
        }

        if let d = detailsJSON {
            sqlite3_bind_text(stmt, 5, (d as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 5)
        }

        sqlite3_bind_double(stmt, 6, Date().timeIntervalSince1970)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("SQLite insert failed: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }

    //MARK: Delete Favorite
    @discardableResult
    func deleteFavorite(workKey raw: String) -> Bool {
        let workKey = raw.hasPrefix("/") ? String(raw.dropFirst()) : raw
        let sql = "DELETE FROM favorites WHERE work_key = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK { return false }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (workKey as NSString).utf8String, -1, nil)
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("SQLite delete failed: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }

    //MARK: Is Favorite
    func isFavorite(workKey raw: String) -> Bool {
        let workKey = raw.hasPrefix("/") ? String(raw.dropFirst()) : raw
        let sql = "SELECT 1 FROM favorites WHERE work_key = ? LIMIT 1;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK { return false }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (workKey as NSString).utf8String, -1, nil)
        let done = sqlite3_step(stmt)
        return done == SQLITE_ROW
    }

    //MARK: Get All Favorites
    func fetchAllFavorites() -> [FavoriteBook] {
        var results = [FavoriteBook]()
        let sql = "SELECT work_key, title, authors, cover_id, details_json, saved_at FROM favorites ORDER BY saved_at DESC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK { return [] }
        defer { sqlite3_finalize(stmt) }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let wk = String(cString: sqlite3_column_text(stmt, 0))
            let title = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
            let authors = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
            let coverId = sqlite3_column_type(stmt, 3) != SQLITE_NULL ? Int(sqlite3_column_int(stmt, 3)) : nil
            let details = sqlite3_column_text(stmt, 4).flatMap { String(cString: $0) }
            let saved = sqlite3_column_double(stmt, 5)
            results.append(FavoriteBook(workKey: wk, title: title, authors: authors, coverId: coverId, detailsJSON: details, savedAt: saved))
        }
        return results
    }
}
