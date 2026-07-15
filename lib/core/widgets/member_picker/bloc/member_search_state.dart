import 'package:equatable/equatable.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';

/// State for member search (query, results, loading, error).
class MemberSearchState extends Equatable {
  const MemberSearchState({
    this.query = '',
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<ListMembersItem> members;
  final bool isLoading;
  final String? errorMessage;

  MemberSearchState copyWith({
    String? query,
    List<ListMembersItem>? members,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MemberSearchState(
      query: query ?? this.query,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [query, members, isLoading, errorMessage];
}
