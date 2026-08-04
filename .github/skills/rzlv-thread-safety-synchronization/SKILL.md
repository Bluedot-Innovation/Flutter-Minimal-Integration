---
name: 'rzlv-thread-safety-synchronization'
description: 'Review Flutter/C++ platform code for race conditions: unprotected access to shared data structures, missing mutex locks, callbacks received after object destruction, and multi-threaded operations that need consolidation.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Thread Safety & Synchronization

## Purpose

Flag race conditions, unprotected shared state, and multi-threaded coordination issues in Flutter platform code (C++, platform channels, isolates). Inconsistent UI state and hard-to-reproduce crashes are frequently caused by missing synchronization.

## When to Apply

Trigger this skill when a PR touches:
- C++ platform view or shell code that modifies shared data structures
- Object destruction sequences that may race with in-flight callbacks
- Platform channel message handlers that run on different threads
- Operations split across platform thread and raster/UI thread
- Any code that accesses or modifies shared state from multiple call sites

## Key Practices

1. **Protect shared data with mutexes**:
   ```cpp
   // Before: Unprotected access — race condition with other threads
   expected_frame_constraints_.erase(view_id);

   // After: Scoped lock prevents concurrent modification
   std::scoped_lock<std::mutex> lock(resize_mutex_);
   expected_frame_constraints_.erase(view_id);
   ```

2. **Unregister handlers before destroying objects** to prevent callbacks arriving during/after destruction:
   ```dart
   @override
   void destroy() {
     if (_destroyed) return;

     // Unregister BEFORE issuing the destroy, not after
     _owner.removeMessageHandler(this);
     _Win32PlatformInterface.destroyWindow(getWindowHandle());
     _destroyed = true;
     _delegate.onWindowDestroyed();
   }
   ```

3. **Consolidate multi-threaded operations** — when a logical operation requires multiple steps, post all steps to the same thread:
   ```cpp
   // Rather than split across platform and raster threads (race condition):
   task_runners_.GetPlatformTaskRunner()->PostTask([&, jni_facade = jni_facade_]() {
     HideOverlayLayerIfNeeded();
     jni_facade->applyTransaction();
   });
   ```

## Review Checklist

- [ ] Is every write to a shared data structure protected by a mutex or equivalent?
- [ ] Are callbacks/handlers unregistered before the owning object is destroyed?
- [ ] Are logically related multi-step operations posted to the same task runner?
- [ ] Are there any `_destroyed` or `_invalidated` guards missing on async callbacks?
- [ ] Is the threading model of new APIs documented (which thread owns what)?

## Output

Raise findings as:
- 🔴 **Blocking** — race condition that can cause data corruption, crashes, or inconsistent UI in production
- 🟡 **Important** — potential race that is unlikely but possible under load or timing
- 🔵 **Minor** — missing guard or documentation that would improve safety and auditability

