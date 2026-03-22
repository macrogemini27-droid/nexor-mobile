# Error Handling Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER INTERFACE                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ File Browser │  │ File Viewer  │  │ File Search  │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                  │                  │                       │
│         └──────────────────┴──────────────────┘                      │
│                            │                                          │
│                    ┌───────▼────────┐                                │
│                    │ ErrorDisplay   │                                │
│                    │  Widget        │                                │
│                    │ ┌────────────┐ │                                │
│                    │ │ Retry      │ │ (if retryable)                │
│                    │ │ Reconnect  │ │ (if connection/auth error)    │
│                    │ │ Dismiss    │ │ (always)                      │
│                    │ └────────────┘ │                                │
│                    └───────▲────────┘                                │
└────────────────────────────┼─────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────────┐
│                    PROVIDER LAYER                                     │
│                    ┌───────┴────────┐                                │
│                    │ Riverpod       │                                │
│                    │ Providers      │                                │
│                    └───────┬────────┘                                │
└────────────────────────────┼─────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────────┐
│                    REPOSITORY LAYER                                   │
│                    ┌───────▼────────┐                                │
│                    │ RetryHelper    │                                │
│                    │ ┌────────────┐ │                                │
│                    │ │ Attempt 1  │ │ ──┐                           │
│                    │ │ Wait 1s    │ │   │                           │
│                    │ │ Attempt 2  │ │   │ Exponential               │
│                    │ │ Wait 2s    │ │   │ Backoff                   │
│                    │ │ Attempt 3  │ │   │                           │
│                    │ │ Wait 4s    │ │ ──┘                           │
│                    │ └────────────┘ │                                │
│                    └───────┬────────┘                                │
│                            │                                          │
│                    ┌───────▼────────┐                                │
│                    │ FileRepository │                                │
│                    │ Impl           │                                │
│                    └───────┬────────┘                                │
└────────────────────────────┼─────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────────┐
│                    CLIENT LAYER                                       │
│                    ┌───────▼────────┐                                │
│                    │ SFTP Client    │                                │
│                    │ SSH Client     │                                │
│                    └───────┬────────┘                                │
│                            │                                          │
│                    ┌───────▼────────┐                                │
│                    │ System Errors  │                                │
│                    │ SocketException│                                │
│                    │ TimeoutExcept. │                                │
│                    │ FileSystemExc. │                                │
│                    │ SftpError      │                                │
│                    └───────┬────────┘                                │
│                            │                                          │
│                    ┌───────▼────────┐                                │
│                    │ ErrorHandler   │                                │
│                    │ .handle()      │                                │
│                    └───────┬────────┘                                │
│                            │                                          │
│                    ┌───────▼────────┐                                │
│                    │ Typed Errors   │                                │
│                    │ NetworkExc.    │ ──► Retryable                 │
│                    │ ConnectionExc. │ ──► Retryable + Reconnect     │
│                    │ TimeoutExc.    │ ──► Retryable                 │
│                    │ FileNotFound   │ ──► Not Retryable             │
│                    │ PermissionExc. │ ──► Not Retryable             │
│                    │ BinaryFileExc. │ ──► Not Retryable             │
│                    └────────────────┘                                │
└──────────────────────────────────────────────────────────────────────┘

ERROR FLOW EXAMPLES:

1. Network Failure (Transient)
   User Action → Repository → SFTP Client → SocketException
   → ErrorHandler → NetworkException (retryable=true)
   → RetryHelper (3 attempts with backoff)
   → If still fails → UI shows "Retry" button

2. File Not Found (Permanent)
   User Action → Repository → SFTP Client → SftpError("not found")
   → ErrorHandler → FileNotFoundException (retryable=false)
   → No retry → UI shows "Go Back" button

3. Connection Lost (Transient)
   User Action → Repository → Check isConnected → false
   → Throw ConnectionException (retryable=true)
   → RetryHelper (3 attempts)
   → If still fails → UI shows "Retry" + "Reconnect" buttons

4. Permission Denied (Permanent)
   User Action → Repository → SFTP Client → SftpError("permission")
   → ErrorHandler → PermissionException (retryable=false)
   → No retry → UI shows "Go Back" button

RETRY TIMELINE:

Attempt 1 ──[fail]──► Wait 1s ──► Attempt 2 ──[fail]──► Wait 2s ──► Attempt 3 ──[fail]──► Show Error
    0s                  1s            2s                  4s            6s                  6s

Total time for 3 attempts: ~6 seconds
```
