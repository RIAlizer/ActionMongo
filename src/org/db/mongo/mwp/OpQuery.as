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
 */

package org.db.mongo.mwp
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	import org.serialization.bson.BSON;

	public class OpQuery implements IRequest
	{
		
		public static const OP_QUERY : int = 2004;
		
		// flags
		public static const TailableCursor : uint = 2;
		public static const SlaveOK : uint = 4;
		public static const OplogReplay : uint = 8; // ignore
		public static const NoCursorTimeout : uint = 16;
		public static const AwaitData : uint = 32;
		public static const Exhaust : uint = 64;
		
		public var requestID : int;
		public var flags : int = 0;
		public var fullCollectionName : String; // cstring
		public var numberToSkip : int;
		public var numberToReturn : int;
		public var query : Object; // document
		public var returnFieldSelector : Object = null; // document (optional)
		
		public function OpQuery( requestID : int, flags : int, fullCollectionName : String, numberToSkip : int, numberToReturn : int, query : Object, returnFieldSelector : Object = null ) {
			this.requestID = requestID;
			this.flags = flags;
			this.fullCollectionName = fullCollectionName;
			this.numberToSkip = numberToSkip;
			this.numberToReturn = numberToReturn;
			this.query = query;
			this.returnFieldSelector = returnFieldSelector;
		}
		
		public function toBinaryMsg() : ByteArray {
			var bin : ByteArray = new ByteArray();
			bin.endian = Endian.LITTLE_ENDIAN;
			
			// ### write the header ### // 
			// placeholder for message size
			bin.writeInt( 0 );
			bin.writeInt( requestID );
			bin.writeInt( 0 );
			bin.writeInt( OP_QUERY );
			
			// ### write the body ### //
			bin.writeInt( flags );
			bin.writeUTFBytes( fullCollectionName );
			bin.writeByte( 0 ); // write the cstring terminator
			bin.writeInt( numberToSkip );
			bin.writeInt( numberToReturn );
			bin.writeBytes( BSON.encode( query ) );
			if( returnFieldSelector != null ) {
				bin.writeBytes( BSON.encode( returnFieldSelector ) );
			}
			
			// write the object size
			bin.position = 0;
			bin.writeInt( bin.length );
			
			bin.position = 0;
			return bin;
		}
	}
}