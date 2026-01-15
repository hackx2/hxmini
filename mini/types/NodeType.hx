package mini.types;

enum NodeType {
	Document;
	Section;
	KeyValue;
	Comment(?type:CommentVariant); // type = ; | #
	DangerousInner(data:String);
}