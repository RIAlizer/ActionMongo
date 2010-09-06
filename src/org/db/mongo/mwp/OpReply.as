/*
 * Copyright (c) 2010 Claudio Alberto Andreoni.
 *	
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 	
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

package org.db.mongo.mwp
{
	import org.db.mongo.errors.QueryFailureError;
	import org.serialization.bson.Int64;
	
	public class OpReply
	{
		public static const OP_REPLY : int = 1;
		
		
		// responseFlags
		public static const CursorNotFound : int = 1;
		public static const QueryFailure : int = 2;
		public static const ShardConfigStale : int = 4; // ignore
		public static const AwaitCapable : int = 8;
		
		public var messageLength : int = -1; // unparsed object
		public var requestID : int;
		public var responseTo : int;
		public var opCode : int;
		public var responseFlags : int;
		public var cursorID : Int64;
		public var startingFrom : int;
		public var numberReturned : int;
		public var documents : Array; // Objects as documents
		
		public function OpReply() {
			documents = new Array();
			messageLength = -1;
		}
		
		public function queryFailed() : Boolean {
			if ( responseFlags & OpReply.QueryFailure == OpReply.QueryFailure ) {
				return true;
			} else {
				return false;
			}
		}
		
		public function cursorNotFound() : Boolean {
			if( responseFlags & OpReply.CursorNotFound == OpReply.CursorNotFound ) {
				return true;
			} else {
				return false;
			}
		}
		
	}
}