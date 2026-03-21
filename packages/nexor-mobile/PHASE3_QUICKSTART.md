# Phase 3: Quick Start Guide

## Prerequisites

- Flutter SDK installed
- OpenCode server running
- Phase 1 & 2 completed

## Setup Steps

### 1. Generate Code

```bash
cd /workspaces/ServMo/work/open/opencode/packages/nexor-mobile

# Install dependencies
flutter pub get

# Generate .g.dart files
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `session_model.g.dart`
- `message_model.g.dart`
- `conversations_provider.g.dart`
- `chat_provider.g.dart`

### 2. Run the App

```bash
flutter run
```

## User Flow

### Creating a Conversation

1. **From Server List** → Tap server → Navigate to `/conversations`
2. **Tap FAB** (+) → Opens `/chat/new`
3. **Fill Form:**
   - Title (optional)
   - Directory (required)
   - Select Agent (General/Build/Explore)
4. **Tap "Create Conversation"** → Navigates to `/chat/:sessionId`

### Sending Messages

1. **Type message** in input field
2. **Tap send button** (paper plane icon)
3. **Watch streaming response** appear in real-time
4. **Auto-scroll** to bottom as messages arrive

### Managing Conversations

- **View all:** Navigate to `/conversations`
- **Delete:** Swipe left on conversation card → Confirm
- **Refresh:** Pull down to refresh list
- **Search:** Tap search icon (coming soon)

## API Flow

```
User Action → Provider → Repository → API Client → OpenCode Server
                ↓
            UI Update
```

### Example: Send Message

```
1. User types "Hello" and taps send
2. ChatProvider.sendMessage("Hello")
3. SessionRepository.sendMessage(sessionId, "Hello")
4. ApiClient.postStream("/session/:id/message")
5. Stream chunks received
6. ChatProvider updates state with each chunk
7. UI re-renders with new content
8. Auto-scroll to bottom
```

## Key Components

### Providers

```dart
// Get conversations
ref.watch(conversationsProvider())

// Get specific session
ref.watch(sessionProvider(sessionId))

// Get messages
ref.watch(chatProvider(sessionId))

// Check streaming state
ref.watch(streamingStateProvider(sessionId))
```

### Navigation

```dart
// To conversations list
context.push('/conversations')

// To new conversation
context.push('/chat/new')
context.push('/chat/new?directory=/path&file=/path/file.dart')

// To chat
context.push('/chat/$sessionId')
```

## Features Overview

### Conversation List
- ✅ List all conversations
- ✅ Last message preview
- ✅ Message count
- ✅ Agent badge
- ✅ Project badge
- ✅ Swipe to delete
- ✅ Pull to refresh
- ✅ Empty state

### New Conversation
- ✅ Title input
- ✅ Directory selection
- ✅ Agent selector (3 types)
- ✅ Visual cards
- ✅ Loading state

### Chat Screen
- ✅ Message list
- ✅ User messages (right, blue)
- ✅ AI messages (left, gray)
- ✅ Real-time streaming
- ✅ Typing indicator
- ✅ Auto-scroll
- ✅ Scroll to bottom FAB
- ✅ Message input
- ✅ Copy functionality
- ✅ Code highlighting
- ✅ Markdown rendering

## Troubleshooting

### Build Errors

**Error: Missing .g.dart files**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: Conflicting outputs**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: Hive adapter not registered**
- Check `app_database.dart` has all adapters registered
- Ensure typeIds are unique (0-4 used)

### Runtime Errors

**Error: Server not found**
- Ensure at least one server is added in Phase 1
- Check server is connected

**Error: Failed to get sessions**
- Verify OpenCode server is running
- Check API endpoint: `GET /session`
- Verify network connectivity

**Error: Streaming not working**
- Check API endpoint: `POST /session/:id/message`
- Verify server supports SSE (Server-Sent Events)
- Check Dio configuration for streaming

### UI Issues

**Messages not auto-scrolling**
- Check `_autoScroll` flag in ChatScreen
- Verify ScrollController is attached

**Typing indicator not showing**
- Check `streamingStateProvider` is updating
- Verify `isStreaming` flag in AIMessage

**Code blocks not highlighting**
- Verify `flutter_highlight` package installed
- Check language detection in MessageParser

## Testing Checklist

### Conversation Management
- [ ] Create conversation with title
- [ ] Create conversation without title
- [ ] Select different agents
- [ ] Delete conversation
- [ ] Cancel delete
- [ ] Pull to refresh
- [ ] View empty state

### Messaging
- [ ] Send short message
- [ ] Send long message
- [ ] Send message with code
- [ ] Receive streaming response
- [ ] Copy message
- [ ] Copy code block
- [ ] View markdown formatting

### UI/UX
- [ ] Auto-scroll works
- [ ] Scroll to bottom FAB appears
- [ ] Typing indicator animates
- [ ] Input field expands
- [ ] Send button changes icon
- [ ] Loading states show
- [ ] Error states show
- [ ] Empty states show

### Navigation
- [ ] Navigate to conversations
- [ ] Navigate to new conversation
- [ ] Navigate to chat
- [ ] Back button works
- [ ] Deep linking works

## Performance Tips

1. **Lazy Loading**: Messages load on demand
2. **Caching**: Hive stores sessions/messages locally
3. **Streaming**: Efficient real-time updates
4. **Auto-scroll**: Only when at bottom
5. **Debouncing**: Search input (when implemented)

## Next Phase

Phase 4 will include:
- File attachment support
- Voice input
- Image support
- Export functionality
- Advanced search
- Conversation archiving
- Multi-server support

## Support

For issues or questions:
1. Check `PHASE3_COMPLETE.md` for detailed documentation
2. Review `PHASE3_SUMMARY.md` for implementation overview
3. Check OpenCode server logs
4. Verify API endpoints with Postman/curl

## Success! 🎉

If you can:
1. ✅ Create a conversation
2. ✅ Send a message
3. ✅ See streaming response
4. ✅ View code with syntax highlighting
5. ✅ Delete a conversation

**Phase 3 is working correctly!**
