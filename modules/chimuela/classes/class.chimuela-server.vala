using GLib;
using Gee;

namespace EPos
{
	public class ChimuelaServer : Object
	{
		protected	SocketService	server;
		protected	bool killServer{get;set;default = false;}
		protected	MainLoop		loop;
		protected	string			configFile;
		
		public ChimuelaServer()
		{
			this.configFile = "chimuela.xml";
		}
		public bool Start()
		{
			try
			{
				this.server = new SocketService();
				this.server.add_inet_port(2205, null);
				this.server.incoming.connect(this.OnClientConnected);
				this.server.start();
				this.loop = new MainLoop ();
				this.loop.run ();
			}
			catch(GLib.Error e)
			{
				stderr.printf("Chimuela ERROR: %s\n", e.message);
			}
			return true;
		}
		public bool Stop()
		{
			this.killServer = true;
			this.server.stop();
			this.loop.quit();
			return true;
		}
		protected bool OnClientConnected(SocketConnection conn)
		{
			this.ProcessRequest.begin(conn);
			return true;
		}
		protected async void ProcessRequest(SocketConnection conn)
		{
			try 
			{
				var dis = new DataInputStream (conn.input_stream);
				var dos = new DataOutputStream (conn.output_stream);
				string req = yield dis.read_line_async (Priority.HIGH_IDLE);
				if( !this.ClientAllowed(conn) )
				{
					dos.put_string ("Chimuela Info: You are not allowed to connect.\n");
					return;
				}
				if( req.strip().up() == "-:CLOSE:-" )
				{
					this.Stop();
				}
				else if( req.strip().up() == "-:RESTART:-" )
				{
					this.Stop();
				}
				dos.put_string ("Got: %s\n".printf (req));
			} 
			catch (GLib.Error e) 
			{
				stderr.printf ("Chimuela Process Request ERROR: %s\n", e.message);
			}
		}
		protected bool ClientAllowed(SocketConnection conn)
		{
			//SocketAddress local_address = conn.get_local_address();
			InetSocketAddress local_address = (InetSocketAddress)conn.get_local_address();
			InetSocketAddress remote_address = (InetSocketAddress)conn.get_remote_address();
			
			stdout.printf("Local address: %s\n", local_address.address.to_string());
			stdout.printf("Remote address: %s\n", remote_address.address.to_string());
			return true;
		}
		protected void HandleCommand()
		{
		}
	}
}
public int main(string[] args)
{
	var srv = new EPos.ChimuelaServer();
	srv.Start();
	return 0;
}
