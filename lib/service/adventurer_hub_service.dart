import 'package:karanda/model/user.dart';
import 'package:karanda/repository/auth_repository.dart';

class AdventurerHubService {
  final AuthRepository _authRepository;
  AdventurerHubService({required AuthRepository authRepository}): _authRepository = authRepository;

  Stream<User?> get userStream => _authRepository.userStream;
}