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
	
	import org.serialization.bson.Int64;
	
	public class OpKillCursors implements IRequest
	{
		
		public static const OP_KILL_CURSORS : int = 2007;
		
		public var requestID : int;
		public var numberOfCursorIDs : uint;
		public var cursorIDs : Array; // int64
		
		public function OpKillCursors( requestID : int, numberOfCoursorIDs : uint, cursorIDs : Array ) {
			this.requestID = requestID;
			this.numberOfCursorIDs = numberOfCoursorIDs;
			this.cursorIDs = cursorIDs;
		}
			
			
		public function toBinaryMsg() : ByteArray {
			var bin : ByteArray = new ByteArray();
			bin.endian = Endian.LITTLE_ENDIAN;
			
			// ### write the header ### // 
			// placeholder for message size
			bin.writeInt( 0 );
			bin.writeInt( requestID );
			bin.writeInt( 0 );
			bin.writeInt( OP_KILL_CURSORS );
			
			// ### write the body ### //
			bin.writeInt( 0 ); // ZERO
			bin.writeInt( numberOfCursorIDs );
			for each( var id : Int64 in cursorIDs ) {
				bin.writeBytes( id.getAsBytes() );
			}
			
			// write the object size
			bin.position = 0;
			bin.writeInt( bin.length );
			
			bin.position = 0;
			return bin;
		}
		
		public function waitForResponse() : Boolean {
			return false;
		}
		
	}
}