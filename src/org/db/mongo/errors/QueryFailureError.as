package org.db.mongo.errors
{
	import org.db.mongo.mwp.OpReply;

	public class QueryFailureError extends Error
	{
		
		public var serverReply : OpReply;
		
		public function QueryFailureError( serverReply : OpReply, message:*="", id:*=0 )
		{
			super(message, id);
			this.serverReply = serverReply;
		}
	}
}