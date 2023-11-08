# https://can-lehmann.github.io/owlkettle/docs/tutorial.html

import owlkettle
import owlkettle/adw
import std/sequtils

type TodoItem = object
   text: string
   done: bool

viewable App:
   todos: seq[TodoItem]
   new_item: string
   hide_complete: bool = false

method view(app: AppState): Widget =
   result = gui:
      Window:
         title = "Todo"

         HeaderBar {.addTitlebar.}:
            WindowTitle {.addTitle.}:
               title = "Todo"
               subtitle = $app.todos.filter_it(not it.done).len & " task(s) to do"

            MenuButton {.add_right.}:
               icon = "open-menu-symbolic"
               PopoverMenu:
                  Box {.name: "main".}:
                     orient = OrientY
                     spacing = 3
                     margin = 4

                     Box(orient = OrientX):
                        Icon:
                           if app.hide_complete:
                              name = "dino-tick"
                           else:
                              name = ""
                        ModelButton:
                           text = "Hide completed"
                           proc clicked() =
                              app.hide_complete = not app.hide_complete
                     
                     Separator()

                     ModelButton:
                        text = "Delete completed"
                        proc clicked() =
                           let (res, state) = app.open: gui:
                              MessageDialog:
                                 message = "Are you sure you want to delete completed entries?\nThis cannot be undone."
                                 DialogButton {.addbutton.}:
                                    text = "Cancel"
                                    res = DialogCancel
                                    style = [ButtonSuggested]
                                 DialogButton {.addbutton.}:
                                    text = "Delete"
                                    res = DialogAccept
                                    style = [ButtonDestructive]

                           discard state
                           if res.kind == DialogAccept:
                              app.todos = app.todos.filter_it(not it.done)

                     Separator()

                     ModelButton:
                        text = "About"
                        proc clicked() =
                           when defined(adwaita12):
                              discard app.open: gui:
                                 AboutWindow:
                                    applicationName = "Todo Enhanced"
                                    developerName = "Raine Lewis & Can Lehmann"
                                    version = "1.2.2"
                                    website = "https://can-lehmann.github.io/owlkettle/docs/tutorial.html"
                           else:
                              discard app.open: gui:
                                 AboutDialog:
                                    programName = "Todo Enhanced"
                                    version = "1.2.2"
                                    logo = "application-x-executable"
                                    credits = @{
                                       "Original version": @["Can Lehmann"],
                                       "Enhanced version": @["Raine Lewis"]
                                    }


         Box(orient = OrientY, spacing = 6, margin = 12):
            Box(orient = OrientX, spacing = 6) {.expand: false.}:
               Entry:
                  text = app.new_item
                  proc changed(new_item: string) =
                     app.new_item = new_item
                  proc activate() =
                     app.todos.add(TodoItem(text: app.new_item))
                     app.new_item = ""
               Button {.expand: false.}:
                  icon = "list-add-symbolic"
                  style = [ButtonSuggested]
                  proc clicked() =
                     app.todos.add(TodoItem(text: app.new_item))
                     app.new_item = ""
            
            Frame:
               ScrolledWindow:
                  ListBox:
                     selection_mode = SelectionNone
                     for it, todo in app.todos:
                        if (not app.hide_complete) or (app.hide_complete and not todo.done):
                           Box:
                              spacing = 6
                              CheckButton {.expand: false.}:
                                 state = todo.done
                                 proc changed(state: bool) = 
                                    app.todos[it].done = state
                              Label:
                                 text = todo.text
                                 x_align = 0

adw.brew(gui(App(todos = @[
   TodoItem(text: "Clean up UX a little", done: true),
   TodoItem(text: "Add About menu", done: true),
   TodoItem(text: "Require confirmation for deleting", done: true),
   TodoItem(text: "Add edit and delete context options on task list"),
   TodoItem(text: "Save and load todo entries")
])))

