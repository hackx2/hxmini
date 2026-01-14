package mini.types;

enum abstract CommentType(String) to String from String {
    final SEMICOLON:CommentType = ';';
    final HASHTAG:CommentType = '#';
}