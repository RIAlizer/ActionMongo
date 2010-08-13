package org.db.mongo.errors
{
	import org.db.mongo.mwp.OpReply;

	public class LostReplyError extends Error
	{
		
		public function LostReplyError( message:*="", id:*=0 )
		{
			super( message, id );
		}
	}
}