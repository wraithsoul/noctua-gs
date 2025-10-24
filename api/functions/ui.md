# ui
Description:
Functions for interfacing with the GameSense user interface.

## Functions

### `get`
`ui.get(item: number): any`
*   For a checkbox, returns **true** or **false**.
*   For a slider, returns an **integer**.
*   For a combobox, returns a **string**.
*   For a multiselect combobox, returns an **array of strings**.
*   For a hotkey, returns **true** if the hotkey is active.
*   For a color picker, returns **r, g, b, a**.
*   Throws an error on failure.

### `is_menu_open`
`ui.is_menu_open(): boolean`
Returns **true** if the menu is currently open.

### `menu_position`
`ui.menu_position(): number, number`
Returns the **x, y** of the menu, even when closed.

### `menu_size`
`ui.menu_size(): number, number`
Returns the **width, height** of the menu, even when closed.

### `mouse_position`
`ui.mouse_position(): number, number`
Returns current mouse coordinates **x, y**.

### `name`
`ui.name(item: number): string`
Returns the display name.

### `new_button`
`ui.new_button(tab: string, container: string, name: string, callback): number`
Throws an error on failure. The return value should **not** be used with `ui.set` or `ui.get`.

### `new_checkbox`
`ui.new_checkbox(tab: string, container: string, name: string): number`
Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.

### `new_color_picker`
`ui.new_color_picker(tab: string, container: string, name: string, r: number, g: number, b: number, a: number): number`
Throws an error on failure. The color picker is placed to the right of the previous menu item.

### `new_combobox`
`ui.new_combobox(tab: string, container: string, name: string, ...): number`
Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.

### `new_hotkey`
`ui.new_hotkey(tab: string, container: string, name: string, inline: boolean, default_hotkey: number): number`
Returns a special value that can be passed to `ui.get` to see if the hotkey is pressed, or throws an error on failure.

### `new_label`
`ui.new_label(tab: string, container: string, name: string): number`
Creates a new label, this can be used to make otherwise attached menu items standalone or have interactive menus. Returns a special value that can be passed to `ui.set`, or throws an error on failure.

### `new_listbox`
`ui.new_listbox(tab: string, container: string, name: string, items: table): number`
Throws an error on failure. Returns a special value that can be used with `ui.get`. Calling `ui.get` on a listbox will return the zero-based index of the currently selected string.

### `new_multiselect`
`ui.new_multiselect(tab: string, container: string, name: string, ...): number`
Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.

### `new_slider`
`ui.new_slider(tab: string, container: string, name: string, min: number, max: number, init_value: number, show_tooltip: boolean, unit: string, scale: number, tooltips: table): number`
Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.

### `new_string`
`ui.new_string(name: string, default_value: string): number`
Creates a string UI element, can be used to store arbitrary strings in configs. No menu item is created but it has the same semantics as other `ui.new_*` functions. Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.

### `new_textbox`
`ui.new_textbox(tab: string, container: string, name: string): number`
Throws an error on failure. Returns a special value that can be used with `ui.get`.

### `reference`
`ui.reference(tab: string, container: string, name: string): number`
**Avoid calling this from inside a function.** Returns a reference that can be passed to `ui.get` and `ui.set`, or throws an error on failure. This allows you to access a built-in pre-existing menu items. This function returns multiple values when the specified menu item is followed by unnamed menu items, for example a color picker or a hotkey.

### `set`
`ui.set(item: number, value: any, ...)`
*   For checkboxes, pass **true** or **false**.
*   For a slider, pass a **number** that is within the slider's minimum/maximum values.
*   For a combobox, pass a **string** value.
*   For a multiselect combobox, pass zero or more **strings**.
*   For referenced buttons, `value` is ignored and the button's callback is invoked.
*   For color pickers, pass the arguments **r, g, b, a**.

### `set_callback`
`ui.set_callback(item: number, callback)`
Sets the change callback of a custom menu item. It will be executed on change and passed the reference.

### `set_enabled`
`ui.set_enabled(item: number, enabled: boolean)`
Sets the enabled state of the menu item.

### `set_visible`
`ui.set_visible(item: number, visible: boolean)`
Sets the visibility of the menu item.

### `type`
`ui.type(item: number)`
Returns the type of an element.

### `update`
`ui.update(item: number, value: any, ...)`
*Note: This description seems to be a duplicate of `new_string` or a generic description for setting values, but the function name is `update`. Given the context of `ui.set`, this might be for internally updating the UI element's displayed value without triggering a change callback, or it might be another way to set the value. Sticking to the provided text:*
Creates a string UI element, can be used to store arbitrary strings in configs. No menu item is created but it has the same semantics as other `ui.new_*` functions. Returns a special value that can be passed to `ui.get` and `ui.set`, or throws an error on failure.