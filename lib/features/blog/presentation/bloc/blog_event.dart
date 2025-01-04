part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}


final class BlogUpload extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File fileimage;
  final List<String> topics;

  BlogUpload({
    required this.posterId,
    required this.title,
    required this.content,
    required this.fileimage,
    required this.topics,
  });
}

final class BlogFetchAllBlogs extends BlogEvent {}