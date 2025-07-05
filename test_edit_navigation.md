# Notes Edit Navigation Test Guide

## Test Scenarios

### 1. Edit from Note Card
**Steps:**
1. Navigate to `/notes` (main notes page)
2. Find any note card
3. Click the edit icon (pencil icon) in the note card
4. Verify navigation to `/notes/edit/{noteId}`
5. Verify the form is pre-filled with existing note data

**Expected Result:**
- Navigation should work smoothly
- Edit page should load with existing note data
- Title, content, color, and tags should be pre-populated

### 2. Edit from Note View Page
**Steps:**
1. Navigate to `/notes` (main notes page)
2. Click on any note card to view it
3. In the note view page, click the edit button in the AppBar
4. Verify navigation to `/notes/edit/{noteId}`
5. Verify the form is pre-filled with existing note data

**Expected Result:**
- Navigation should work smoothly
- Edit page should load with existing note data
- All note properties should be correctly displayed

### 3. Direct Edit URL Navigation
**Steps:**
1. Navigate directly to `/notes/edit/{validNoteId}`
2. Verify the note loads correctly
3. Verify the form is pre-filled

**Expected Result:**
- Note should load via the _NoteEditLoader
- Form should be pre-populated with note data

### 4. Edit and Save
**Steps:**
1. Navigate to edit page via any method above
2. Modify the note title, content, or other properties
3. Click "تحديث الملاحظة" (Update Note)
4. Verify the note is updated and navigation returns to notes list

**Expected Result:**
- Note should be successfully updated
- Changes should be reflected in the notes list
- Success message should be displayed

## Routes Implemented

- ✅ `/notes/add` - Add new note
- ✅ `/notes/edit/:noteId` - Edit existing note (NEW)
- ✅ `/notes/view/:noteId` - View note

## Components Updated

- ✅ `UnifiedNoteCard` - Added edit button
- ✅ `OptimizedNoteViewPage` - Updated edit button to pass note data
- ✅ `_NoteEditLoader` - New component for loading notes by ID
- ✅ `app_routes.dart` - Added edit route configuration

## Navigation Methods

1. **With Note Data (Faster):**
   ```dart
   context.go('/notes/edit/${note.id}', extra: note);
   ```

2. **With Note ID Only (Loads from database):**
   ```dart
   context.go('/notes/edit/${noteId}');
   ```

Both methods are supported and will work correctly.
