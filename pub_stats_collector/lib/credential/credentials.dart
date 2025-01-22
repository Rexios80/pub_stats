class Credentials {
  static const _userAgent = 'Rexios80/pub_stats_collector';

  static final prod = Credentials._(userAgent: _userAgent);

  static final debug = Credentials._(userAgent: _userAgent);

  //! THIS WILL MODIFY THE PRODUCTION DATABASE
  static final tool = Credentials._(userAgent: _userAgent);

  final String userAgent;

  const Credentials._({required this.userAgent});
}
