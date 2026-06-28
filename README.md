# Property Binder for Godot.
Features:
- Automatically syncs data between objects and UI.
- When objects are changed, the bound UI updates to display the properties of the new object.
- Changes made in the UI are written back to the object.

How to use:

There are examples for every configuration in the examples folder, please check them out.

## PropertyBinder
For binding a single property, you can use an individual PropertyBinder.
1) Create a new PropertyBinder. Pass the Control and the name of the object property to bind.
Next, assign the object to bind to.
2) Assign the object by calling assign_obj(). The property is now bound to the control.

## PropertyBinderGroup
For binding more than one property of the same object to multiple controls, a PropertyBinderGroup can be used.
1) Create a new PropertyBinderGroup.
2) Add new bindings by calling add_binding().
3) Assing the object to the PropertyBindingGroup by calling assing_obj()
The PropertyBinderGroup now handles syncing the object to its bound controls.

## PropertyBinderGroupNode
To wire everything up without code, a PropertyBinderGroupNode can be used. For each property to be bound, add a PropertyBinderNode as a direct child of the PropertyBinderGroupNode and configure.

This can be used to permanently bind a single object without writing code or setting up a compolex UI without code and assigning different objects through code.

## Mappings
The PropertyBinders use a mapping system to find the correct control properties to map to. Default mappings are set in the Mapping/Map.tres Resource, and more can be added here.
Mapping rules:
- 1 PropertyMap per Variant.Type
- 1 ControlMap per PropertyMap and Control type
- control_type is the class_name of the Control this mapping is for (i.e. "CheckBox", "LineEdit", etc.)
- control_property is the property of the control that will be used for the binding (i.e. "value", "text", etc.)
- control_signal is the signal used for syncing changes made in the control back to the object. Set to "NONE" to disable (readonly).

### Mapping Overrides
When creating a binding, you can pass 2 optional parameters. These overwrite the Mappings from the default mapping library.

This can be done when adding a binding as a PropertyBinder, in a PropertyBinderGroup or on a PropertyBinderNode.
