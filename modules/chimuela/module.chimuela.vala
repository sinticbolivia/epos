using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos
{
	public class SB_ModuleChimuela : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Chimuela";}}
		
		protected	Pid			chimuelaPid;
		construct
		{
			this._moduleId 		= "mod_chimuela";
			this._name			= "Chimuela - EPos Server Module";
			this._description 	= "Enable your Point of Sale to work using client-server architecture.";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceNs		= "/net/sinticbolivia/EPos/Chimuela";
			this.resourceFile 	= "./modules/moodule.chimuela.gresource";
		}
		public void Enabled()
		{
			
		}
		public void Disabled()
		{
		}
		public void Load()
		{
			
			
		}
		public void Unload(){}
		public void Init()
		{
			var hook0 = new SBModuleHook(){HookName = "on_quit", handler = this.hook_on_quit};
			SBModules.add_action("on_quit", ref hook0);
			//MainLoop loop = new MainLoop ();
			try
			{
				Process.spawn_async(".", {"chimuela"}, Environ.get(),
					SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
					null,
					out this.chimuelaPid
				);
				ChildWatch.add (this.chimuelaPid, (pid, status) => 
				{
					stdout.printf("ChildWatch\n");
					// Triggered when the child indicated by child_pid exits
					Process.close_pid (pid);
					Process.close_pid (this.chimuelaPid);
					//loop.quit ();
				});
				//loop.run();
			}
			catch(SpawnError e)
			{
				stderr.printf("Module Chimuela ERROR: %s\n", e.message);
			}
		}
		protected void hook_on_quit(SBModuleArgs<string> args)
		{
			stdout.printf("Shutting down chimuela server, pid => %d\n", this.chimuelaPid);
			//if( this.chimuelaPid != null )
			//{
				Process.close_pid (this.chimuelaPid);
				//Posix.kill(this.chimuelaPid, 2);
			//}
			// Connect
			string host = "localhost";
			var resolver = Resolver.get_default ();
			var addresses = resolver.lookup_by_name (host, null);
			var address = addresses.nth_data (0);
			var client = new SocketClient ();
			var conn = client.connect (new InetSocketAddress (address, 2205));
			conn.output_stream.write ("-:CLOSE:-".data);
		}
	}
}
public Type sb_get_module_libchimuela_type(Module module)
{
	return typeof(EPos.SB_ModuleChimuela);
}
