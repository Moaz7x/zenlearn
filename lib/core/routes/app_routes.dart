import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/features/exams/presentation/pages/quizzes_review_page.dart';
import 'package:zenlearn/features/intro/presentation/pages/intro_page.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';
import 'package:zenlearn/features/youtube_browser/presentation/pages/helper_page.dart';

import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../../features/alarms/presentation/pages/alarm_page.dart';
import '../../features/classes/presentation/pages/classes_calendar_page.dart';
import '../../features/classes/presentation/pages/classes_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/exams/presentation/pages/add_questions_page.dart';
import '../../features/exams/presentation/pages/quizzes_folder.dart';
import '../../features/exams/presentation/pages/quizzes_page.dart';
import '../../features/exams/presentation/pages/quizzes_result_page.dart';
import '../../features/flashcards/presentation/pages/add_flashcards_page.dart';
import '../../features/flashcards/presentation/pages/flashcards_folder_page.dart';
import '../../features/flashcards/presentation/pages/flashcards_page.dart';
import '../../features/flashcards/presentation/pages/flashcards_review_page.dart';
import '../../features/flashcards/presentation/pages/flashcards_shuffled_review_page.dart';
import '../../features/habit_tracker/presentation/pages/habit_tracker_page.dart';
import '../../features/media_manager/presentation/pages/audio_viewer_page.dart';
import '../../features/media_manager/presentation/pages/gallery_folder_page.dart';
import '../../features/media_manager/presentation/pages/gallery_page.dart';
import '../../features/media_manager/presentation/pages/pdf_viewer_page.dart';
import '../../features/media_manager/presentation/pages/picture_viewer_page.dart';
import '../../features/media_manager/presentation/pages/video_viewer_page.dart';
import '../../features/notes/domain/entities/note_entity.dart';
import '../../features/notes/presentation/pages/optimized_add_notes_page.dart';
import '../../features/notes/presentation/pages/optimized_note_view_page.dart';
import '../../features/notes/presentation/pages/optimized_notes_page.dart';
import '../../features/pomodoro/presentation/pages/pomodoro_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/todo/presentation/pages/edit_todo_page.dart';
import '../../features/todo/presentation/pages/todo_detail_page.dart';
import '../../features/todo/presentation/pages/todo_list_page.dart';
import '../../features/youtube_browser/presentation/pages/youtube_download_page.dart';
import '../../features/youtube_browser/presentation/pages/youtube_to_transcript_page.dart';

part '../widgets/custom_drawer.dart';
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const IntroPage();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsPage();
        },
      ),
      // --- Top-Level Feature Entry Routes with Nested Routes ---
     GoRoute(
        path: '/notes',
        builder: (BuildContext context, GoRouterState state) {
          return const OptimizedNotesPage(); // Main Notes Page (optimized)
        },
        routes: [
          GoRoute(
            path: 'add', // Path relative to /notes -> /notes/add
            builder: (context, state) {
              final NoteEntity? existingNote = state.extra as NoteEntity?;
              return OptimizedAddNotesPage(existingNote: existingNote);
            },
          ),
          GoRoute(
            path: 'view/:noteId', // Path relative to /notes -> /notes/view/:noteId
            builder: (context, state) {
              final noteId = state.pathParameters['noteId'];
              if (noteId == null) {
                return const Text('Error: Note ID is missing');
              }
              return OptimizedNoteViewPage(noteId: noteId);
            },
          ),
        ],
      ),
      GoRoute(
          path: '/quizzes',
          builder: (BuildContext context, GoRouterState state) {
            return const QuizzesPage(); // Main Quizzes Page (list/folders)
          },
          routes: [
            GoRoute(
              path: 'add-question', // Path relative to /quizzes -> /quizzes/add-question
              builder: (context, state) => const AddQuestionsPage(),
            ),
            GoRoute(
                path: 'folder/:folderId', // Path relative to /quizzes -> /quizzes/folder/:folderId
                builder: (context, state) {
                  final folderId = state.pathParameters['folderId'];
                  return QuizzesFolderPage(folderId: folderId);
                }),
            GoRoute(
                path: 'review/:quizId', // Path relative to /quizzes -> /quizzes/review/:quizId
                builder: (context, state) {
                  final quizId = state.pathParameters['quizId'];
                  return QuizzesReviewPage(quizId: quizId);
                }),
            GoRoute(
                path:
                    'result/:attemptId', // Path relative to /quizzes -> /quizzes/result/:attemptId
                builder: (context, state) {
                  final attemptId = state.pathParameters['attemptId'];
                  return QuizzesResultPage(attemptId: attemptId);
                }),
          ]),
      GoRoute(
        path: '/pomodoro',
        builder: (BuildContext context, GoRouterState state) {
          return const PomodoroPage();
        },
      ),
      GoRoute(
          path: '/classes',
          builder: (BuildContext context, GoRouterState state) {
            return const ClassesPage();
          },
          routes: [
            GoRoute(
              path: 'calendar', // Path relative to /classes -> /classes/calendar
              builder: (context, state) => const ClassesCalendarPage(),
            ),
          ]),
      GoRoute(
          path: '/todos',
          builder: (BuildContext context, GoRouterState state) {
            if (context.mounted) {
              context.read<TodoBloc>().add(LoadTodos());
            }
            return const TodoListPage();
          },
          routes: [
            GoRoute(
              path: 'add', // Path relative to /todos -> /todos/add
              builder: (context, state) => EditTodoPage(
                todo: TodoEntity(
                    title: 'title',
                    description: 'description',
                    isCompleted: false,
                    priority: 1,
                    createdAt: DateTime.now(),
                    subtodos: [],
                    reminders: []),
              ),
            ),
            GoRoute(
                path: 'view/:todoId', // Path relative to /todos -> /todos/view/:todoId
                builder: (context, state) {
                  return TodoDetailPage(
                    todo: TodoEntity(
                        title: 'title',
                        description: 'description',
                        isCompleted: false,
                        createdAt: DateTime.now(),
                        subtodos: [],
                        priority: 1,
                        reminders: []),
                  );
                }),
          ]),
      GoRoute(
          path: '/gallery',
          builder: (BuildContext context, GoRouterState state) {
            return const GalleryPage(); // Main Gallery Page (list/folders)
          },
          routes: [
            // GoRoute(
            //   path: 'camera', // Path relative to /gallery -> /gallery/camera
            //   builder: (context, state) => const CameraPage(),
            // ),
            // GoRoute(
            //   path: 'scanner', // Path relative to /gallery -> /gallery/camera
            //   builder: (context, state) => const ScanPage(),
            // ),
            GoRoute(
                path: 'folder/:folderId', // Path relative to /gallery -> /gallery/folder/:folderId
                builder: (context, state) {
                  final folderId = state.pathParameters['folderId'];
                  return GalleryFolderPage(folderId: folderId);
                }),
            GoRoute(
                path: 'audio/:assetPath', // Path relative to /gallery -> /gallery/audio/:assetPath
                builder: (context, state) {
                  final assetPath = state.pathParameters['assetPath'];
                  return AudioViewerPage(assetPath: assetPath);
                }),
            GoRoute(
                name: 'pdf',
                path: 'pdf/:assetPath', // Path relative to /gallery -> /gallery/pdf/:assetPath
                builder: (context, state) {
                  final assetPath = state.pathParameters['assetPath'];
                  return PdfViewerPage(assetPath: assetPath!);
                }),
            GoRoute(
                path:
                    'picture/:assetPath', // Path relative to /gallery -> /gallery/picture/:assetPath
                builder: (context, state) {
                  final assetPath = state.pathParameters['assetPath'];
                  return PictureViewerPage(assetPath: assetPath);
                }),
            // Video route using query parameter
            GoRoute(
                path: 'video/:assetPath', // Path is just /gallery/video
                builder: (context, state) {
                  final assetPath = state.pathParameters['assetPath'];

                  // Pass both path and title (using path as title for now)
                  return VideoViewerPage(videoPath: assetPath!, title: assetPath.split('/').last);
                }),
          ]),
      GoRoute(
          path: '/flashcards',
          builder: (BuildContext context, GoRouterState state) {
            return const FlashcardsPage(); // Main Flashcards Page (list/folders)
          },
          routes: [
            GoRoute(
              path: 'add', // Path relative to /flashcards -> /flashcards/add
              builder: (context, state) => const AddFlashcardsPage(),
            ),
            GoRoute(
              path: 'review', // Path relative to /flashcards -> /flashcards/review
              builder: (context, state) => const FlashcardsReviewPage(),
            ),
            GoRoute(
                path:
                    'folder/:folderId', // Path relative to /flashcards -> /flashcards/folder/:folderId
                builder: (context, state) {
                  final folderId = state.pathParameters['folderId'];
                  return FlashcardsFolderPage(folderId: folderId);
                }),
            GoRoute(
                path:
                    'shuffled-review/:setId', // Path relative to /flashcards -> /flashcards/shuffled-review/:setId
                builder: (context, state) {
                  final setId = state.pathParameters['setId'];
                  return FlashcardsShuffledReviewPage(setId: setId);
                }),
          ]),
      GoRoute(
        path: '/youtube-download',
        builder: (BuildContext context, GoRouterState state) {
          return const YoutubeDownloadPage();
        },
      ),
      GoRoute(
        path: '/youtube-helper',
        builder: (BuildContext context, GoRouterState state) {
          return const HelperPage();
        },
      ),
      GoRoute(
        path: '/youtube-transcript',
        builder: (BuildContext context, GoRouterState state) {
          return const YoutubeToTranscriptPage();
        },
      ),
      GoRoute(
        path: '/habit-tracker',
        builder: (BuildContext context, GoRouterState state) {
          return const HabitTrackerPage();
        },
      ),
      GoRoute(
        path: '/alarms',
        builder: (BuildContext context, GoRouterState state) {
          return const AlarmPage();
        },
      ),
      GoRoute(
        path: '/achievements',
        builder: (BuildContext context, GoRouterState state) {
          return const AchievementsPage();
        },
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (BuildContext context, GoRouterState state) {
          return const AIChatPage();
        },
      ),
    ],
      observers: [routeObserver],
    // Add errorPageBuilder, redirect, etc. as needed
  );

  static GoRouter get router => _router;
}
