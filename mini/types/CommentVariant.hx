package mini.types;

enum abstract CommentVariant(String) to String from String {
    final SEMICOLON:CommentVariant = ';';
    final HASHTAG:CommentVariant = '#';
}