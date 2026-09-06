import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _initialized = false;

  /// jo notifications pehle se pata hain unke ids
  Set<String> _knownNotifIds = {};
  bool _listenerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _attachListenerAndLoad();
    }
  }

  Future<void> _attachListenerAndLoad() async {
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // pehle se jo bhi notifications hain unko known mark kar do
    _knownNotifIds = notifProvider.notifications.map((n) => n.id).toSet();

    if (!_listenerAttached) {
      notifProvider.addListener(_onNotificationsChanged);
      _listenerAttached = true;
    }

    await _loadData();
  }

  void _onNotificationsChanged() {
    if (!mounted) return;
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final currentIds = notifProvider.notifications.map((n) => n.id).toSet();

    // naye ids = current - known
    final newIds = currentIds.difference(_knownNotifIds);
    if (newIds.isNotEmpty) {
      // ek koi naya notification uthao
      final AppNotification? latestNew = notifProvider.notifications.isEmpty
          ? null
          : notifProvider.notifications.firstWhere(
              (n) => newIds.contains(n.id),
              orElse: () => notifProvider.notifications.last,
            );

      _knownNotifIds = currentIds;

      if (latestNew != null) {
        _showNewNotificationPopup(latestNew);
      }
    }
  }

  void _showNewNotificationPopup(AppNotification n) {
    if (!mounted) return;

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        content: Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'New notification: ${n.title}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: theme.colorScheme.primary,
          onPressed: () {
            // list me rehke hi tap karega user
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final user = authProvider.user;
    final token = authProvider.token;

    // agar user ya token missing hai to kuch mat karo
    if (user == null || token == null || token.isEmpty) {
      debugPrint(
          'NotificationScreen: user/token null hai, fetchNotifications skip');
      return;
    }

    await notifProvider.fetchNotifications(
      userId: user.id,
      token: token,
    );

    // fetch ke baad list ko knownIds me sync kar do
    _knownNotifIds = notifProvider.notifications.map((n) => n.id).toSet();
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.removeListener(_onNotificationsChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.15),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildBody(notifProvider),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationProvider notifProvider) {
    // yahan se auth token le rahe hain markAsRead ke liye
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    // 1) Loading state
    if (notifProvider.isLoading && notifProvider.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          _LoadingState(),
        ],
      );
    }

    // 2) Error state (no data)
    if (notifProvider.error != null && notifProvider.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          _ErrorState(message: notifProvider.error!),
        ],
      );
    }

    // 3) Empty state (no notifications but no error)
    if (notifProvider.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          _EmptyState(),
        ],
      );
    }

    // 4) Actual list – professional cards
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notifProvider.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final AppNotification n = notifProvider.notifications[index];
        return _NotificationCard(
          notification: n,
          onTap: () async {
            // sirf tab hit karo jab unread ho + token valid ho
            if (!n.isRead && token != null && token.isNotEmpty) {
              await notifProvider.markAsRead(
                notifId: n.id,
                token: token,
              );
            } else {
              debugPrint(
                  'markAsRead skip: either already read ya token null/empty');
            }
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    this.onTap,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    final String scheduledText = notification.notificationDate != null
        ? 'Scheduled • ${_formatDate(notification.notificationDate)}'
        : '';
    final String receivedText = notification.createdAt != null
        ? 'Received • ${_formatDate(notification.createdAt)}'
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? theme.colorScheme.primaryContainer.withOpacity(0.18)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
          border: Border.all(
            color: isUnread
                ? theme.colorScheme.primary.withOpacity(0.25)
                : theme.dividerColor.withOpacity(0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // leading icon + unread dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (isUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(notification.createdAt ??
                            notification.notificationDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (scheduledText.isNotEmpty || receivedText.isNotEmpty)
                        Text(
                          scheduledText.isNotEmpty
                              ? scheduledText
                              : receivedText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading notifications...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('empty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 64,
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'No notifications yet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'We’ll notify you when something new comes.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: 64,
          color: theme.colorScheme.error.withOpacity(0.7),
        ),
        const SizedBox(height: 12),
        Text(
          'Couldn\'t load notifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pull down to retry.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
