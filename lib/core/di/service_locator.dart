class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  void init() {
    // Initialize services
    print(' Dependency injection initialized');
  }
}
