
git repo : https://github.com/Moaz7x/zenlearn.git
# ZenLearn App

ZenLearn is a comprehensive productivity and learning companion designed to help users manage their tasks, study effectively, and stay organized. Built with Flutter, it offers a clean architecture, robust state management, and a rich set of features to enhance daily productivity and learning routines.

## 🌟 Features

ZenLearn is packed with various modules to cater to different aspects of your academic and personal life:

### Task & Productivity Management
*   **Todo List (`features/todo`)**: A powerful and intuitive todo management system.
    *   **Create & Manage Todos**: Add, update, and delete main todo items.
    *   **Subtasks**: Break down complex tasks into manageable subtasks.
    *   **Reminders**: Set reminders for important deadlines and events.
    *   **Completion Tracking**: Mark todos and subtasks as completed.
    *   **Filtering**: Filter todos by completion status (All, Completed, Due Dated) and priority levels.
    *   **Detailed View**: Tap on any todo to view its full details, including subtasks and reminders.
    *   **Edit/Delete Actions**: Easily edit or delete todos via a convenient popup menu on each tile.
*   **Habit Tracker (`features/habit_tracker`)**: Cultivate positive habits and track your progress over time.
*   **Pomodoro Timer (`features/pomodoro`)**: Boost your focus and productivity using the popular Pomodoro technique.
*   **Alarms (`features/alarms`)**: Set and manage alarms for important events or wake-up calls.

### Learning & Study Tools
*   **Flashcards (`features/flashcards`)**: Create, organize, and review flashcards for effective memorization.
    *   **Folder Organization**: Group flashcards into folders for different subjects or topics.
    *   **Review Modes**: Engage in regular or shuffled review sessions.
*   **Exams/Quizzes (`features/exams`)**: Prepare for tests with built-in quiz functionalities.
    *   **Question Management**: Add and manage quiz questions.
    *   **Quiz Sessions**: Take quizzes and view results.
    *   **Review Mode**: Review quiz answers to learn from mistakes.
*   **Notes (`features/notes`)**: A simple yet effective note-taking feature to capture ideas and information.
    *   **Add & View Notes**: Create new notes and browse existing ones.
*   **Classes (`features/classes`)**: Manage your academic classes and schedules.
    *   **Class List**: Keep track of all your courses.
    *   **Calendar View**: Visualize your class schedule in a calendar format.
*   **YouTube Browser (`features/youtube_browser`)**: Integrate with YouTube for learning resources.
    *   **Video Download**: Potentially download YouTube videos (feature dependent on external libraries/APIs).
    *   **Transcript Generation**: Extract transcripts from YouTube videos for study.

### Utility & Personalization
*   **Dashboard (`features/dashboard`)**: A central hub providing an overview of your day and key metrics.
*   **AI Chat (`features/ai_chat`)**: Interact with an AI assistant for quick answers or study help.
*   **Achievements (`features/achievements`)**: Track and celebrate your progress and milestones within the app.
*   **Media Manager (`features/media_manager`)**: Organize and view various media files directly within the app.
    *   **Gallery**: Browse images.
    *   **Audio Viewer**: Play audio files.
    *   **Video Viewer**: Watch videos.
    *   **PDF Viewer**: Read PDF documents.
*   **Settings (`features/settings`)**: Customize app preferences to suit your needs.
*   **Intro (`features/intro`)**: An onboarding experience for new users.

## 🛠️ Technical Architecture

ZenLearn is built following best practices to ensure maintainability, scalability, and performance:

*   **Clean Architecture**: The application adheres to Clean Architecture principles, separating concerns into `domain`, `data`, and `presentation` layers, particularly evident in the `todo` module.
*   **BLoC for State Management**: Utilizes the BLoC (Business Logic Component) pattern for robust and predictable state management across the application.
*   **Dependency Injection**: Employs a dependency injection setup (`di/injection_container.dart`) for managing dependencies and facilitating testing.
*   **Localization**: Supports multiple languages with a dedicated localization system (`core/localization`).
*   **Theming**: Provides a flexible theming system (`core/theme`) for UI customization.
*   **Network Handling**: Includes a dedicated layer for API communication and network status checks (`core/network`).
*   **Notification Services**: Integrates local notification services for reminders and alerts.
*   **Reusable UI Components**: A comprehensive set of custom widgets (`core/widgets`) ensures UI consistency and accelerates development.
*   **Error Handling**: Standardized error and failure handling mechanisms (`core/errors`).

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Moaz7x/zenlearn.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd zenlearn
    ```
3.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

