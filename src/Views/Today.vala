/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alain23@protonmail.com>
*/

public class Views.Today : Gtk.EventBox {
    public MainWindow window { get; construct; }
    private Widgets.TaskNew task_new_revealer;
    private Gtk.ListBox tasks_list;
    private Gtk.Button add_task_button;
    private Gtk.Revealer box_revealer;
    private Gtk.FlowBox labels_flowbox;
    private Widgets.AlertView alert_view;
    private Widgets.Popovers.LabelsPopover labels_popover;

    private Gtk.Stack main_stack;
    private bool first_init;
    public Today () {
        Object (
            expand: true
        );
    }

    construct {
        first_init = true;
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        alert_view = new Widgets.AlertView (
            _("You're all done for today!"),
            _("Enjoy your day."),
            "emblem-default-symbolic"
        );

        var today_icon = new Gtk.Image.from_icon_name ("planner-today-" + new GLib.DateTime.now_local ().get_day_of_month ().to_string (), Gtk.IconSize.DND);

        var today_label = new Gtk.Label ("<b>%s</b>".printf (_("Today")));
        today_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        today_label.use_markup = true;

        var date_label = new Gtk.Label ("<b>%s</b>".printf (Application.utils.get_default_date_format_from_date (new GLib.DateTime.now_local ())));
        date_label.valign = Gtk.Align.CENTER;
        date_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        date_label.use_markup = true;

        var show_hide_all_button = new Gtk.ToggleButton ();
        show_hide_all_button.valign = Gtk.Align.CENTER;
        show_hide_all_button.halign = Gtk.Align.CENTER;
        show_hide_all_button.get_style_context ().add_class ("planner-zoom-in-menu");
        show_hide_all_button.tooltip_text = _("Open all tasks");

        var show_hide_image = new Gtk.Image.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
        show_hide_all_button.add (show_hide_image);

        var paste_button = new Gtk.Button.from_icon_name ("planner-paste-symbolic", Gtk.IconSize.MENU);
        paste_button.get_style_context ().add_class ("planner-paste-menu");
        paste_button.tooltip_text = _("Paste");
        paste_button.valign = Gtk.Align.CENTER;
        paste_button.halign = Gtk.Align.CENTER;

        var labels_button = new Gtk.Button.from_icon_name ("planner-label-symbolic", Gtk.IconSize.MENU);
        labels_button.get_style_context ().add_class ("planner-label-menu");
        labels_button.tooltip_text = _("Filter by Label");
        labels_button.valign = Gtk.Align.CENTER;
        labels_button.halign = Gtk.Align.CENTER;

        labels_popover = new Widgets.Popovers.LabelsPopover (labels_button, true);
        labels_popover.position = Gtk.PositionType.BOTTOM;

        var share_button = new Gtk.Button.from_icon_name ("planner-share-symbolic", Gtk.IconSize.MENU);
        share_button.get_style_context ().add_class ("planner-share-menu");
        share_button.tooltip_text = _("Share");
        share_button.valign = Gtk.Align.CENTER;
        share_button.halign = Gtk.Align.CENTER;

        share_button.clicked.connect (() => {
            var share_dialog = new Dialogs.ShareDialog (Application.instance.main_window);
            share_dialog.today = true;
            share_dialog.destroy.connect (Gtk.main_quit);
            share_dialog.show_all ();
        });

        var action_grid = new Gtk.Grid ();
        action_grid.column_spacing = 12;
        action_grid.valign = Gtk.Align.CENTER;

        action_grid.add (labels_button);
        action_grid.add (paste_button);
        action_grid.add (share_button);
        action_grid.add (show_hide_all_button);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.hexpand = true;
        top_box.margin_start = 12;
        top_box.margin_top = 12;

        top_box.pack_start (today_icon, false, false, 0);
        top_box.pack_start (today_label, false, false, 12);
        top_box.pack_start (date_label, false, false, 0);
        top_box.pack_end (action_grid, false, false, 12);

        tasks_list = new Gtk.ListBox  ();
        tasks_list.activate_on_single_click = true;
        tasks_list.selection_mode = Gtk.SelectionMode.SINGLE;
        tasks_list.valign = Gtk.Align.START;
        tasks_list.hexpand = true;

        add_task_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        add_task_button.height_request = 32;
        add_task_button.width_request = 32;
        add_task_button.get_style_context ().add_class ("button-circular");
        add_task_button.get_style_context ().add_class ("no-padding");
        add_task_button.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        add_task_button.tooltip_text = _("Add new task");

        box_revealer = new Gtk.Revealer ();
        box_revealer.valign = Gtk.Align.END;
        box_revealer.halign = Gtk.Align.END;
        box_revealer.margin = 12;
        box_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        box_revealer.add (add_task_button);
        box_revealer.reveal_child = true;

        task_new_revealer = new Widgets.TaskNew (true);
        task_new_revealer.valign = Gtk.Align.END;
        task_new_revealer.when_datetime = new GLib.DateTime.now_local ();

        var events_widget = new Widgets.CalendarEvents ();
        events_widget.halign = Gtk.Align.END;

        labels_flowbox = new Gtk.FlowBox ();
        labels_flowbox.selection_mode = Gtk.SelectionMode.NONE;
        labels_flowbox.margin_start = 6;
        labels_flowbox.height_request = 38;
        labels_flowbox.expand = false;

        var labels_flowbox_revealer = new Gtk.Revealer ();
        labels_flowbox_revealer.margin_start = 3;
        labels_flowbox_revealer.margin_top = 6;
        labels_flowbox_revealer.add (labels_flowbox);
        labels_flowbox_revealer.reveal_child = false;

        var t_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        t_box.hexpand = true;
        t_box.pack_start (top_box, false, false, 0);
        t_box.pack_start (labels_flowbox_revealer, false, false, 0);

        var b_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        b_box.expand = true;
        b_box.pack_start (tasks_list, false, true, 0);

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.margin_start = 9;
        main_stack.margin_bottom = 9;
        main_stack.transition_duration = 350;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (b_box, "main");
        main_stack.add_named (alert_view, "alert");

        main_stack.visible_child_name = "main";

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.expand = true;
        box.pack_start (t_box, false, true, 0);
        box.pack_start (main_stack, false, true, 0);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (scrolled, true, true, 0);

        var main_overlay = new Gtk.Overlay ();
        main_overlay.add_overlay (events_widget);
        main_overlay.add_overlay (box_revealer);
        main_overlay.add_overlay (task_new_revealer);
        main_overlay.add (main_box);

        add (main_overlay);
        
        Gdk.Display display = Gdk.Display.get_default ();
        Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);

        // Signals
        show_hide_all_button.toggled.connect (() => {
          if (show_hide_all_button.active) {
              show_hide_all_button.tooltip_text = _("Close all tasks");
              show_hide_image.icon_name = "zoom-out-symbolic";

              foreach (Gtk.Widget element in tasks_list.get_children ()) {
                  var row = element as Widgets.TaskRow;
                  row.show_content ();
              }
          } else {
              show_hide_all_button.tooltip_text = _("Open all tasks");
              show_hide_image.icon_name = "zoom-in-symbolic";

              foreach (Gtk.Widget element in tasks_list.get_children ()) {
                  var row = element as Widgets.TaskRow;
                  row.hide_content ();
              }
          }
        });

        events_widget.on_signal_close.connect (() => {
            events_widget.reveal_child = false;
            box_revealer.reveal_child = true;
        });

        add_task_button.clicked.connect (() => {
            task_on_revealer ();
        });

        task_new_revealer.on_signal_close.connect (() => {
            task_on_revealer ();
        });

        paste_button.clicked.connect (() => {
            string text = "";
            text = clipboard.wait_for_text ();

            if (text == "" || text == null) {
                // Notificacion Here ...
                Application.notification.send_local_notification (
                    _("Empty clipboard"),
                    _("Try copying some text and try again"),
                    "dialog-error",
                    3,
                    false);
            } else {
                var task = new Objects.Task ();
                task.content = text;
                task.is_inbox = 1;
                task.when_date_utc = new GLib.DateTime.now_local ().to_string ();

                if (Application.database.add_task (task) == Sqlite.DONE) {
                    // Notificacion Here ...
                    Application.notification.send_local_notification (
                        _("His task was created from the clipboard"),
                        _("Tap to undo"),
                        "edit-paste",
                        3,
                        true);
                }
            }
        });

        this.event.connect ((event) => {
            var button_press = Application.settings.get_enum ("quick-save");

            if (button_press == 0) {

            } else if (button_press == 1) {
                if (event.type == Gdk.EventType.@2BUTTON_PRESS) {
                    foreach (Gtk.Widget element in tasks_list.get_children ()) {
                        var row = element as Widgets.TaskRow;

                        if (row.bottom_box_revealer.reveal_child) {
                            row.hide_content ();
                        }
                    }
                }
            } else {
                if (event.type == Gdk.EventType.@3BUTTON_PRESS) {
                    foreach (Gtk.Widget element in tasks_list.get_children ()) {
                        var row = element as Widgets.TaskRow;

                        if (row.bottom_box_revealer.reveal_child) {
                            row.hide_content ();
                        }
                    }
                }
            }

            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                events_widget.reveal_child = false;
                box_revealer.reveal_child = true;
            }

            return false;
        });

        labels_button.clicked.connect (() => {
            labels_popover.update_label_list ();
            labels_popover.show_all ();
        });

        labels_popover.on_selected_label.connect ((label) => {
            if (Application.utils.is_label_repeted (labels_flowbox, label.id) == false) {
                var child = new Widgets.LabelChild (label);
                labels_flowbox.add (child);
            }

            labels_flowbox_revealer.reveal_child = !Application.utils.is_empty (labels_flowbox);
            labels_flowbox.show_all ();
            labels_popover.popdown ();

            // Filter
            tasks_list.set_filter_func ((row) => {
                var item = row as Widgets.TaskRow;
                var labels = new Gee.ArrayList<int> ();
                var _labels = new Gee.ArrayList<int> ();

                foreach (string label_id in item.task.labels.split (";")) {
                    labels.add (int.parse (label_id));
                }

                foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
                    var child = element as Widgets.LabelChild;
                    _labels.add (child.label.id);
                }

                // Filter
                foreach (int x in labels) {
                    if (x in _labels) {
                        return true;
                    }
                }

                return false;
            });
        });

        labels_flowbox.remove.connect ((widget) => {
            if (Application.utils.is_empty (labels_flowbox)) {
                labels_flowbox_revealer.reveal_child = false;
                tasks_list.set_filter_func ((row) => {
                    return true;
                });
            } else {
                // Filter
                tasks_list.set_filter_func ((row) => {
                    var item = row as Widgets.TaskRow;
                    var labels = new Gee.ArrayList<int> ();
                    var _labels = new Gee.ArrayList<int> ();

                    foreach (string label_id in item.task.labels.split (";")) {
                        labels.add (int.parse (label_id));
                    }

                    foreach (Gtk.Widget element in labels_flowbox.get_children ()) {
                        var child = element as Widgets.LabelChild;
                        _labels.add (child.label.id);
                    }

                    // Filter
                    foreach (int x in labels) {
                        if (x in _labels) {
                            return true;
                        }
                    }

                    return false;
                });
            }
        });

        tasks_list.remove.connect ((widget) => {
            check_visible_alertview ();
        });

        Application.database.update_task_signal.connect ((task) => {
            if (Application.utils.is_task_repeted (tasks_list, task.id) == false) {
                add_new_task (task);
            }

            foreach (Gtk.Widget element in tasks_list.get_children ()) {
                var row = element as Widgets.TaskRow;

                if (row.task.id == task.id) {
                    var _when = new GLib.DateTime.from_iso8601 (task.when_date_utc, new GLib.TimeZone.local ());

                    if (Application.utils.is_today (_when) == false) {
                        if (row is Gtk.Widget) {
                            GLib.Timeout.add (250, () => {
                                row.destroy ();
                                return GLib.Source.REMOVE;
                            });
                        }
                    } else {
                        row.set_update_task (task);
                    }
                }
            }
        });

        Application.database.add_task_signal.connect ((task) => {
            add_new_task (task);
        });

        Application.database.on_signal_remove_task.connect ((task) => {
            foreach (Gtk.Widget element in tasks_list.get_children ()) {
                var row = element as Widgets.TaskRow;

                if (row.task.id == task.id) {
                    if (row is Gtk.Widget) {
                        GLib.Timeout.add (250, () => {
                            row.destroy ();
                            return GLib.Source.REMOVE;
                        });
                    }
                }
            }
        });
    }

    public void check_visible_alertview () {
        if (Application.utils.is_listbox_empty (tasks_list)) {
            main_stack.visible_child_name = "alert";
        } else {
            main_stack.visible_child_name = "main";
        }

        show_all ();
    }

    private void add_new_task (Objects.Task task) {
        if (task.when_date_utc != "") {
            var when = new GLib.DateTime.from_iso8601 (task.when_date_utc, new GLib.TimeZone.local ());
            if (Application.utils.is_today (when) || Application.utils.is_before_today (when)) {
                var row = new Widgets.TaskRow (task);

                tasks_list.add (row);

                row.on_signal_update.connect ((_task) => {
                    var _when = new GLib.DateTime.from_iso8601 (_task.when_date_utc, new GLib.TimeZone.local ());

                    if (Application.utils.is_today (_when) == false) {
                        // Send quick notification
                        string view = "";

                        if (Application.utils.is_upcoming (_when)) {
                            view = _("Upcoming");
                        } else if (_task.is_inbox == 1) {
                            view = _("Inbox");
                        } else {
                            var project = new Objects.Project ();
                            project = Application.database.get_project (_task.project_id);
                            view = project.name;
                        }

                        Application.notification.send_local_notification (
                            task.content,
                            _("It was moved to %s").printf (view),
                            "document-export",
                            3,
                            false
                        );

                        if (row is Gtk.Widget) {
                            GLib.Timeout.add (250, () => {
                                row.destroy ();
                                return GLib.Source.REMOVE;
                            });
                        }
                    }
                });

                tasks_list.show_all ();
            }

            check_visible_alertview ();
        }
    }

    public void update_tasks_list () {
        if (first_init) {
            Application.signals.start_loading_item ("today");

            Timeout.add (200, () => {
                var all_tasks = new Gee.ArrayList<Objects.Task?> ();
                all_tasks = Application.database.get_all_today_tasks ();

                foreach (var task in all_tasks) {
                    var row = new Widgets.TaskRow (task);

                    tasks_list.add (row);

                    row.on_signal_update.connect ((_task) => {
                        var _when = new GLib.DateTime.from_iso8601 (_task.when_date_utc, new GLib.TimeZone.local ());

                        if (Application.utils.is_today (_when) == false) {
                            // Send quick notification
                            string view = "";
                            if (_task.is_inbox == 1) {
                                view = _("Inbox");
                            } else {
                                var project = new Objects.Project ();
                                project = Application.database.get_project (_task.project_id);
                                view = project.name;
                            }

                            Application.notification.send_local_notification (
                                task.content,
                                _("It was moved to %s").printf (view),
                                "document-export",
                                3,
                                false
                            );

                            if (row is Gtk.Widget) {
                                GLib.Timeout.add (250, () => {
                                    row.destroy ();
                                    return GLib.Source.REMOVE;
                                });
                            }
                        }
                    });

                    tasks_list.show_all ();
                }

                if (Application.utils.is_listbox_empty (tasks_list)) {
                    Timeout.add (200, () => {
                        main_stack.visible_child_name = "alert";
                        return false;
                    });
                } else {
                    Timeout.add (200, () => {
                        main_stack.visible_child_name = "main";
                        return false;
                    });
                }

                tasks_list.set_sort_func ((row1, row2) => {
                    var item1 = row1 as Widgets.TaskRow;
                    if (item1.task.checked == 0) {
                        return 0;
                    } else {
                        return 1;
                    }
                });

                tasks_list.set_filter_func ((row) => {
                    var item = row as Widgets.TaskRow;
                    return item.task.checked == 0;
                });

                tasks_list.invalidate_sort ();

                first_init = false;
                Application.signals.stop_loading_item ("today");

                return false;
            });
        }
    }

    private void task_on_revealer () {
        if (task_new_revealer.reveal_child) {
            task_new_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            task_new_revealer.reveal_child = false;

            box_revealer.reveal_child = true;
        } else {
            task_new_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            task_new_revealer.reveal_child = true;

            box_revealer.reveal_child = false;
            task_new_revealer.name_entry.grab_focus ();

            task_new_revealer.when_button.set_date (new GLib.DateTime.now_local (), false, new GLib.DateTime.now_local ());
        }
    }
}
