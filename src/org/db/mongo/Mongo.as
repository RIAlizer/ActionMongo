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

	public class Mongo
	{
		
		// the Master server
		public var master_host : String;
		public var master_port : uint;
		
		// the Slave server
		public var slave_host : String;
		public var slave_port : uint;
		
		// internal state variables
		private var uniqueCounter : uint = 0;
		
		public function Mongo( master_host : String = "localhost", master_port : uint = 27017, slave_host : String = "localhost", slave_port : uint = 27017 ) {
			this.master_host = master_host;
			this.master_port = master_port;
			this.slave_host =  slave_host;
			this.slave_port = slave_port;
		}
		
		
		/**
		 * @brief Get a new database object
		 * @return A new database object
		 */
		public function getDB( dbName : String ) : DB {
			return new DB( this, dbName );
		}
		
		
		/**
		 * @brief Produce a unique identifier
		 * @return A unique identifier
		 */
		internal function getUniqueID() : uint {
			return ++uniqueCounter;
		}
		
		internal function getCurrentHost() : String {
			return master_host;
		}
		
		internal function getCurrentPort() : int {
			return master_port;	
		}
		
		/*public function getDBNameList() : Array {
		var comm : Object = new Object();
		comm.listDatabases = 1;
		getDB( "admin" ).executeCommand( comm );
		}*/
		
	}
}
