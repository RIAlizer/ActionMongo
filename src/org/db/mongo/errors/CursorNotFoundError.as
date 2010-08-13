package org.db.mongo.errors
{
	import org.db.mongo.mwp.OpReply;

	public class CursorNotFoundError extends Error
	{
		
		public var serverReply : OpReply;
		
		public function CursorNotFoundError( serverReply : OpReply, message:*="", id:*=0 )
		{
			super(message, id);
			this.serverReply = serverReply;
		}
	}
}