using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using Gtk;

namespace EPos
{
	public class WidgetPosConfig : Box
	{
		protected	Builder		ui;
		protected	Box			box1;
		protected	ComboBox	comboboxPosGui;
		
		public WidgetPosConfig()
		{
			this.ui			= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("widget.pos-config.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.comboboxPosGui	= (ComboBox)this.ui.get_object("comboboxPosGui");
			this.box1.reparent(this);
			this.Build();
		}
		~WidgetPosConfig()
		{
			SBModules.remove_action("before_save_config", this.before_save_config);
		}
		protected void Build()
		{
			this.comboboxPosGui.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxPosGui.pack_start(cell, true);
			this.comboboxPosGui.set_attributes(cell, "text", 0);
			this.comboboxPosGui.id_column = 1;
			
			TreeIter iter;
			(this.comboboxPosGui.model as ListStore).append(out iter);
			(this.comboboxPosGui.model as ListStore).set(iter, 0, SBText.__("-- pos gui --"), 1, "-1");
			(this.comboboxPosGui.model as ListStore).append(out iter);
			(this.comboboxPosGui.model as ListStore).set(iter, 0, SBText.__("Standard"), 1, "standard");
			(this.comboboxPosGui.model as ListStore).append(out iter);
			(this.comboboxPosGui.model as ListStore).set(iter, 0, SBText.__("Retail"), 1, "retail");
			
			this.comboboxPosGui.active_id = (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("pos_gui", "standard");
			//## add hooks
			var hook0 = new SBModuleHook(){HookName = "before_save_config", handler = this.before_save_config};
			SBModules.add_action("before_save_config", ref hook0);
		}
		public void before_save_config(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			(data["config"] as SBConfig).SetValue("pos_gui", this.comboboxPosGui.active_id);
		}
	}
}
