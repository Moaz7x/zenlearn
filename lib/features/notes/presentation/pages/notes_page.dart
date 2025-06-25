import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/routes/app_routes.dart'; // NEW: Import the file where routeObserver is defined
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with RouteAware {
  // Changed from WidgetsBindingObserver to RouteAware
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality (e.g., show a search bar or navigate to a search page)
            // context.read<NotesBloc>().add(SearchNotesEvent(query: 'test'));
          },
        ),
      ],
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}')),
            );
          }
          // يمكنك إضافة المزيد من المستمعين لحالات النجاح إذا لزم الأمر للحصول على ملاحظات محددة لواجهة المستخدم
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('لا توجد ملاحظات بعد. انقر على + لإضافة واحدة!'),
              );
            }
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    context.go('/notes/view/${note.id}');
                  },
                  onTogglePin: () {
                    context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
                  },
                );
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Text('فشل تحميل الملاحظات: ${state.failure.message ?? "غير معروف"}'),
            );
          }
          return const Center(child: Text('ابدأ بإضافة ملاحظاتك!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/notes/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // قم بتسجيل هذه الصفحة مع RouteObserver
    // ModalRoute.of(context)! يعطي المسار الحالي
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // يتم استدعاء هذا التابع عندما يتم إزالة المسار العلوي من المكدس، ويصبح المسار الحالي مرئيًا مرة أخرى.
  @override
  void didPopNext() {
    _loadNotes(); // أعد تحميل الملاحظات عند العودة إلى هذه الصفحة
  }

  // اختياري: يتم استدعاء هذا التابع عندما يتم دفع المسار إلى Navigator.
  // عادةً ما يتم استدعاء _loadNotes() في initState، لذا لا داعي لاستدعائه هنا مرة أخرى
  // إلا إذا كان لديك منطق محدد عند دفع المسار مقابل إنشائه فقط.
  @override
  void didPush() {
    // _loadNotes(); // يمكن استدعاؤه هنا إذا كنت تريد التأكد من التحميل عند الدفع الأول
  }

  @override
  void dispose() {
    // إلغاء التسجيل من RouteObserver عند التخلص من الويدجت
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Initial load when the page is first created
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(const LoadNotes());
  }
}
