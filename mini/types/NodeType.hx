package mini.types;

enum NodeType {
	Document;
	Section;
	KeyValue;
	Comment(comment:String, ?type:CommentVariant); // type = ; | #
	DangerousInner(data:String);
}