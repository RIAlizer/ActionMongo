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
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.serialization.bson.BSON;

	public class OpUpdate implements IRequest
	{
		public static const OP_UPDATE : int = 2001;
		
		// flags
		public static var Upsert : int = 1;
		public static var MultiUpdate : int = 2;
		
		public var requestID : int;
		public var fullCollectionName : String; // cstring
		public var flags : int;
		public var selector : Object; // document
		public var update : Object; // document
		
		public function OpUpdate( requestID : int, fullCollectionName : String, flags : int, selector : Object, update : Object ) {
			this.requestID = requestID;
			this.fullCollectionName = fullCollectionName;
			this.flags = flags;
			this.selector = selector;
			this.update = update;
		}
		
		public function toBinaryMsg() : ByteArray {
			var bin : ByteArray = new ByteArray();
			bin.endian = Endian.LITTLE_ENDIAN;
			
			// ### write the header ### // 
			// placeholder for message size
			bin.writeInt( 0 );
			bin.writeInt( requestID );
			bin.writeInt( 0 );
			bin.writeInt( OP_UPDATE );
			
			// ### write the body ### //
			bin.writeInt( 0 ), // ZERO
			bin.writeUTFBytes( fullCollectionName );
			bin.writeByte( 0 ); // write the cstring terminator
			bin.writeInt( flags );
			bin.writeBytes( BSON.encode( selector ) );
			bin.writeBytes( BSON.encode( update ) );
			
			// write the object size
			bin.position = 0;
			bin.writeInt( bin.length );
			
			bin.position = 0;
			return bin;
		}
		
	}
}