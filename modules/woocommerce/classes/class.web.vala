using GLib;
using Soup;
using Gee;

namespace SinticBolivia
{
	
	class SBWeb : Object
	{
		//public delegate void DownloadProgressCallback(double downloaded_bytes, double total_bytes);
		public static void Download(string url, string dest_file, FileProgressCallback? progress_callback = null)
		{
			//MainLoop loop = new MainLoop ();
			File url_handler 	= File.new_for_uri(url);
			File dest_handler	= File.new_for_path(dest_file);
			try
			{
				url_handler.copy(dest_handler, FileCopyFlags.NONE, null, progress_callback);
			}
			catch(GLib.Error e)
			{
				stderr.printf("DOWNLOAD ERROR: %s\n", e.message);
				//loop.quit();
				url_handler = null;
			}
		}
		public static void DownloadAsync(string url, string dest_file, FileProgressCallback? progress_callback = null)
		{
			File url_handler 	= File.new_for_uri(url);
			File dest_handler	= File.new_for_path(dest_file);
			url_handler.copy_async.begin(dest_handler, FileCopyFlags.NONE, Priority.DEFAULT, null, 
				progress_callback,
				(obj, res) => 
				{
					try 
					{
						bool tmp = url_handler.copy_async.end (res);
						stdout.printf ("Result: %s\n", tmp.to_string ());
					} 
					catch (Error e) 
					{
						stdout.printf ("Error: %s\n", e.message);
					}
				});
		}
		
		public static void RequestData(string url, out uint8[] buffer)
		{
			string method = "GET";
			
			//var fh = File.new_for_path("test.png");
			//try
			//{
				Soup.SessionSync session = new Soup.SessionSync();
				var message = new Soup.Message (method, url);
				session.send_message(message);
				/*
				if( fh.query_exists() )
				{
					fh.delete();
				}
				OutputStream? stream = fh.create(FileCreateFlags.NONE);
				// Write text data to file
				var data_stream = new DataOutputStream (stream);
				//data_stream.put_string (message.response_body.flatten());
				*/
				buffer = message.response_body.data;
				/*
				foreach(uint8 byte in buffer)
				{
					data_stream.put_byte(byte);
				}
				*/
			//}
			//catch(GLib.Error e)
			//{
			//	stdout.printf("ERROR: %s\n", e.message);
			//}
		
			
			
			//return message.response_body.flatten().data;
		}
		public static string RequestString(string url)
		{
			string method = "GET";
			Soup.SessionSync session = new Soup.SessionSync();
			var message = new Soup.Message (method, url);
			session.send_message(message);
			return (string)message.response_body.flatten().data;
		}
		public static bool HasConnection(string url = "http://google.com")
		{
			/*
			try
			{
				SessionSync session = new Soup.SessionSync();
				Soup.Request request		= session.request(url);
				InputStream istream = request.send();
				DataInputStream datais	= new DataInputStream(istream);
				string? line;
				while ((line = datais.read_line ()) != null) 
				{
					stdout.printf("%s\n", line);
				}
				
			}
			catch(Error e)
			{
				stdout.printf("ERROR: %s\n", e.message);
				return false;
			}
			*/
			return true;
		}
		public static string jsonEncode(HashMap<string, string> data)
		{
			var generator = new Json.Generator();
			var root = new Json.Node(Json.NodeType.OBJECT);
			Json.Object obj = new Json.Object();
			
			return "";
			
		}
	}
}

