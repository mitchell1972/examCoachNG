import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final String? title;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText = 'Try Again',
    this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            
            Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      error: message ?? 'Please check your internet connection and try again.',
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.server_problem,
      title: 'Server Error',
      error: message ?? 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
      retryText: 'Try Again',
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onGoHome;

  const NotFoundErrorWidget({
    super.key,
    this.message,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.search_off,
      title: 'Not Found',
      error: message ?? 'The content you\'re looking for could not be found.',
      onRetry: onGoHome,
      retryText: 'Go Home',
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          AppErrorWidget(
            error: _error.toString(),
            onRetry: () => setState(() {
              _error = null;
              _stackTrace = null;
            }),
          );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
          });
        }
      });
      return const SizedBox.shrink();
    };
  }
}

// Error message helpers
class ErrorMessage {
  static String getNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'Network connection failed. Please check your internet connection.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('host')) {
      return 'Unable to reach server. Please try again later.';
    }
    
    return 'Network error occurred. Please check your connection and try again.';
  }

  static String getAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Your session has expired. Please login again.';
    }
    
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You don\'t have permission to access this resource.';
    }
    
    if (errorString.contains('invalid') && errorString.contains('credentials')) {
      return 'Invalid login credentials. Please check your phone number and try again.';
    }
    
    return 'Authentication error. Please login again.';
  }

  static String getServerError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('500')) {
      return 'Server is experiencing issues. Please try again later.';
    }
    
    if (errorString.contains('502') || errorString.contains('503')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    
    if (errorString.contains('404')) {
      return 'The requested resource was not found.';
    }
    
    return 'Server error occurred. Please try again later.';
  }

  static String getUserFriendlyError(dynamic error) {
    if (error == null) return 'An unknown error occurred.';
    
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout')) {
      return getNetworkError(error);
    }
    
    // Auth errors
    if (errorString.contains('unauthorized') || 
        errorString.contains('forbidden') ||
        errorString.contains('credentials')) {
      return getAuthError(error);
    }
    
    // Server errors
    if (errorString.contains('500') || 
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server')) {
      return getServerError(error);
    }
    
    // Default fallback
    return 'Something went wrong. Please try again.';
  }
}
