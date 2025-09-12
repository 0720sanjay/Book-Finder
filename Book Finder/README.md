#Book Finder
   A simple app for finding and saving favorite books.

# Setup Instructions
 1) Get Xcode: Download from the App Store.
 2) Create a Repository: In Terminal, run git init, git add ., and git commit. Push to a service like GitHub.
 3) Open Project: Open the .xcodeproj file in Xcode.
 4) Run App: Connect a device or use a simulator, then press the "Run" button.

# Architecture
 1) MVVM: Separates the app into three parts.
 2) View: The UI (SwiftUI). Observes the ViewModel.
 3) ViewModel: The logic and state manager. Independent of SwiftUI for easy testing.
 4) Model: Simple data structures.

# Clean Architecture (Repository Pattern):
  1) Protocol: Defines a contract for data operations (BookRepositoryProtocol).
  2) Dependency Injection: ViewModel uses the protocol, not a specific database class, making it flexible.

# API Integration
 1) Networking: Handles all data requests to the Open Library API.
 2) Pagination: Loads initial results, then fetches more as the user scrolls.
 3) Images: Uses AsyncImage for efficient, asynchronous loading of book covers.

# Database Design
  1) Local Storage: Uses SQLite to store a user's favorite books locally.
  2) Separation: SQLiteManager handles low-level database tasks. This keeps the ViewModel clean and database.

# Known Limitations
  1) Limited Error Handling: No detailed user messages for network errors.
  2) No User Accounts: Favorites are saved only on the local device.
  3) Scalability: May have performance issues with extremely large datasets.
