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
		private var readAll : Function;
		
		private var parseLock : Boolean = false;
		private var currentReply : OpReply = null;
		public var replies : Array = new Array();
		
		public function Cursor( dbName : String, collName : String, query : OpQuery, queryID : int, readAll : Function = null ) {
			this.mongo = mongo;
			this.dbName = dbName;
			this.collName = collName;
			this.query = query;
			this.queryID = queryID;
			this.readAll = readAll;
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
		private function parseReply( event : ProgressEvent ) : void {
			// make sure no other event is reading
			trace( "data received: " + event.bytesLoaded );
			if( parseLock ) {
				trace( "locked: exiting" );
				return;
			}
			
			if( currentReply == null ) {
				currentReply = new OpReply;
			}
			
			var socket : Socket = event.target as Socket;
			socket.endian = Endian.LITTLE_ENDIAN;
			trace( "socket ready" );
			
			// retrieve the message length
			if( currentReply.messageLength == -1 ) {
				trace( "trying to determine message size" );
				if( socket.bytesAvailable >= 4 ) {
					currentReply.messageLength = socket.readInt();
					trace( "length is: " + currentReply.messageLength );
				} else {
					trace( "message parts missing..." + currentReply.messageLength );
					// message wasn't retrieved entirely
					socket.addEventListener( ProgressEvent.SOCKET_DATA, parseReply );
					return;
				}
			}
			
			trace( "bytes available: " + socket.bytesAvailable );
			// parse the message once all the data arrived
			if( socket.bytesAvailable + 4 >= currentReply.messageLength ) {
				// prevent other events from reading from this socket
				parseLock = true;
				trace( "lock obtained: parsing" );
				
				currentReply.requestID = socket.readInt();
				currentReply.responseTo = socket.readInt();
				currentReply.opCode = socket.readInt();
				currentReply.responseFlags = socket.readInt();
				var cursorIDBuffer : ByteArray = new ByteArray(); 
				socket.readBytes( cursorIDBuffer, 0, 8 );
				currentReply.cursorID = new Int64( cursorIDBuffer );
				currentReply.startingFrom = socket.readInt();
				currentReply.numberReturned = socket.readInt();
				
				var docsRead : int = 0;
				while( docsRead <  currentReply.numberReturned ) {
					var docSize : int = socket.readInt();
					var obj : ByteArray = new ByteArray();
					obj.endian = Endian.LITTLE_ENDIAN;
					obj.writeInt( docSize );
					socket.readBytes( obj, 4, docSize - 4 );
					obj.position = 0;
					var doc : Object = BSON.decode( obj );
					currentReply.documents.push( doc );
					++docsRead;
				}
				replies.push( currentReply );
				
				trace( "read: " + currentReply.documents.length );
				trace( Utils.objectToString( currentReply.documents[0]) );
				// if there are more results, fetch them
				if( Int64.cmp( currentReply.cursorID, Int64.ZERO ) != 0 ) {
					socket.addEventListener( ProgressEvent.SOCKET_DATA, parseReply );
					socket.writeBytes( new OpGetMore( queryID, dbName+"."+collName, 0, currentReply.cursorID ).toBinaryMsg() );
					socket.flush();
					trace( "getting more..." );
				} else {
					socket.close();
					// run a user-defined callback
					trace( "callback" );
					if( readAll != null ) {
						readAll();
					}
				}
				parseLock = false;
				currentReply = null;
			}
		}

	}
}
