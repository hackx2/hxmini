package mini.types;

enum EntryType {
	Document;
	Section;
	Comment(?type:CommentType); // type = ; | #
	KeyValue;
	DangerousInner;
}