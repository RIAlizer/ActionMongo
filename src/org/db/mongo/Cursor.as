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

package org.db.mongo
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.db.mongo.mwp.OpGetMore;
	import org.db.mongo.mwp.OpQuery;
	import org.db.mongo.mwp.OpReply;
	import org.serialization.bson.BSON;
	import org.serialization.bson.Int64;
	import org.serialization.bson.Utils;

	public class Cursor
	{
		
		private var mongo : Mongo;
		private var dbName : String;
		private var collName : String;
		private var query : OpQuery;
		private var queryID : int;
		private var cursorID : Int64;
		private var readAll : Function;
		
		public var documents : Array;
		
		public function Cursor( dbName : String, collName : String, query : OpQuery, queryID : int, readAll : Function = null ) {
			this.mongo = mongo;
			this.dbName = dbName;
			this.collName = collName;
			this.query = query;
			this.queryID = queryID;
			this.readAll = readAll;
			documents = new Array();
		}
		
		
		/**
		 * @brief Send a query when the socket is ready
		 * @param event Event generated for Event.CONNECT
		 */
		internal function sendQuery( event : Event ) : void {
			var socket : Socket = event.target as Socket;
			socket.addEventListener( ProgressEvent.SOCKET_DATA, parseReply );
			socket.writeBytes( query.toBinaryMsg() );
			socket.flush();
		}
		
		
		/**
		 * @brief Read a response from the socket and extend the list of documents in the cursor
		 * @param event Event generated for ProgressEvent.SOCKET_DATA
		 */
		private function parseReply( event : Event ) : void {
			var socket : Socket = event.target as Socket;
			socket.endian = Endian.LITTLE_ENDIAN;
			var response : OpReply = new OpReply();
			
			// read header
			var messageLength : int = socket.readInt();
			var requestID : int = socket.readInt();
			response.responseTo = socket.readInt();
			var opCode : int = socket.readInt();
			
			// read body
			response.responseFlags = socket.readInt();
			var cursorID : ByteArray = new ByteArray(); 
			socket.readBytes( cursorID, 0, 8 );
			response.cursorID = new Int64( cursorID );
			response.startingFrom = socket.readInt();
			response.numberReturned = socket.readInt();
			// read all the documents contained in the response
			for( var o : int = 0; o < response.numberReturned; ++o ) {
				var len : int = socket.readInt();
				var obj : ByteArray = new ByteArray();
				obj.endian = Endian.LITTLE_ENDIAN;
				obj.writeInt( len );
				socket.readBytes( obj, 4, len-4 );
				obj.position = 0;
				var doc : Object = BSON.decode( obj );
				documents.push( doc );
			}
			
			// if there are more results, fetch them
			if( Int64.cmp( response.cursorID, Int64.ZERO ) != 0 ) {
				socket.writeBytes( new OpGetMore( queryID, dbName+"."+collName, 0, response.cursorID ).toBinaryMsg() );
			} else {
				socket.close();
				// run a user-defined callback
				if( readAll != null ) {
					readAll();
				}
			}
		}

	}
}
